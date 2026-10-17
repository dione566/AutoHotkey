#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Painel gráfico para converter vídeos H.265/HEVC para H.264/AVC.
Requer FFmpeg instalado e acessível pelo PATH do Windows.
"""

import os
import shutil
import subprocess
import threading
import queue
from pathlib import Path
import tkinter as tk
from tkinter import ttk, filedialog, messagebox

VIDEO_EXTS = {
    ".mp4", ".mkv", ".mov", ".avi", ".m4v", ".ts", ".webm",
    ".wmv", ".flv", ".mpg", ".mpeg", ".3gp", ".mts", ".m2ts"
}

BG = "#08111b"
PANEL = "#0e1c2a"
PANEL2 = "#102437"
BLUE = "#168cf0"
BLUE_HOVER = "#0876d8"
TEXT = "#f1f6fc"
MUTED = "#9eb6cb"
GREEN = "#48d597"
RED = "#ff6b6b"


class ConverterApp:
    def __init__(self, root):
        self.root = root
        self.root.title("H.265 → H.264 Converter")
        self.root.geometry("680x560")
        self.root.minsize(600, 500)
        self.root.configure(bg=BG)

        self.selected_files = []
        self.source_description = ""
        self.output_dir = ""
        self.ffmpeg_path = shutil.which("ffmpeg") or ""
        self.worker = None
        self.events = queue.Queue()
        self.running = False

        self._style()
        self._build_ui()
        self.root.after(100, self._process_events)

    def _style(self):
        style = ttk.Style()
        try:
            style.theme_use("clam")
        except tk.TclError:
            pass
        style.configure(
            "Blue.Horizontal.TProgressbar",
            troughcolor="#203449", background=BLUE, bordercolor="#203449",
            lightcolor=BLUE, darkcolor=BLUE
        )

    def _label(self, parent, text, size=10, color=TEXT, bold=False):
        return tk.Label(
            parent, text=text, bg=parent.cget("bg"), fg=color,
            font=("Segoe UI", size, "bold" if bold else "normal"),
            anchor="w", justify="left"
        )

    def _button(self, parent, text, command, primary=False):
        bg = BLUE if primary else PANEL2
        active = BLUE_HOVER if primary else "#19364f"
        return tk.Button(
            parent, text=text, command=command, bg=bg, fg=TEXT,
            activebackground=active, activeforeground=TEXT,
            relief="flat", bd=0, padx=10, pady=5,
            font=("Segoe UI", 9, "bold" if primary else "normal"),
            cursor="hand2"
        )

    def _card(self, parent, padx=12, pady=10):
        frame = tk.Frame(parent, bg=PANEL, highlightbackground="#1d3449",
                         highlightthickness=1, padx=padx, pady=pady)
        return frame

    def _build_ui(self):
        header = tk.Frame(self.root, bg=BG, padx=14, pady=8)
        header.pack(fill="x")
        self._label(header, "▣  H.265 → H.264 Converter", 14, TEXT, True).pack(anchor="w")

        content = tk.Frame(self.root, bg=BG, padx=14)
        content.pack(fill="both", expand=True)

        top_grid = tk.Frame(content, bg=BG)
        top_grid.pack(fill="x", pady=(0, 6))
        top_grid.columnconfigure(0, weight=1)
        top_grid.columnconfigure(1, weight=1)

        # Card FFmpeg
        ffcard = self._card(top_grid, padx=10, pady=8)
        ffcard.grid(row=0, column=0, sticky="nsew", padx=(0, 4))
        self._label(ffcard, "FFmpeg", 10, TEXT, True).pack(anchor="w")
        
        self.ffmpeg_var = tk.StringVar(
            value=self.ffmpeg_path if self.ffmpeg_path else "Não selecionado"
        )
        ff_box = tk.Frame(ffcard, bg="#0a1723", padx=6, pady=4, highlightbackground="#20384e", highlightthickness=1)
        ff_box.pack(fill="x", pady=4)
        tk.Label(ff_box, textvariable=self.ffmpeg_var, bg="#0a1723", fg=MUTED,
                 font=("Segoe UI", 8), anchor="w", wraplength=280, justify="left").pack(fill="x")
        
        ff_btn_frame = tk.Frame(ffcard, bg=PANEL)
        ff_btn_frame.pack(fill="x")
        self._button(ff_btn_frame, "📄 .exe", self.select_ffmpeg).pack(side="left", expand=True, fill="x", padx=(0, 2))
        self._button(ff_btn_frame, "📁 Pasta", self.select_ffmpeg_folder).pack(side="left", expand=True, fill="x", padx=(2, 0))

        # Card Pasta de Saída
        outcard = self._card(top_grid, padx=10, pady=8)
        outcard.grid(row=0, column=1, sticky="nsew", padx=(4, 0))
        
        out_header_frame = tk.Frame(outcard, bg=PANEL)
        out_header_frame.pack(fill="x")
        self._label(out_header_frame, "Pasta de Saída", 10, TEXT, True).pack(side="left")
        self._button(out_header_frame, "📁 Alterar", self.select_output_folder).pack(side="right")

        self.output_var = tk.StringVar(value="Mesma da origem (padrão)")
        out_box = tk.Frame(outcard, bg="#0a1723", padx=6, pady=4, highlightbackground="#20384e", highlightthickness=1)
        out_box.pack(fill="x", pady=4)
        tk.Label(out_box, textvariable=self.output_var, bg="#0a1723", fg=MUTED,
                 font=("Segoe UI", 8), anchor="w", wraplength=280, justify="left").pack(fill="x")

        # Card Origem
        card1 = self._card(content, padx=10, pady=8)
        card1.pack(fill="x", pady=(0, 6))
        
        c1_top = tk.Frame(card1, bg=PANEL)
        c1_top.pack(fill="x")
        self._label(c1_top, "Origem dos Vídeos", 10, TEXT, True).pack(side="left")
        
        c1_btns = tk.Frame(c1_top, bg=PANEL)
        c1_btns.pack(side="right")
        self._button(c1_btns, "📁 Pasta", self.select_folder).pack(side="left", padx=(0, 4))
        self._button(c1_btns, "🎞 Vídeo(s)", self.select_files).pack(side="left")

        self.path_var = tk.StringVar(value="Nenhuma pasta ou vídeo selecionado")
        pathbox = tk.Frame(card1, bg="#0a1723", padx=6, pady=4, highlightbackground="#20384e", highlightthickness=1)
        pathbox.pack(fill="x", pady=4)
        tk.Label(pathbox, textvariable=self.path_var, bg="#0a1723", fg=MUTED,
                 font=("Segoe UI", 8), anchor="w", wraplength=600, justify="left").pack(fill="x")

        # Card Qualidade
        card2 = self._card(content, padx=10, pady=8)
        card2.pack(fill="x", pady=(0, 6))
        
        row = tk.Frame(card2, bg=PANEL)
        row.pack(fill="x", pady=(0, 4))
        self._label(row, "Qualidade:", 9, MUTED).pack(side="left")
        self.quality_var = tk.StringVar(value="Alta (recomendado)")
        quality = ttk.Combobox(
            row, textvariable=self.quality_var, state="readonly", width=18,
            values=["Muito alta", "Alta (recomendado)", "Equilibrada", "Arquivo menor"]
        )
        quality.pack(side="left", padx=(8, 15))
        
        self._label(row, "Áudio:", 9, MUTED).pack(side="left")
        self._label(row, "Copiar direto", 9, GREEN).pack(side="left", padx=(5, 0))

        self._button(card2, "▶  Iniciar Conversão", self.start_conversion, True).pack(
            fill="x", pady=(4, 0)
        )

        # Card Status e Log
        card3 = self._card(content, padx=10, pady=8)
        card3.pack(fill="both", expand=True, pady=(0, 8))
        
        top_status = tk.Frame(card3, bg=PANEL)
        top_status.pack(fill="x")
        self.status_var = tk.StringVar(value="Pronto")
        self.count_var = tk.StringVar(value="Aguardando seleção...")
        self._label(top_status, "Progresso", 10, TEXT, True).pack(side="left")
        tk.Label(top_status, textvariable=self.status_var, bg=PANEL, fg=BLUE,
                 font=("Segoe UI", 9, "bold")).pack(side="right")
        
        tk.Label(card3, textvariable=self.count_var, bg=PANEL, fg=MUTED,
                 font=("Segoe UI", 8), anchor="w").pack(fill="x", pady=(2, 2))

        prog_frame = tk.Frame(card3, bg=PANEL)
        prog_frame.pack(fill="x", pady=2)
        
        p_sub1 = tk.Frame(prog_frame, bg=PANEL)
        p_sub1.pack(fill="x", pady=(0, 2))
        tk.Label(p_sub1, text="Atual:", bg=PANEL, fg=MUTED, font=("Segoe UI", 8), width=6, anchor="w").pack(side="left")
        self.progress = ttk.Progressbar(p_sub1, style="Blue.Horizontal.TProgressbar", mode="determinate", maximum=100)
        self.progress.pack(side="left", fill="x", expand=True)

        p_sub2 = tk.Frame(prog_frame, bg=PANEL)
        p_sub2.pack(fill="x")
        tk.Label(p_sub2, text="Geral:", bg=PANEL, fg=MUTED, font=("Segoe UI", 8), width=6, anchor="w").pack(side="left")
        self.total_progress = ttk.Progressbar(p_sub2, style="Blue.Horizontal.TProgressbar", mode="determinate", maximum=100)
        self.total_progress.pack(side="left", fill="x", expand=True)

        self.log = tk.Text(
            card3, height=3, bg="#07121c", fg="#c5d7e8", insertbackground=TEXT,
            relief="flat", bd=0, font=("Consolas", 8), wrap="word",
            state="disabled"
        )
        self.log.pack(fill="both", expand=True, pady=(4, 0))

    def add_log(self, text):
        self.log.configure(state="normal")
        self.log.insert("end", text + "\n")
        self.log.see("end")
        self.log.configure(state="disabled")

    def _set_ffmpeg(self, candidate):
        candidate = Path(candidate)
        if candidate.is_dir():
            possible = [
                candidate / "ffmpeg.exe",
                candidate / "bin" / "ffmpeg.exe",
                candidate / "ffmpeg",
                candidate / "bin" / "ffmpeg",
            ]
            found = next((x for x in possible if x.is_file()), None)
            if not found:
                messagebox.showerror("FFmpeg não encontrado", "Não encontrei ffmpeg.exe nesta pasta.")
                return
            candidate = found

        if not candidate.is_file() or candidate.name.lower() not in ("ffmpeg.exe", "ffmpeg"):
            messagebox.showerror("Arquivo inválido", "Selecione o executável ffmpeg.exe.")
            return

        self.ffmpeg_path = str(candidate.resolve())
        self.ffmpeg_var.set(self.ffmpeg_path)
        self.add_log(f"FFmpeg selecionado: {self.ffmpeg_path}")

    def select_ffmpeg(self):
        filename = filedialog.askopenfilename(
            title="Selecione ffmpeg.exe",
            filetypes=[("FFmpeg", "ffmpeg.exe"), ("Executáveis", "*.exe"), ("Todos", "*.*")]
        )
        if filename:
            self._set_ffmpeg(filename)

    def select_ffmpeg_folder(self):
        folder = filedialog.askdirectory(title="Selecione a pasta do FFmpeg")
        if folder:
            self._set_ffmpeg(folder)

    def select_output_folder(self):
        folder = filedialog.askdirectory(title="Selecione a pasta para mídias convertidas")
        if folder:
            self.output_dir = folder
            self.output_var.set(folder)
            self.add_log(f"Saída definida: {folder}")
        else:
            self.output_dir = ""
            self.output_var.set("Mesma da origem (padrão)")
            self.add_log("Saída redefinida para a pasta de origem")

    def get_ffmpeg_command(self):
        if self.ffmpeg_path and Path(self.ffmpeg_path).is_file():
            return self.ffmpeg_path
        return shutil.which("ffmpeg")

    def get_ffprobe_command(self, ffmpeg_exe):
        ffmpeg_path = Path(ffmpeg_exe)
        names = ("ffprobe.exe", "ffprobe")
        for name in names:
            candidate = ffmpeg_path.with_name(name)
            if candidate.is_file():
                return str(candidate)
        return shutil.which("ffprobe")

    @staticmethod
    def _get_duration(source, ffprobe_exe):
        if not ffprobe_exe:
            return 0.0
        try:
            result = subprocess.run(
                [ffprobe_exe, "-v", "error", "-show_entries", "format=duration",
                 "-of", "default=noprint_wrappers=1:nokey=1", str(source)],
                capture_output=True, text=True, encoding="utf-8", errors="replace",
                timeout=20, check=False
            )
            return max(0.0, float(result.stdout.strip())) if result.returncode == 0 else 0.0
        except (OSError, ValueError, subprocess.SubprocessError):
            return 0.0

    def select_folder(self):
        folder = filedialog.askdirectory(title="Selecione a pasta de vídeos")
        if not folder:
            return
        path = Path(folder)
        files = sorted(
            p for p in path.iterdir()
            if p.is_file() and p.suffix.lower() in VIDEO_EXTS
        )
        self.selected_files = files
        self.source_description = folder
        self.path_var.set(folder)
        self.count_var.set(f"{len(files)} vídeo(s) encontrado(s).")
        self.status_var.set("Pasta carregada")
        self.add_log(f"Pasta: {folder} ({len(files)} vídeos)")

    def select_files(self):
        filenames = filedialog.askopenfilenames(
            title="Selecione vídeos",
            filetypes=[("Vídeos", "*.mp4 *.mkv *.mov *.avi *.m4v *.ts *.webm *.wmv *.flv *.mpg *.mpeg *.3gp *.mts *.m2ts"), ("Todos", "*.*")]
        )
        if not filenames:
            return
        self.selected_files = [
            Path(f) for f in filenames
            if Path(f).suffix.lower() in VIDEO_EXTS
        ]
        self.source_description = f"{len(self.selected_files)} arquivo(s)"
        if len(self.selected_files) == 1:
            self.path_var.set(str(self.selected_files[0]))
        else:
            self.path_var.set(self.source_description)
        self.count_var.set(f"{len(self.selected_files)} vídeo(s) selecionado(s).")
        self.status_var.set("Arquivos carregados")
        self.add_log(self.source_description)

    def start_conversion(self):
        if self.running:
            return
        if not self.selected_files:
            messagebox.showwarning("Aviso", "Selecione uma pasta ou vídeo primeiro.")
            return
        ffmpeg_exe = self.get_ffmpeg_command()
        if not ffmpeg_exe:
            messagebox.showerror("Erro", "FFmpeg não encontrado.")
            return

        quality_values = {
            "Muito alta": "16",
            "Alta (recomendado)": "18",
            "Equilibrada": "21",
            "Arquivo menor": "24",
        }
        crf = quality_values.get(self.quality_var.get(), "18")
        files = list(self.selected_files)
        self.running = True
        self.progress.configure(value=0, maximum=100)
        self.total_progress.configure(value=0, maximum=100)
        self.status_var.set("Convertendo...")
        self.count_var.set(f"Iniciando {len(files)} arquivo(s)...")
        self.add_log(f"--- Início: {len(files)} arquivos (CRF {crf}) ---")
        self.worker = threading.Thread(
            target=self._convert_worker,
            args=(files, crf, ffmpeg_exe, self.get_ffprobe_command(ffmpeg_exe)), daemon=True
        )
        self.worker.start()

    def _convert_worker(self, files, crf, ffmpeg_exe, ffprobe_exe=None):
        succeeded = 0
        failed = 0
        skipped = 0
        total_files = len(files)

        if self.output_dir:
            Path(self.output_dir).mkdir(parents=True, exist_ok=True)

        for index, source in enumerate(files, start=1):
            # ALTERAÇÃO AQUI: Mantém o nome exato original (source.name ou source.stem + source.suffix)
            # Se quiser salvar estritamente com o mesmo nome e extensão original:
            if self.output_dir:
                output = Path(self.output_dir) / source.name
            else:
                # Cuidado: se converter na mesma pasta com o mesmo nome, vai sobrescrever o original.
                # Para evitar conflito direto caso a pasta seja a mesma, geramos um nome temporário ou usamos o mesmo se for desejado substituição.
                # Aqui definimos com o nome original exato:
                output = source.with_name(source.name)

            self.events.put(("file", index, total_files, source.name))
            general_percent = int(((index - 1) / total_files) * 100)
            self.events.put(("total_progress", general_percent))

            # Se for a mesma pasta e o arquivo de saída for igual ao de origem, o ffmpeg pode dar erro de conflito se ler e escrever no mesmo arquivo ao mesmo tempo.
            # Por isso, caso estejam na mesma pasta, geramos num arquivo temporário e depois substituímos, ou tratamos.
            temp_output = output.with_suffix(output.suffix + ".tmp.mp4") if source.resolve() == output.resolve() else output

            duration = self._get_duration(source, ffprobe_exe)
            command = [
                ffmpeg_exe, "-hide_banner", "-y", "-i", str(source),
                "-map", "0:v:0", "-map", "0:a?",
                "-map_metadata", "0",
                "-c:v", "libx264", "-preset", "medium", "-crf", crf,
                "-pix_fmt", "yuv420p",
                "-c:a", "copy",
                "-movflags", "+faststart",
                "-progress", "pipe:1", "-nostats",
                str(temp_output)
            ]
            self.events.put(("log", f"Processando: {source.name}"))
            try:
                process = subprocess.Popen(
                    command, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                    text=True, encoding="utf-8", errors="replace", bufsize=1
                )
                stderr_lines = []
                stderr_thread = threading.Thread(
                    target=self._drain_stderr, args=(process.stderr, stderr_lines), daemon=True
                )
                stderr_thread.start()
                last_percent = -1
                if process.stdout:
                    for line in process.stdout:
                        line = line.strip()
                        if line.startswith("out_time_us=") or line.startswith("out_time_ms="):
                            try:
                                elapsed = int(line.split("=", 1)[1]) / 1_000_000
                                if duration > 0:
                                    percent = min(99, max(0, int(elapsed / duration * 100)))
                                    if percent != last_percent:
                                        last_percent = percent
                                        self.events.put(("file_progress", percent, f"{source.name} — {percent}%"))
                            except ValueError:
                                pass
                        elif line == "progress=end":
                            self.events.put(("file_progress", 100, f"Finalizando {source.name}..."))
                process.wait()
                stderr_thread.join(timeout=2)
                stderr = "".join(stderr_lines)
                
                if process.returncode == 0 and temp_output.exists() and temp_output.stat().st_size > 0:
                    if temp_output != output:
                        if output.exists():
                            output.unlink()
                        temp_output.rename(output)
                    
                    succeeded += 1
                    self.events.put(("log", f"Sucesso: {output.name}"))
                    self.events.put(("file_progress", 100, f"Concluído: {source.name}"))
                else:
                    failed += 1
                    self.events.put(("log", f"Erro em: {source.name}"))
                    if stderr:
                        self.events.put(("log", stderr[-800:].strip()))
                    if temp_output.exists() and temp_output.stat().st_size == 0:
                        try:
                            temp_output.unlink()
                        except OSError:
                            pass
            except Exception as exc:
                failed += 1
                self.events.put(("log", f"Falha {source.name}: {exc}"))

        self.events.put(("total_progress", 100))
        self.events.put(("done", succeeded, failed, skipped, total_files))

    @staticmethod
    def _drain_stderr(stream, lines):
        try:
            if stream:
                for line in stream:
                    lines.append(line)
        except (OSError, ValueError):
            pass

    def _process_events(self):
        try:
            while True:
                event = self.events.get_nowait()
                kind = event[0]
                if kind == "log":
                    self.add_log(event[1])
                elif kind == "file":
                    _, index, total, filename = event
                    self.progress.configure(value=0, maximum=100)
                    self.status_var.set(f"[{index}/{total}]")
                    self.count_var.set(filename)
                elif kind == "file_progress":
                    _, percent, description = event
                    self.progress.configure(value=percent, maximum=100)
                    self.count_var.set(description)
                elif kind == "total_progress":
                    _, percent = event
                    self.total_progress.configure(value=percent, maximum=100)
                elif kind == "done":
                    _, succeeded, failed, skipped, total = event
                    self.running = False
                    self.progress.configure(value=100, maximum=100)
                    self.total_progress.configure(value=100, maximum=100)
                    self.status_var.set("Concluído")
                    self.count_var.set(f"Sucesso: {succeeded} | Falhas: {failed} | Ignorados: {skipped}")
                    self.add_log(f"--- Fim: {succeeded} convertidos, {failed} falhas, {skipped} ignorados ---")
                    messagebox.showinfo("Fim", f"Conversão finalizada!\nConvertidos: {succeeded}\nFalhas: {failed}\nIgnorados: {skipped}")
        except queue.Empty:
            pass
        self.root.after(100, self._process_events)


def main():
    root = tk.Tk()
    ConverterApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
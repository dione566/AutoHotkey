# =======================================================================
# --- Configurações Iniciais e APIs do Windows ---
# =======================================================================
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;

public class Win32 {
    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, UIntPtr dwExtraInfo);
    
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);
}
"@

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# --- Configurações do Alvo (Ajuste Aqui) ---
$TargetR = 255
$TargetG = 72
$TargetB = 229

$Variation    = 25     
$SearchRadius = 120    

# --- Configurações Anti-Tremedeira e Velocidade ---
$Sensibilidade = 0.65
$Deadzone      = 3
$MaxMovimento  = 20
$OffsetY       = 0

$AimbotActive  = $false

# Dimensões da tela
$Bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$MidX = [int]($Bounds.Width / 2)
$MidY = [int]($Bounds.Height / 2)

# Definição das teclas (F6 liga/desliga, F7 fecha)
$VK_F6        = 0x75 
$VK_F7        = 0x76 

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " [F6] ATIVAR/DESATIVAR | [F7] FECHAR SCRIPT" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "STATUS: AIMBOT OFF" -ForegroundColor Red

# Bitmap e Graphics reutilizáveis para performance
$Size = $SearchRadius * 2
$Bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
$Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
$ScreenSize = New-Object System.Drawing.Size($Size, $Size)

# =======================================================================
# --- Loop Principal ---
# =======================================================================
try {
    while ($true) {
        # Verificar Tecla F6 (Alternar entre Ativar e Desativar)
        if ([Win32]::GetAsyncKeyState($VK_F6) -band 0x8000) {
            $AimbotActive = -not $AimbotActive # Inverte o estado atual (True vira False, False vira True)
            Clear-Host
            
            if ($AimbotActive) {
                Write-Host "STATUS: AIMBOT ON" -ForegroundColor Green
            } else {
                Write-Host "STATUS: AIMBOT OFF" -ForegroundColor Red
            }
            
            # Pequena pausa para evitar múltiplos registros com um único clique rápido
            [System.Threading.Thread]::Sleep(200)
        }

        # Verificar Tecla F7 (Sair)
        if ([Win32]::GetAsyncKeyState($VK_F7) -band 0x8000) {
            break
        }

        if ($AimbotActive) {
            # Define a área de captura
            $X1 = $MidX - $SearchRadius
            $Y1 = $MidY - $SearchRadius

            # Tira o print da área
            $Graphics.CopyFromScreen($X1, $Y1, 0, 0, $ScreenSize)

            $FoundX = -1
            $FoundY = -1
            $TargetFound = $false

            # Varredura dos pixels
            for ($x = 0; $x -lt $Size; $x += 2) { 
                for ($y = 0; $y -lt $Size; $y += 2) {
                    $PixelColor = $Bitmap.GetPixel($x, $y)

                    if ([Math]::Abs($PixelColor.R - $TargetR) -le $Variation -and
                        [Math]::Abs($PixelColor.G - $TargetG) -le $Variation -and
                        [Math]::Abs($PixelColor.B - $TargetB) -le $Variation) {
                        
                        $FoundX = $X1 + $x
                        $FoundY = $Y1 + $y
                        $TargetFound = $true
                        break
                    }
                }
                if ($TargetFound) { break }
            }

            if ($TargetFound) {
                $DistX = $FoundX - $MidX
                $DistY = ($FoundY + $OffsetY) - $MidY

                if ([Math]::Abs($DistX) -gt $Deadzone -or [Math]::Abs($DistY) -gt $Deadzone) {
                    
                    $TargetX = [int]($DistX * $Sensibilidade)
                    $TargetY = [int]($DistY * $Sensibilidade)

                    if ($TargetX -gt $MaxMovimento) { $TargetX = $MaxMovimento }
                    if ($TargetX -lt -$MaxMovimento) { $TargetX = -$MaxMovimento }
                    if ($TargetY -gt $MaxMovimento) { $TargetY = $MaxMovimento }
                    if ($TargetY -lt -$MaxMovimento) { $TargetY = -$MaxMovimento }

                    # Move o mouse relativo
                    [Win32]::mouse_event(0x0001, $TargetX, $TargetY, 0, [UIntPtr]::Zero)
                }
            }
        }
        
        [System.Threading.Thread]::Sleep(1)
    }
}
finally {
    $Graphics.Dispose()
    $Bitmap.Dispose()
    Write-Host "Script encerrado." -ForegroundColor Yellow
}
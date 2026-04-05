#Requires AutoHotkey v2.0
#SingleInstance Force

; --- CONFIGURAÇÃO ---
ConsoleKey := "'" ; Certifique-se que esta é a tecla no seu jogo (ex: ' ou ")
SetKeyDelay(50, 50) ; Melhora a digitação dentro de jogos

; --- CRIAÇÃO DA INTERFACE ---
L4D2Menu := Gui("+AlwaysOnTop", "L4D2 Ultimate Control")
L4D2Menu.SetFont("s9 w600", "Segoe UI")
L4D2Menu.BackColor := "1a1a1a"

Tabs := L4D2Menu.Add("Tab3", "cWhite w420 h580", ["Geral", "Armas", "Itens/Melee", "Zombies", "Mundo/Bot"])
L4D2Menu.SetFont("s9 w400", "Segoe UI")

; --- ABA 1: GERAL E STATUS ---
Tabs.UseTab(1)
AddBtn("ATIVAR SV_CHEATS 1", "sv_cheats 1", "w380 cGreen")
L4D2Menu.Add("Text", "cWhite", "--- Sobrevivência ---")
AddBtn("God Mode (ON)", "god 1", "w185 Section")
AddBtn("God Mode (OFF)", "god 0", "w185 x+10")
AddBtn("Buddha Mode", "buddha 1", "w185 xs")
AddBtn("NoClip (Voar)", "noclip", "w185 x+10")
AddBtn("Munição Infinita", "sv_infinite_ammo 1", "w185 xs")
AddBtn("Cura Total", "give health", "w185 x+10")
AddBtn("Repor Munição", "give ammo", "w185 xs")
L4D2Menu.Add("Text", "cWhite xs", "--- Câmera ---")
AddBtn("3ª Pessoa", "thirdperson", "w120 Section")
AddBtn("Ombro", "thirdpersonshoulder", "w120 x+5")
AddBtn("1ª Pessoa", "firstperson", "w120 x+5")
AddBtn("Morte/Suicídio", "kill", "w380 xs cRed")

; --- ABA 2: ARMAS ---
Tabs.UseTab(2)
AddBtn("AK-47", "give rifle_ak47", "w120 Section")
AddBtn("M16", "give rifle", "w120 x+5")
AddBtn("SCAR", "give rifle_desert", "w120 x+5")
AddBtn("Auto Shotgun", "give autoshotgun", "xs w120")
AddBtn("SPAS Shotgun", "give shotgun_spas", "x+5 w120")
AddBtn("Chrome Shot", "give shotgun_chrome", "x+5 w120")
AddBtn("Sniper Military", "give sniper_military", "xs w120")
AddBtn("Hunting Rifle", "give hunting_rifle", "x+5 w120")
AddBtn("Grenade Launcher", "give weapon_grenade_launcher", "x+5 w120")
AddBtn("Magnum", "give pistol_magnum", "xs w120")
AddBtn("Dual Pistols", "give pistol", "x+5 w120")
AddBtn("Impulse 101", "impulse 101", "x+5 w120")
L4D2Menu.Add("Text", "cWhite xs", "--- Upgrades ---")
AddBtn("Mira Laser", "upgrade_add laser_sight", "w120 Section")
AddBtn("Incendiária", "upgrade_add incendiary_ammo", "w120 x+5")
AddBtn("Explosiva", "upgrade_add explosive_ammo", "w120 x+5")

; --- ABA 3: MELEE E ITENS ---
Tabs.UseTab(3)
AddBtn("Katana", "give katana", "w120 Section")
AddBtn("Machete", "give machete", "w120 x+5")
AddBtn("Chainsaw", "give chainsaw", "w120 x+5")
AddBtn("Guitarra", "give electric_guitar", "xs w120")
AddBtn("Fritadeira", "give frying_pan", "x+5 w120")
AddBtn("Tonfa", "give tonfa", "x+5 w120")
L4D2Menu.Add("Text", "cWhite xs", "--- Equipamentos ---")
AddBtn("Medkit", "give first_aid_kit", "w120 Section")
AddBtn("Defibrilador", "give defibrilator", "w120 x+5")
AddBtn("Adrenalina", "give adrenaline", "w120 x+5")
AddBtn("Pills", "give pain_pills", "xs w120")
AddBtn("Molotov", "give molotov", "x+5 w120")
AddBtn("Pipe Bomb", "give pipe_bomb", "x+5 w120")
AddBtn("Bile Jar", "give vomitjar", "xs w120")
AddBtn("Gas Can", "give gascan", "x+5 w120")
AddBtn("Propane Tank", "give propanetank", "x+5 w120")

; --- ABA 4: ZOMBIES ---
Tabs.UseTab(4)
AddBtn("Spawn TANK", "z_spawn tank", "w185 Section")
AddBtn("Spawn WITCH", "z_spawn witch", "w185 x+10")
AddBtn("Spawn HUNTER", "z_spawn hunter", "w120 xs")
AddBtn("Spawn BOOMER", "z_spawn boomer", "x+5 w120")
AddBtn("Spawn SMOKER", "z_spawn smoker", "x+5 w120")
AddBtn("Spawn JOCKEY", "z_spawn jockey", "xs w120")
AddBtn("Spawn CHARGER", "z_spawn charger", "x+5 w120")
AddBtn("Spawn SPITTER", "z_spawn spitter", "x+5 w120")
AddBtn("Spawn Horda (Mob)", "z_spawn mob", "xs w380")
L4D2Menu.Add("Text", "cWhite xs", "--- Atributos ---")
AddBtn("Z Speed (250)", "z_speed 250", "w185 Section")
AddBtn("Z Health (50)", "z_health 50", "w185 x+10")

; --- ABA 5: MUNDO E BOTS ---
Tabs.UseTab(5)
AddBtn("Remover Bots", "Ent_Remove", "w380")
AddBtn("Parar Diretor", "director_stop", "w185 Section")
AddBtn("Forçar Pânico", "director_force_panic", "w185 x+10")
AddBtn("Friendly Fire OFF", "sb_friendlyfire 0", "w185 xs")
AddBtn("Bots Open Fire", "sb_openfire 1", "w185 x+10")
AddBtn("No Mobs (Toggle)", "director_no_mobs 1", "w185 xs")
AddBtn("Quit Game", "quit", "w380 cRed")

; --- FUNÇÕES ---

AddBtn(Name, Cmd, Options := "") {
    L4D2Menu.Add("Button", Options, Name).OnEvent("Click", (*) => EnviarComando(Cmd))
}

EnviarComando(Comando) {
    if WinExist("ahk_exe left4dead2.exe") {
        WinActivate("ahk_exe left4dead2.exe")
        if !WinWaitActive("ahk_exe left4dead2.exe", , 2)
            return

        ; Bloqueia entrada do usuário para não bugar a digitação
        BlockInput(true)
        
        ; Tenta abrir o console
        Send("{" ConsoleKey "}")
        Sleep(250) ; Espera o console descer
        
        ; Limpa e digita
        Send("^a{Backspace}")
        Sleep(50)
        SendText(Comando)
        Sleep(50)
        Send("{Enter}")
        Sleep(100)
        
        ; Fecha o console
        Send("{" ConsoleKey "}")
        
        BlockInput(false)
        
        ; Esconde o menu para você voltar ao jogo
        L4D2Menu.Hide()
        global MenuVisivel := false
    } else {
        MsgBox("O jogo Left 4 Dead 2 não está aberto.")
    }
}

; --- ATALHOS (HOTKEYS) ---

global MenuVisivel := false

$Tab::
{
    global MenuVisivel
    if (MenuVisivel) {
        L4D2Menu.Hide()
        MenuVisivel := false
        if WinExist("ahk_exe left4dead2.exe")
            WinActivate("ahk_exe left4dead2.exe")
    } else {
        L4D2Menu.Show() 
        Tabs.Focus()
        MenuVisivel := true
    }
}

F7::ExitApp

F12::
{
    if WinExist("ahk_exe left4dead2.exe")
        WinMinimize("ahk_exe left4dead2.exe")
}
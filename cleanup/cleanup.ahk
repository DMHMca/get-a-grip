#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
CoordMode("ToolTip", "Screen")

; ChatRite: fixes speech-to-text mistakes (whole/hole, Kodak's/Codex ...) in the text box you are in.
; Press Ctrl+Shift+Space. It uses a language model running on THIS PC (Ollama). Nothing leaves the PC.
; This file is kept up to date automatically from https://dmhmca.github.io/get-a-grip/cleanup/
VERSION := 6

UpdateUrl := "https://dmhmca.github.io/get-a-grip/cleanup/"
InstallDir := EnvGet("LOCALAPPDATA") "\ChatRite"
DataDir := EnvGet("APPDATA") "\ChatRite"
IniFile := DataDir "\settings.ini"
VocabFile := DataDir "\vocabulary.txt"
LogFile := DataDir "\tidy-log.txt"
OllamaUrl := "http://127.0.0.1:11434"

; First run from Downloads (or anywhere else): copy to the permanent folder and start from there.
if (A_ScriptDir != InstallDir) {
    DirCreate(InstallDir)
    FileCopy(A_ScriptFullPath, InstallDir "\cleanup.ahk", true)
    Run('"' A_AhkPath '" "' InstallDir '\cleanup.ahk"')
    ExitApp()
}
DirCreate(DataDir)

Cfg := {Model: IniRead(IniFile, "Tidy", "Model", "qwen2.5:7b"), Busy: false, LastOriginal: ""}

if !FileExist(VocabFile) {
    FileAppend("; Your words and names, one per line. Lines starting with a semicolon are ignored.`n"
        . "; To tell it what the recogniser often gets wrong, write:  heard => meant`n"
        . "Codex`nChrome`nClaude`nChatGPT`n"
        . "Kodak's => Codex`ncrime => Chrome`n", VocabFile, "UTF-8")
}

SetupTray()
if (IniRead(IniFile, "Tidy", "Installed", "") = "") {
    IniWrite("1", IniFile, "Tidy", "Installed")
    SetStartup(true)
    Msg("ChatRite is running. Press Ctrl+Shift+Space in any text box.", 6000)
}
SetTimer(StartUp, -400)
SetTimer(AutoUpdate, 6 * 3600 * 1000)

$^+Space:: Tidy()

; ---------------------------------------------------------------- the main job
Tidy() {
    if Cfg.Busy
        return
    Cfg.Busy := true
    try
        TidyCore()
    catch as e
        Msg("Tidy stopped: " e.Message, 5000)
    Cfg.Busy := false
}

TidyCore() {
    KeyWait("Space")
    KeyWait("Shift")
    KeyWait("Control")
    saved := ClipboardAll()
    t0 := A_TickCount
    usedAll := false
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(0.5) {
        usedAll := true
        Send("^a")
        Sleep(80)
        A_Clipboard := ""
        Send("^c")
        if !ClipWait(0.8) {
            A_Clipboard := saved
            Msg("Nothing to tidy. Click in a text box with some text first.", 3000)
            return
        }
    }
    orig := A_Clipboard
    if (StrLen(orig) > 6000) {
        A_Clipboard := saved
        Msg("That is a lot of text. Select just the part you want tidied, then press again.", 4500)
        return
    }
    Cfg.LastOriginal := orig
    Msg("Tidying...", 30000)
    hadCRLF := InStr(orig, "`r`n") > 0
    text := StrReplace(orig, "`r`n", "`n")
    fixes := AskModel(text)
    newText := ApplyFixes(text, fixes, &applied, &skipped)
    secs := Round((A_TickCount - t0) / 1000, 1)
    if (applied = 0) {
        A_Clipboard := saved
        if usedAll
            Send("{Right}")
        Msg("Nothing to fix (" secs " s)", 2500)
        WriteLog(secs, 0, skipped, text)
        return
    }
    out := hadCRLF ? StrReplace(newText, "`n", "`r`n") : newText
    A_Clipboard := out
    if !ClipWait(1) {
        A_Clipboard := saved
        throw Error("could not use the clipboard")
    }
    Send("^v")
    Sleep(300)
    A_Clipboard := saved
    word := (applied = 1) ? " fix" : " fixes"
    note := (skipped > 0) ? ", " skipped " skipped" : ""
    Msg("Tidied: " applied word " in " secs " s" note ". Ctrl+Z undoes it.", 3500)
    WriteLog(secs, applied, skipped, text)
}

; ---------------------------------------------------------------- the model
AskModel(text) {
    body := '{"model":' JStr(Cfg.Model) ',"stream":false,"keep_alive":"24h",'
        . '"options":{"temperature":0,"num_ctx":4096,"num_predict":400},'
        . '"format":{"type":"object","properties":{"fixes":{"type":"array","items":{"type":"object","properties":{"wrong":{"type":"string"},"right":{"type":"string"}},"required":["wrong","right"]}}},"required":["fixes"]},'
        . '"messages":[{"role":"system","content":' JStr(BuildPrompt()) '},{"role":"user","content":' JStr(text) '}]}'
    tmpIn := A_Temp "\chatrite-in.json"
    tmpOut := A_Temp "\chatrite-out.json"
    try FileDelete(tmpOut)
    f := FileOpen(tmpIn, "w", "UTF-8-RAW")
    f.Write(body)
    f.Close()
    errFile := A_Temp "\chatrite-err.txt"
    try FileDelete(errFile)
    cmd := A_ComSpec ' /c curl.exe -s -S --max-time 60 -H "Content-Type: application/json" --data-binary "@' tmpIn '" -o "' tmpOut '" ' OllamaUrl '/api/chat 2>"' errFile '"'
    code := RunWait(cmd, , "Hide")
    if (code != 0 || !FileExist(tmpOut)) {
        why := FileExist(errFile) ? Trim(FileRead(errFile)) : ""
        throw Error("could not reach Ollama (code " code "). " SubStr(why, 1, 200) "`n`nIs Ollama running? Open it from the Start menu (type Ollama), then try again.")
    }
    resp := FileRead(tmpOut, "UTF-8")
    if RegExMatch(resp, '"error"\s*:\s*"((?:[^"\\]|\\.)*)"', &em)
        throw Error(JUnesc(em[1]))
    if !RegExMatch(resp, '"content"\s*:\s*"((?:[^"\\]|\\.)*)"', &m)
        throw Error("no answer from the model")
    inner := JUnesc(m[1])
    fixes := []
    pos := 1
    while RegExMatch(inner, '"wrong"\s*:\s*"((?:[^"\\]|\\.)*)"\s*,\s*"right"\s*:\s*"((?:[^"\\]|\\.)*)"', &m2, pos) {
        fixes.Push([JUnesc(m2[1]), JUnesc(m2[2])])
        pos := m2.Pos + m2.Len
    }
    return fixes
}

BuildPrompt() {
    lines := []
    lines.Push("You fix mistakes made by a speech recogniser in text dictated by a British English speaker. You are given the text.")
    lines.Push('Reply ONLY with JSON like {"fixes":[{"wrong":"...","right":"..."}]}.')
    lines.Push("")
    lines.Push("Fix only real recognition errors: words that sound alike but do not fit the meaning (whole/hole, their/there/they're, to/too, and so on), mis-heard names and technical terms, wrong capital letters in the middle of a sentence, an accidentally repeated or doubled word, and clearly wrong punctuation. Work out what the speaker meant from the whole text.")
    lines.Push("Never rephrase, reword, improve the style, change the meaning, or change words that are correct. Keep British spelling. If a word is right in context, leave it alone even if it sounds like another word.")
    lines.Push("'wrong' must be copied exactly from the text. Include a neighbouring word or two only when needed to make it unique. 'right' is what replaces it. If nothing needs fixing reply {" '"fixes":[]' "}.")
    lines.Push("")
    lines.Push("Examples:")
    lines.Push("Text: Open Kodak's in crime and read the hole thing again.")
    lines.Push('{"fixes":[{"wrong":"Kodak' "'" 's in crime","right":"Codex in Chrome"},{"wrong":"the hole thing","right":"the whole thing"}]}')
    lines.Push("Text: We dug a hole in the ground, then I read the whole document twice.")
    lines.Push('{"fixes":[]}')
    lines.Push("Text: It was good, but are the longer ones are likely to be much Fuller with errors.")
    lines.Push('{"fixes":[{"wrong":"but are the longer ones are","right":"but the longer ones are"},{"wrong":"much Fuller","right":"much fuller"}]}')
    names := []
    heard := []
    try {
        for line in StrSplit(FileRead(VocabFile, "UTF-8"), "`n", "`r") {
            line := Trim(line)
            if (line = "" || SubStr(line, 1, 1) = ";" || SubStr(line, 1, 1) = "#")
                continue
            if InStr(line, "=>") {
                parts := StrSplit(line, ["=>"], " `t")
                if (parts.Length = 2 && parts[1] != "" && parts[2] != "")
                    heard.Push('the recogniser often writes "' parts[1] '" when the speaker said "' parts[2] '"')
            } else
                names.Push(line)
        }
    }
    if (names.Length > 0)
        lines.Push("`nThe speaker's own words and names (use exactly this spelling): " Join(names, ", ") ".")
    if (heard.Length > 0)
        lines.Push("Known mix-ups, to fix only where they make sense in the sentence: " Join(heard, "; ") ".")
    return Join(lines, "`n")
}

ApplyFixes(text, fixes, &applied, &skipped) {
    applied := 0
    skipped := 0
    cur := text
    for f in fixes {
        wrong := f[1]
        right := f[2]
        if (wrong = "" || wrong == right || StrLen(right) > 3 * StrLen(wrong) + 30) {
            skipped += 1
            continue
        }
        p := InStr(cur, wrong, true)
        if !p
            p := InStr(cur, wrong, false)
        if !p {
            skipped += 1
            continue
        }
        cur := SubStr(cur, 1, p - 1) . right . SubStr(cur, p + StrLen(wrong))
        applied += 1
    }
    if (applied > 0 && Abs(StrLen(cur) - StrLen(text)) > StrLen(text) * 0.4) {
        skipped += applied
        applied := 0
        return text
    }
    return cur
}

; ---------------------------------------------------------------- small helpers
Join(arr, sep) {
    out := ""
    for i, v in arr
        out .= (i = 1 ? "" : sep) v
    return out
}

JStr(s) {
    s := RegExReplace(s, "[\x00-\x08\x0B\x0C\x0E-\x1F]", "")
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, '"', '\"')
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`r", "\r")
    s := StrReplace(s, "`t", "\t")
    return '"' s '"'
}

JUnesc(s) {
    out := ""
    i := 1
    n := StrLen(s)
    while (i <= n) {
        c := SubStr(s, i, 1)
        if (c = "\" && i < n) {
            d := SubStr(s, i + 1, 1)
            switch d {
                case "n": out .= "`n"
                case "r": out .= "`r"
                case "t": out .= "`t"
                case "u":
                    out .= Chr("0x" SubStr(s, i + 2, 4))
                    i += 4
                default: out .= d
            }
            i += 2
        } else {
            out .= c
            i += 1
        }
    }
    return out
}

Msg(text, ms := 2500) {
    ToolTip(text, A_ScreenWidth // 2 - 200, A_ScreenHeight - 150)
    SetTimer(ClearTip, -ms)
}
ClearTip() {
    ToolTip()
}

WriteLog(secs, applied, skipped, text) {
    words := StrSplit(Trim(text), " ").Length
    try FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") " | " secs " s | " applied " fixes | " skipped " skipped | " words " words | " Cfg.Model "`n", LogFile, "UTF-8")
}

Fetch(url) {
    tmp := A_Temp "\chatrite-fetch.txt"
    try FileDelete(tmp)
    code := RunWait('curl.exe -s --max-time 20 -o "' tmp '" "' url '"', , "Hide")
    if (code != 0 || !FileExist(tmp))
        return ""
    return FileRead(tmp, "UTF-8")
}

; ---------------------------------------------------------------- tray menu
SetupTray() {
    global VERSION
    A_IconTip := "ChatRite (Ctrl+Shift+Space)"
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Version " VERSION, (*) => 0)
    A_TrayMenu.Disable("Version " VERSION)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Try it on a sample sentence", (*) => SampleTest())
    A_TrayMenu.Add("Edit my words and names", (*) => Run('notepad.exe "' VocabFile '"'))
    A_TrayMenu.Add("Copy the last original text back", (*) => CopyOriginal())
    A_TrayMenu.Add("Change the model...", (*) => ChangeModel())
    A_TrayMenu.Add("Check for updates now", (*) => CheckUpdate(true))
    A_TrayMenu.Add("Open the log folder", (*) => Run('explorer.exe "' DataDir '"'))
    A_TrayMenu.Add("Start with Windows", ToggleStartup)
    if FileExist(A_Startup "\ChatRite.lnk")
        A_TrayMenu.Check("Start with Windows")
    A_TrayMenu.Add()
    A_TrayMenu.Add("Exit", (*) => ExitApp())
}

SetStartup(on) {
    lnk := A_Startup "\ChatRite.lnk"
    if on
        FileCreateShortcut(A_AhkPath, lnk, InstallDir, '"' InstallDir '\cleanup.ahk"')
    else
        try FileDelete(lnk)
}

ToggleStartup(name, *) {
    on := !FileExist(A_Startup "\ChatRite.lnk")
    SetStartup(on)
    if on
        A_TrayMenu.Check(name)
    else
        A_TrayMenu.Uncheck(name)
}

CopyOriginal() {
    if (Cfg.LastOriginal = "") {
        Msg("Nothing saved yet.", 2000)
        return
    }
    A_Clipboard := Cfg.LastOriginal
    Msg("The original text is on the clipboard. Press Ctrl+V to paste it.", 3500)
}

ChangeModel() {
    r := InputBox("Model name for Ollama.`n`nqwen2.5:7b is quick. qwen2.5:14b is cleverer and a bit slower, and fits your graphics card.", "Change the model", "w420 h200", Cfg.Model)
    if (r.Result != "OK" || Trim(r.Value) = "")
        return
    Cfg.Model := Trim(r.Value)
    IniWrite(Cfg.Model, IniFile, "Tidy", "Model")
    if EnsureModel()
        Warm()
}

SampleTest() {
    global VERSION
    if Cfg.Busy
        return
    Cfg.Busy := true
    win := Gui("+AlwaysOnTop", "ChatRite: checking everything")
    win.SetFont("s11", "Segoe UI")
    ed := win.Add("Edit", "w640 h400 ReadOnly -Wrap +VScroll")
    win.Add("Button", "w120", "Close").OnEvent("Click", (*) => win.Destroy())
    win.OnEvent("Close", (*) => win.Destroy())
    win.Show()
    Say := (t) => SayTo(ed, t)
    try {
        sample := "Yesterday I opened Kodak's in crime and read the hole thing again. We dug a hole in the ground, then I read the whole document twice. Their going to send it to us tomorrow, and the new version is likely to be much Fuller of errors."
        Say("ChatRite version " VERSION ". Model chosen: " Cfg.Model)
        Say("")
        Say("1. Looking for Ollama at " OllamaUrl " ...")
        t0 := A_TickCount
        tags := Fetch(OllamaUrl "/api/tags")
        if (tags = "")
            throw Error("Ollama did not answer. Open Ollama from the Start menu (type Ollama), wait for the llama icon by the clock, then run this check again.")
        names := ""
        pos := 1
        while RegExMatch(tags, '"name":"([^"]*)"', &nm, pos) {
            names .= (names = "" ? "" : ", ") nm[1]
            pos := nm.Pos + nm.Len
        }
        shown := (names = "") ? "none" : names
        Say("   Ollama answered. Models on this PC: " shown)
        if !InStr(names, Cfg.Model)
            throw Error("The model " Cfg.Model " is not on this PC. Close this window, right-click the ChatRite icon, choose 'Change the model...' and press OK to download it.")
        Say("2. The model " Cfg.Model " is installed.")
        Say("3. First request. This can take up to a minute while the model loads into the graphics card ...")
        t1 := A_TickCount
        f1 := AskModel(sample)
        s1 := Round((A_TickCount - t1) / 1000, 1)
        Say("   done in " s1 " seconds")
        Say("4. Second request ...")
        t2 := A_TickCount
        f2 := AskModel(sample)
        s2 := Round((A_TickCount - t2) / 1000, 1)
        Say("   done in " s2 " seconds")
        out := ApplyFixes(sample, f2, &applied, &skipped)
        Say("")
        Say("Fixes applied: " applied ", skipped: " skipped)
        Say("")
        Say("BEFORE: " sample)
        Say("")
        Say("AFTER:  " out)
        Say("")
        if (s2 <= 2)
            Say("RESULT: fast enough. The second request took " s2 " seconds, under the 2 second target.")
        else
            Say("RESULT: the second request took " s2 " seconds, slower than the 2 second target. Is the laptop plugged in? Tell David's assistant this number.")
    } catch as e {
        Say("")
        Say("STOPPED: " e.Message)
    }
    Cfg.Busy := false
}

SayTo(ed, t) {
    try {
        ed.Value .= t "`r`n"
        SendMessage(0x0115, 7, 0, ed)
    }
}

; ---------------------------------------------------------------- Ollama and model checks
StartUp() {
    if EnsureModel()
        Warm()
    SetTimer(() => AutoUpdate(), -4000)
}

EnsureModel() {
    tags := Fetch(OllamaUrl "/api/tags")
    if (tags = "") {
        r := MsgBox("Ollama does not seem to be running.`n`nIt is the free program that runs the language model on your PC. Install it (or start it from the Start menu), then right-click this program's icon by the clock and choose Exit, and start it again.`n`nOpen the Ollama download page now?", "ChatRite", 36)
        if (r = "Yes")
            Run("https://ollama.com/download/windows")
        return false
    }
    if InStr(tags, '"name":"' Cfg.Model) || InStr(tags, '"model":"' Cfg.Model)
        return true
    r := MsgBox("The language model " Cfg.Model " is not on this PC yet.`n`nDownload it now? It is a few gigabytes and takes a few minutes. A black window will show the progress. When it finishes, close the window.", "ChatRite", 36)
    if (r = "Yes") {
        exe := EnvGet("LOCALAPPDATA") "\Programs\Ollama\ollama.exe"
        if !FileExist(exe)
            exe := "ollama"
        Run(A_ComSpec ' /k "' exe '" pull ' Cfg.Model)
    }
    return false
}

Warm() {
    tmp := A_Temp "\chatrite-warm.json"
    try FileDelete(tmp)
    f := FileOpen(tmp, "w", "UTF-8-RAW")
    f.Write('{"model":' JStr(Cfg.Model) ',"keep_alive":"24h"}')
    f.Close()
    Run('curl.exe -s --max-time 120 -H "Content-Type: application/json" --data-binary "@' tmp '" -o nul ' OllamaUrl '/api/generate', , "Hide")
}

; ---------------------------------------------------------------- automatic updates
AutoUpdate() {
    if !Cfg.Busy
        CheckUpdate(false)
}

CheckUpdate(manual := false) {
    global VERSION
    raw := Fetch(UpdateUrl "version.txt?t=" A_Now)
    ver := RegExReplace(raw, "\D")
    if (ver = "") {
        if manual
            Msg("Could not check for updates just now. (Got: " SubStr(raw, 1, 40) ")", 5000)
        return
    }
    mine := RegExReplace(VERSION, "\D")
    if (mine = "")
        mine := "0"
    if (ver + 0 <= mine + 0) {
        if manual
            Msg("You have the newest version (" mine ").", 3000)
        return
    }
    newTxt := Fetch(UpdateUrl "cleanup.ahk?t=" A_Now)
    if (!RegExMatch(newTxt, "m)^VERSION := (\d+)\s*$", &mm) || mm[1] != ver || !InStr(newTxt, "; CHATRITE-END")) {
        if manual
            Msg("The update did not download properly. Nothing was changed.", 4000)
        return
    }
    tmp := A_Temp "\chatrite-new.ahk"
    try FileDelete(tmp)
    FileAppend(newTxt, tmp, "UTF-8-RAW")
    FileCopy(A_ScriptFullPath, InstallDir "\cleanup.previous.ahk", true)
    FileMove(tmp, A_ScriptFullPath, true)
    Msg("Updated to version " ver ". Restarting...", 3000)
    Sleep(800)
    Reload()
}
; CHATRITE-END

#Requires AutoHotkey v2.0
SetTitleMatchMode 2  

; ==========================================
; ⚙️ 使用者配置區 (Config Zone)
; ==========================================
; 預設使用系統環境變數自動抓取路徑，支援跨電腦隨插即用。
; 若你的軟體安裝在自訂路徑 (如 D:\Tools)，請直接將以下變數替換為絕對路徑。

ChromeAppDir := "C:\Users\qerpz\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\"
LocalProgDir := EnvGet("LOCALAPPDATA") "\Programs\" ; 透過 EnvGet 正確抓取 LocalAppData

; 增加 Program Files 的配置。利用 A_ProgramFiles 抓取 C:\Program Files
; 若引擎升級或裝在其他槽，請直接修改此處 (例如改為 "D:\Epic Games\UE_5.8\...")
UnrealEngineDir := A_ProgramFiles "\Epic Games\UE_5.7\Engine\Binaries\Win64\"

; ==========================================
; 核心函數：切換或啟動應用程式
; ==========================================
RunOrActivate(AppPath, WinTitle, ExcludeTitle := "") {
    if WinExist(WinTitle, "", ExcludeTitle) {
        WinActivate(WinTitle, "", ExcludeTitle) 
    } else {
        Run(AppPath)  
    }
}

; ==========================================
; 快捷鍵設定區 ( >! 代表右側 Alt 鍵 )
; ==========================================

; 右側 Alt + A = Ask Gemini
>!a::RunOrActivate(ChromeAppDir "Google Gemini.lnk", "Google Gemini ahk_exe chrome.exe")

; 右側 Alt + J = Google (排除 Gemini，避免標題誤判)
>!j::RunOrActivate(ChromeAppDir "Google.lnk", "Google ahk_exe chrome.exe", "Gemini")

; 右側 Alt + O = Obsidian
>!o::RunOrActivate(LocalProgDir "Obsidian\Obsidian.exe", "ahk_exe Obsidian.exe")

; 右側 Alt + C = Cursor
>!c::RunOrActivate(LocalProgDir "cursor\Cursor.exe", "ahk_exe Cursor.exe")

; 右側 Alt + M = Music
>!m::RunOrActivate(ChromeAppDir "YouTube Music.lnk", "YouTube Music ahk_exe chrome.exe")

; 右側 Alt + N = NotebookLM
>!n::RunOrActivate(ChromeAppDir "NotebookLM.lnk", "NotebookLM ahk_exe chrome.exe")

; 右側 Alt + Y = YouTube
>!y::RunOrActivate(ChromeAppDir "YouTube.lnk", "YouTube ahk_exe chrome.exe")

; 右側 Alt + G = Game Unreal Engine
>!g::RunOrActivate(UnrealEngineDir "UnrealEditor.exe", "ahk_exe UnrealEditor.exe")


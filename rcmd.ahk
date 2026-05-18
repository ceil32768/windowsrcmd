#Requires AutoHotkey v2.0
SetTitleMatchMode 2  

; ==========================================
; ⚙️ 使用者配置區 (Config Zone)
; ==========================================
; 預設使用系統環境變數自動抓取路徑，支援跨電腦隨插即用。
; 若你的軟體安裝在自訂路徑 (如 D:\Tools)，請直接將以下變數替換為絕對路徑。

ChromeAppDir := "C:\Users\qerpz\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Apps\"
if !DirExist(ChromeAppDir) {
    ; 如果英文資料夾不存在，就改用中文資料夾路徑
    ChromeAppDir := A_AppData "\Microsoft\Windows\Start Menu\Programs\Chrome 應用程式\"
}

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
; 核心功能：滑鼠瞬移 (可選擇是否點擊喚醒)
; ==========================================
CenterMouse(DoClick := false) {
    ; 將座標基準設定為「當前啟用的視窗」
    CoordMode "Mouse", "Window"
    
    ; 抓取當前視窗的寬度和高度
    WinGetPos(,, &Width, &Height, "A")
    
    if (Width > 0 && Height > 0) {
        ; 1. 瞬間移動滑鼠到視窗正中心
        MouseMove(Width/1.07, Height/2, 0)
        
        ; 2. 如果傳入的參數要求點擊 (DoClick 為 true)，才執行點擊
        if (DoClick) {
            Sleep(50) ; 給瀏覽器一點反應時間
            Click()
        }
    }
}



; ==========================================
; 快捷鍵設定區 ( >! 代表右側 Alt 鍵 )
; ==========================================

; 右側 Alt + A = Ask Gemini
>!a:: {
    TargetTitle := "Google Gemini ahk_exe chrome.exe"
    TargetApp := ChromeAppDir "Google Gemini.lnk"

    ; 情況一：如果連半個 Gemini 視窗都沒開，就直接執行啟動
    if !WinExist(TargetTitle) {
        Run(TargetApp)
    } 
    ; 情況二：如果「目前已經在」Gemini 視窗中，就強制啟用最底層的另一個，達成循環切換 (Cycle)
    else if WinActive(TargetTitle) {
        WinActivateBottom(TargetTitle)
    } 
    ; 情況三：如果在其他軟體（如 UE5 或 Obsidian），就先喚醒最近使用的那一個 Gemini
    else {
        WinActivate(TargetTitle)
    }
    
    ; 等待視窗確實成為 Active (最多等 2 秒，防止冷啟動卡頓)
    if WinWaitActive(TargetTitle,, 2) {
        ; 視窗準備好後，瞬移並點擊喚醒 DOM
        CenterMouse(true) 
    }
}


; 右側 Alt + J = Google (排除 Gemini，避免標題誤判)
>!j::RunOrActivate(ChromeAppDir "Google.lnk", "Google ahk_exe chrome.exe", "Gemini")

; 右側 Alt + O = Obsidian
>!o::RunOrActivate(LocalProgDir "Obsidian\Obsidian.exe", "ahk_exe Obsidian.exe")

; 右側 Alt + I = IDE
; >!i::RunOrActivate(LocalProgDir "cursor\Cursor.exe", "ahk_exe Cursor.exe")

>!i::RunOrActivate(LocalProgDir "antigravity\antigravity.exe", "ahk_exe antigravity.exe")

; 右側 Alt + M = Music
>!m::RunOrActivate(ChromeAppDir "YouTube Music.lnk", "YouTube Music ahk_exe chrome.exe")

; 右側 Alt + N = NotebookLM
>!n::RunOrActivate(ChromeAppDir "NotebookLM.lnk", "NotebookLM ahk_exe chrome.exe")

; 右側 Alt + Y = YouTube
>!y::RunOrActivate(ChromeAppDir "YouTube.lnk", "YouTube ahk_exe chrome.exe")

; 右側 Alt + G = Game Unreal Engine
>!g::RunOrActivate(UnrealEngineDir "UnrealEditor.exe", "ahk_exe UnrealEditor.exe")

; 右側 Alt + E = Windows File Explorer
>!e::RunOrActivate("explorer.exe", "ahk_class CabinetWClass")

; 右側 Alt + Q = Notion
>!q::RunOrActivate(LocalProgDir "Notion\Notion.exe", "ahk_exe Notion.exe")

; 右側 Alt + T = Git Bash
>!t::RunOrActivate("C:\Program Files\Git\git-bash.exe", "ahk_exe mintty.exe")

; ==========================================
; Notion 專用：Vim 導航層 (R-Alt + hjkl)
; ==========================================
#HotIf WinActive("ahk_exe Notion.exe")

; 基礎導航
>!h::Send "{Left}"
>!j::Send "{Down}"
>!k::Send "{Up}"
>!l::Send "{Right}"

; R-Alt + Space = 打勾 (取代 Ctrl + Enter)
>!Space::Send "^{Enter}"

; 額外加速：R-Alt + d = 刪除該行
>!d::Send "{Esc}{BackSpace}"

#HotIf


; key binding



; ==========================================
; 🍎 左側 Alt 模擬 Mac Command 鍵 (Left Alt)
; ==========================================

; <! 代表左側 Alt
<!c::Send "^{c}" ; Left Alt + C = 複製
<!v::Send "^{v}" ; Left Alt + V = 貼上
<!x::Send "^{x}" ; Left Alt + X = 剪下
<!z::Send "^{z}" ; Left Alt + Z = 復原
<!s::Send "^{s}" ; Left Alt + S = 存檔
<!a::Send "^{a}" ; Left Alt + A = 全選

; ==========================================
; 🛑 重要：防止單擊 Alt 觸發系統選單 (Alt Menu)
; ==========================================
; 在 Windows 中，單按一下 Alt 會讓焦點跳到頂部選單。
; 為了防止這種情況干擾你的編輯心流，我們攔截單純的左 Alt 釋放動作。
~LAlt::Send "{Blind}{vkE8}"

; Bluetooth
>!b::Run("ms-settings:bluetooth")



; =========================================
; 只在 Chrome 瀏覽器中生效的「Alt 宇宙」
; =========================================
#HotIf WinActive("ahk_exe chrome.exe")

; Alt+T (Cmd+T) -> new tab
!t::Send("^t")

; Alt+N (Cmd+N) -> new window
!n::Send("^n")

; Alt + w = close the window
!w::Send("^w")

; 結束限定範圍，後面的腳本會恢復全域生效
#HotIf





; ==========================================
; 全域改鍵：Caps Lock 變為 Esc
; ==========================================
*CapsLock::Send "{Blind}{Esc}"

; (選用) 如果你偶爾還是需要打全大寫，按 Shift + Caps Lock 就可以正常切換
+CapsLock::CapsLock














; ==========================================
; UE5 Vim 狀態機
; ==========================================


; ==========================================
; 全域變數宣告區
; ==========================================
global UEVimMode := false  ; 預設進入 UE 時是 Insert 模式

#HotIf WinActive("ahk_exe UnrealEditor.exe")

; Alt + h j k l = 觸發 BA 的 Ctrl + 方向鍵 (沿著節點連線跳躍/選取)
!h::Send("^{Left}")
!j::Send("^{Down}")
!k::Send("^{Up}")
!l::Send("^{Right}")

; ------------------------------------------
; 1. 模式切換觸發器
; ------------------------------------------
; 按下 Caps Lock + m ➔ 進入 Normal Mode
~CapsLock & m::
{
    global UEVimMode := true
    ToolTip("🔵 NORMAL", 50, 50)
    SetTimer(() => ToolTip(), -1000) ; 1秒後關閉提示
}

; 按下 capslock+i ➔ 進入 Insert Mode
~CapsLock & i::
{
    global UEVimMode
    if (UEVimMode) {
        UEVimMode := false
        ToolTip("🟢 INSERT", 50, 50)
        SetTimer(() => ToolTip(), -1000)
    } else {
        Send("{Blind}i") ; 如果已經在 Insert 模式，就正常打出 i
    }
}

; 自動進入 Insert Mode 的防呆機制
; 當按下 Tab (BA搜尋節點)、F2 (重新命名)、Enter 時，自動切回打字模式
~Tab::
~F2::
{
    global UEVimMode
    if (UEVimMode) {
        UEVimMode := false
        ToolTip("🟢 INSERT", 50, 50)
        SetTimer(() => ToolTip(), -1000)
    }
}

; ------------------------------------------
; 2. Normal Mode 的專屬按鍵映射 (只有在 UEVimMode = true 時生效)
; ------------------------------------------
#HotIf WinActive("ahk_exe UnrealEditor.exe") and UEVimMode

; 基礎：h j k l = 方向鍵 (在節點之間移動)
h::Send("{Left}")
j::Send("{Down}")
k::Send("{Up}")
l::Send("{Right}")

; u = 復原 (Undo)
u::Send("^{z}")

; d = 刪除
d::Send("{Delete}")

; 搭配 Shift 的 h j k l = Shift + 方向鍵
; (BA 裡面用來「物理上」移動節點的位置)
+h::Send("+{Left}")
+j::Send("+{Down}")
+k::Send("+{Up}")
+l::Send("+{Right}")



; ==========================================
; 🔍 畫面縮放 (自帶準星版)
; 觸發時，滑鼠自動飛到畫面正中心，然後執行縮放
; ==========================================

; Shift + < (縮小)
+,::
{
    CoordMode("Mouse", "Client")
    WinGetClientPos(,, &Width, &Height, "A")
    MouseMove(Width/2, Height/2, 0) ; 1. 瞬間移動到中心
    Send("{WheelDown 2}")           ; 2. 執行縮小
}

; Shift + > (放大)
+.::
{
    CoordMode("Mouse", "Client")
    WinGetClientPos(,, &Width, &Height, "A")
    MouseMove(Width/2, Height/2, 0) ; 1. 瞬間移動到中心
    Send("{WheelUp 2}")             ; 2. 執行放大
}

#HotIf
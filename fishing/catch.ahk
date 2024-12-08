; Fishing quick time event script for Thtone and Liberty
; https://github.com/Gaboar
; Version 1.1
;
; Requires Autohotkey https://autohotkey.com/
;
; Notes:
; This scrip is for 1080p borderless mode and lowest graphics settings
; if you are using different settings adjust your script accordingly

#Requires AutoHotkey v2.0
#SingleInstance
#MaxThreadsPerHotkey 2

#HotIf WinActive('ahk_exe TL.exe')

SendMode('Event')
CoordMode('Mouse', 'Screen')

fishHpBarX := 1116
fishHpBarYTop := 620
fishHpBarYBot := 721
fishHpColor := 0x925a2b

isFishing := false

Suspend()
TimedToolTip('Fishing script loaded`nPress F8 to enable/disable', 1600)

f:: {
	global
	Suspend(1)
	Send('{f down}')
	Sleep(150)
	Send('{f up}')
	Suspend(0)
	if (isFishing) {
		isFishing := false
		TimedToolTip('Stopped looking', 800)
	} else {
		isFishing := true
		TimedToolTip('Looking for fish', 800)
		checkForFish()
	}
}

q:: {
	global
	Suspend(1)
	Send('{q down}')
	Sleep(150)
	Send('{q up}')
	Suspend(0)
	isFishing := false
	TimedToolTip('Stopped looking', 800)
}

#SuspendExempt
F8:: {
	Suspend()
	if (A_IsSuspended) {
		TimedToolTip('Fishing script disabled', 1000)
	} else {
		TimedToolTip('Fishing script enabled', 1000)
	}
}
#SuspendExempt False

;; Fishing Actions, not triggered by key press, only used internally
checkForFish() {
	global
	local pX := 0
	local pY := 0
	while (isFishing) {
		local success := PixelSearch(&pX, &pY, fishHpBarX, fishHpBarYTop, fishHpBarX, fishHpBarYBot, fishHpColor, 20)
		if (success) {
			Sleep(150)
			Suspend(1)
			Send('{q down}')
			Sleep(150)
			Send('{q up}')
			Suspend(0)
			isFishing := false
			TimedToolTip('Catch!', 800)
		} else {
			sleep(15)
		}
	}
}

;; Some Utils
TimedToolTip(msg, dur) {
	ToolTip(msg)
	SetTimer(RemoveToolTip, dur)
}

RemoveToolTip() {
	SetTimer(RemoveToolTip, 0)
	ToolTip()
}
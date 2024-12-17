; Fishing quick time event script for Thtone and Liberty
; https://github.com/Gaboar
; Version 2.0
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

fishingRodX := 816
fishingRodY := 955

fishButtonX := 1190
fishButtonY := 630
fishButtonColor := 0x332b37

isFishing := false
fastReset := false

Suspend()
TimedToolTip('Fishing script loaded', 1600)


;; Keys
f:: {
	Cast()
}

Cast() {
	global
	Send('{f down}')
	Sleep(150)
	Send('{f up}')
	if (isFishing) {
		isFishing := false
		TimedToolTip('Stopped looking', 800)
	} else {
		isFishing := true
		TimedToolTip('Looking for fish', 800)
		CheckForFish()
	}
}

q:: {
	global
	Suspend(1)
	Send('{q down}')
	Sleep(150)
	Send('{q up}')
	isFishing := false
	TimedToolTip('Fishing script disabled', 1000)
}

#SuspendExempt true
^f:: {
	global
	Send('{ctrl down}')
	Send('{f down}')
	Sleep(150)
	Send('{f up}')
	Send('{ctrl up}')
	Suspend()
	isFishing := false
	if (A_IsSuspended) {
		TimedToolTip('Fishing script disabled', 1000)
	} else {
		TimedToolTip('Fishing script enabled', 1000)
	}
}
#SuspendExempt false

f6:: {
	global
	if (fastReset) {
		fastReset := false
		TimedToolTip('Fast reset disabled', 1000)
	} else {
		fastReset := true
		TimedToolTip('Fast reset enabled', 1000)
	}
}


;; Fishing Actions, not triggered by key press, only used internally
CheckForFish() {
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
			if (fastReset) {
				WaitForEnd()
				Reset()
			}
		} else {
			sleep(15)
		}
	}
}

WaitForEnd() {
	global
	Sleep(2000)
	local pX := 0
	local pY := 0
	local success := true
	while (success) {
		local success := PixelSearch(&pX, &pY, fishButtonX, fishButtonY, fishButtonX, fishButtonY, fishButtonColor, 20)
		Sleep(50)
	}
	TimedToolTip('Reset', 800)
}

Reset() {
	global
	Send('{alt down}')
	Sleep(150)
	Send('{alt up}')
	Sleep(30)
	MouseClick('L', fishingRodX, fishingRodY, 1, 0)
	Sleep(30)
	MouseClick('L', fishingRodX, fishingRodY, 1, 0)
	Sleep(30)
	Send('{alt down}')
	Sleep(150)
	Send('{alt up}')
	Sleep(800)
	Cast()
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
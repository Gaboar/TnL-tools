; Fishing quick time event script for Thtone and Liberty
; https://github.com/Gaboar
; Version 3.0
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
fishHpBarYTop := 600
fishHpBarYBot := 720
fishHpColor := 0x925a2b
fishHpIndicatorColor := 0xfbf6d4

staminaBarX := 1137
staminaBarY := 595
staminaColor := 0x56391b
staminaTopColor := 0xa5c57a

fishButtonX := 1190
fishButtonY := 630
fishButtonColor := 0x332b37

isFishing := false
fastReset := true ;false
autoPull := false

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

s:: {
	global
	if (isFishing) {
		TimedToolTip('Recast float', 800)
		Suspend(1)
		Send('{f down}')
		Sleep(150)
		Send('{f up}')
		Sleep(200)
		Send('{f down}')
		Sleep(150)
		Send('{f up}')
		Suspend(0)
	}
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

f7:: {
	global
	if (autoPull) {
		autoPull := false
		TimedToolTip('Autopull disabled', 1000)
	} else {
		autoPull := true
		TimedToolTip('Autopull enabled', 1000)
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
			TimedToolTip('Catch!', 800)
			Suspend(1)
			Send('{q down}')
			Sleep(150)
			Send('{q up}')
			Suspend(0)
			if (fastReset) {
				if (autoPull) {
					PullFish()
				} else {
					WaitForEnd()
				}
				Reset()
			}
			else {
				isFishing := false
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
}

;; Only works for low level fishes
PullFish() {
	global
	Sleep(100)
	local pX := 0
	local pY := 0
	local fishHp := fishHpBarYTop
	local pullLeft := true
	local pullingLeft := true
	local waiting := false
	Send('{a down}')
	local success := true
	while (success) {
		local success := PixelSearch(&pX, &pY, fishButtonX, fishButtonY, fishButtonX, fishButtonY, fishButtonColor, 20)
		if (waiting) {
			local s2 := PixelSearch(&pX, &pY, staminaBarX, staminaBarY, staminaBarX, staminaBarY+20, staminaTopColor, 50)
			if (s2) {
				waiting := false
			}
		} else {
			ToolTip(Round((1-(fishHp-fishHpBarYTop)/(fishHpBarYBot-fishHpBarYTop))*100) '%')
			local s3 := PixelSearch(&pX, &pY, fishHpBarX, fishHpBarYTop, fishHpBarX, fishHpBarYBot, fishHpIndicatorColor, 50)
			if (s3) {
				if (fishHp < pY) {
					fishHp := pY
				} else {
					pullLeft := !pullLeft
				}
			}
			if (pullLeft != pullingLeft) {
				if (pullLeft) {
					Send('{d up}')
					Sleep(10)
					Send('{a down}')
				} else {
					Send('{a up}')
					Sleep(10)
					Send('{d down}')
				}
				pullingLeft := pullLeft
			}
			local s1 := PixelSearch(&pX, &pY, staminaBarX, fishHp, staminaBarX, fishHp, staminaColor, 20)
			if (s1) {
				waiting := true
				if (pullingLeft) {
					Send('{a up}')
				} else {
					Send('{d up}')
				}
				ToolTip('Recharge')
			}
		}
		Sleep(150)
	}
	if (pullingLeft) {
		Send('{a up}')
	} else {
		Send('{d up}')
	}
}

;; Skips animation
Reset() {
	global
	if (not isFishing) {
		return
	}
	isFishing := false
	TimedToolTip('Reset', 800)
	Sleep(50)
	Suspend(1)
	Send('{ctrl down}')
	Sleep(100)
	Send('{f down}')
	Send('{f up}')
	Sleep(120)
	Send('{f down}')
	Send('{f up}')
	Sleep(100)
	Send('{ctrl up}')
	Suspend(0)
	Sleep(100)
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

;=========================================Ввод информации=========================================
enteringInfo:
	sbrs programFlags, 4
	ret
	call enteringInfoMenuSwitch
	cbr programFlags, 16
	ret

enteringInfoMenuSwitch:
	mov acc, menuModes
	andi acc, 0xf0
	lsr acc	
	lsr acc
	lsr acc
	lsr acc

	ldi ZH, high(enteringInfoMenuSwitchTable)
	ldi ZL, low(enteringInfoMenuSwitchTable)
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoMenuSwitchOverflow

enteringInfoMenuSwitchContinue:
	ijmp

enteringInfoMenuSwitchOverflow:
	inc r31
	jmp enteringInfoMenuSwitchContinue

enteringInfoMenuSwitchTable:
	call enteringInfoMenu1Switch
	ret
	call enteringInfoMenu2Switch
	ret
	;call enteringInfoMenu3Switch
	ret
	;call enteringInfoMenu4Switch
	ret
	;call enteringInfoMenu5Switch
	ret

enteringInfoMenu1Switch:
	mov acc, menuModes
	andi acc, 0x0f

	ldi ZH, high(enteringInfoMenu1SwitchTable)
	ldi ZL, low(enteringInfoMenu1SwitchTable)
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoMenu1SwitchOverflow

enteringInfoMenu1SwitchContinue:
	ijmp

enteringInfoMenu1SwitchOverflow:
	inc r31
	jmp enteringInfoMenu1SwitchContinue

enteringInfoMenu1SwitchTable:
	call enteringInfoSettingsTimeCursorPosSwitch
	ret
	;call enteringInfoSettingsOptionsCursorPosSwitch
	ret
	;call modeSettingsSetAvgSpending
	ret

enteringInfoWriteInKeyboardBuffer:
	lds acc, cursorCoords
	LDI YL, low(keyboardInputBuffer)
	LDI YH, high(keyboardInputBuffer)
	
	add YL, acc
	brcs enteringInfoWriteInKeyboardBufferOverflow
	jmp enteringInfoWriteInKeyboardBufferContinue
enteringInfoWriteInKeyboardBufferOverflow:
	inc r29
enteringInfoWriteInKeyboardBufferContinue:
	lds acc, pressedKey
	ST y, acc
	ret

enteringInfoClearKeyInputBuffer:
	ldi acc, 0xff
	ldi acc2, 0x11 
	LDI YL, low(keyboardInputBuffer)
	LDI YH, high(keyboardInputBuffer)
enteringInfoClearKeyInputBufferLoop:
	ST y, acc
	adiw y,1
	dec acc2
	cpi acc2, 0
	brne enteringInfoClearKeyInputBufferLoop

	ret

enteringInfoMenu2Switch:
	mov acc, menuModes
	andi acc, 0x0f

	ldi ZH, high(enteringInfoMenu2SwitchTable)
	ldi ZL, low(enteringInfoMenu2SwitchTable)
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoMenu2SwitchOverflow

enteringInfoMenu2SwitchContinue:
	ijmp

enteringInfoMenu2SwitchOverflow:
	inc r31
	jmp enteringInfoMenu2SwitchContinue

enteringInfoMenu2SwitchTable:
	call enteringInfoAutoHeatingScheduleCursorPosSwitch
	ret
	call enteringInfoAutoHeatingWorkingTimeCursorPosSwitch
	ret
	call enteringInfoAutoHeatingTempControlCursorPosSwitch
	ret
	call enteringInfoAutoHeatingOtherOptionsCursorPosSwitch
	ret

;=========================================/Ввод информации=========================================

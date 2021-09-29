;-----ввод информации-----;
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
	inc acc
	jmp enteringInfoMenuSwitchContinue

enteringInfoMenuSwitchTable:
	call enteringInfoMenu1Switch
	ret
	;call enteringInfoMenu2Switch
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
	inc acc
	jmp enteringInfoMenu1SwitchContinue

enteringInfoMenu1SwitchTable:
	call enteringInfoSettingsTimeCursorPosSwitch
	ret
	;call modeSettingsSetTankVolume
	ret
	;call modeSettingsSetAvgSpending
	ret


enteringInfoSettingsTimeCursorPosSwitch:
	;занести значение клавиши в буфер взависимости от курсора
	lds acc, pressedKey
	cpi acc, 0x0A
	brge enteringInfoSettingsTimeKeysLettersCalling

	lds acc, cursorCoords
	LDI YL, low(keyboardInputBuffer)
	LDI YH, high(keyboardInputBuffer)
	
	add YL, acc
	brcs enteringInfoSettingsTimeRow0SwitchkeyboardInputBufferEnteringOverflow
	jmp enteringInfoSettingsTimeRow0SwitchkeyboardInputBufferEnteringContinue
enteringInfoSettingsTimeRow0SwitchkeyboardInputBufferEnteringOverflow:
	inc acc
enteringInfoSettingsTimeRow0SwitchkeyboardInputBufferEnteringContinue:
	lds acc, pressedKey
	ST y, acc
	;в зависимости от положения курсора надо сдвинуть курсор
	lds acc, cursorCoords
	ldi ZH, high(enteringInfoSettingsTimeCursorPosSwitchTable)
	ldi ZL, low(enteringInfoSettingsTimeCursorPosSwitchTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoSettingsTimeCursorPosSwitchOverflow

enteringInfoSettingsTimeCursorPosSwitchContinue:
	ijmp

enteringInfoSettingsTimeKeysLettersCalling: call enteringInfoSettingsTimeKeysLetters
	ret

enteringInfoSettingsTimeCursorPosSwitchOverflow:
	inc acc
	jmp enteringInfoSettingsTimeCursorPosSwitchContinue

enteringInfoSettingsTimeCursorPosSwitchTable:
	call enteringInfoSettingsTimeCursorPos0
	ret
	call enteringInfoSettingsTimeCursorPos1
	ret
	call enteringInfoSettingsTimeCursorPos2
	ret
	call enteringInfoSettingsTimeCursorPos3
	ret
	call enteringInfoSettingsTimeCursorPos4
	ret
	call enteringInfoSettingsTimeCursorPos5
	ret
	call enteringInfoSettingsTimeCursorPos6
	ret

enteringInfoSettingsTimeCursorPos0:
	lds acc2, pressedKey	
	cpi acc2, 3
	brge enteringInfoSettingsTimeError
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	jmp enteringInfoSettingsTimeIncCursor	;сохранение нового значение курсора

enteringInfoSettingsTimeError:
	ret

enteringInfoSettingsTimeCursorPos1:
	LDS acc, keyboardInputBuffer
	cpi acc, 2
	breq enteringInfoSettingsTimeCursorPos1_2h
	jmp enteringInfoSettingsTimeCursorPos1_Continue
enteringInfoSettingsTimeCursorPos1_2h:
	lds acc, pressedKey
	cpi acc, 4
	brge enteringInfoSettingsTimeError
enteringInfoSettingsTimeCursorPos1_Continue:
	lds acc2, pressedKey
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	ldi acc, 1
	RCALL shiftCursorRight	;сдвиг курсора

	jmp enteringInfoSettingsTimeIncCursor	;сохранение нового значение курсора

enteringInfoSettingsTimeCursorPos2:
	lds acc2, pressedKey
	cpi acc2, 6
	brge enteringInfoSettingsTimeError
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	jmp enteringInfoSettingsTimeIncCursor	;сохранение нового значение курсора

enteringInfoSettingsTimeCursorPos3:
	lds acc2, pressedKey
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	ldi acc, 1
	RCALL shiftCursorRight	;сдвиг курсора

	jmp enteringInfoSettingsTimeIncCursor	;сохранение нового значение курсора

enteringInfoSettingsTimeCursorPos4:
	lds acc2, pressedKey
	cpi acc2, 6
	brge enteringInfoSettingsTimeError
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	jmp enteringInfoSettingsTimeIncCursor	;сохранение нового значение курсора

enteringInfoSettingsTimeCursorPos5:
	lds acc2, pressedKey
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	RCALL shiftCursorSecondRow;сдвиг курсора на следующую строку
	jmp enteringInfoSettingsTimeIncCursor;сохранение нового значение курсора

enteringInfoSettingsTimeCursorPos6:
	ldi acc, 1
	RCALL shiftCursorRight;сдвиг курсора
	jmp enteringInfoSettingsTimeIncCursor	;сохранение нового значение курсора

enteringInfoSettingsTimeIncCursor:
	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret
enteringInfoSettingsTimeKeysLetters:	
	lds acc, pressedKey
	cpi acc, 0x0E
	brge enteringInfoSettingsTimeError2

	subi acc, 0x0A
	ldi ZH, high(enteringInfoSettingsTimeKeysLettersSwitchTable)
	ldi ZL, low(enteringInfoSettingsTimeKeysLettersSwitchTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoSettingsTimeKeysLettersSwitchOverflow

enteringInfoSettingsTimeKeysLettersSwitchContinue:
	ijmp

enteringInfoSettingsTimeError2:
	ret

enteringInfoSettingsTimeKeysLettersSwitchOverflow:
	inc acc
	jmp enteringInfoSettingsTimeKeysLettersSwitchContinue

enteringInfoSettingsTimeKeysLettersSwitchTable:
	call enteringInfoSettingsTimeKeysLettersA
	ret
	call enteringInfoSettingsTimeKeysLettersB
	ret
	call enteringInfoSettingsTimeKeysLettersC
	ret
	call enteringInfoSettingsTimeKeysLettersD
	ret

enteringInfoSettingsTimeKeysLettersA:
	;если значение не правильное (больше положенного) - то не изменять его

	lds acc, cursorCoords
	cpi acc, 6
	brge enteringInfoSettingsTimeKeysLettersAWeekDay
enteringInfoSettingsTimeKeysLettersAContinue:
	
	LDI YL, low(keyboardInputBuffer)
	LDI YH, high(keyboardInputBuffer)
	LD acc, Y+
	STS RTT_10H, acc
	mov acc2, acc
	ldi acc, 10
	mul acc, acc2
	mov acc2, r0
	LD acc, Y+
	STS RTT_1H, acc
	add acc, acc2
	STS RTT_24H, acc
	LD acc, Y+
	STS RTT_10m, acc
	LD acc, Y+
	STS RTT_1m	, acc
	LD acc, Y+
	STS RTT_10s, acc
	LD acc, Y+
	STS RTT_1s	, acc
	cbr programFlags, 8
	jmp enteringInfoSettingsTimeKeysLettersB 

enteringInfoSettingsTimeKeysLettersAWeekDay:
	subi acc, 6
	STS RTT_7Days, acc
	rjmp enteringInfoSettingsTimeKeysLettersAContinue


enteringInfoSettingsTimeKeysLettersB:
	cbr programFlags, 8
	LDI		R17,0b00001100; включить мигание и подсветку курсора
	RCALL	CMD_WR
	ret	
enteringInfoSettingsTimeKeysLettersC:
	lds acc, cursorCoords
	cpi acc, 6
	brlo enteringInfoSettingsTimeKeyBindingError

	cpi acc, 12
	brge enteringInfoSettingsTimeKeyBindingError
	
	ldi acc, 1
	RCALL shiftCursorRight

	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret	
enteringInfoSettingsTimeKeysLettersD:
	lds acc, cursorCoords
	cpi acc, 7
	brlo enteringInfoSettingsTimeKeyBindingError

	ldi acc, 1
	RCALL shiftCursorLeft

	lds acc, cursorCoords
	dec acc
	STS cursorCoords, acc
	ret	

enteringInfoSettingsTimeKeyBindingError:
	ret
;-----ввод информации-----;

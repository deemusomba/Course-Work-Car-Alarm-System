
;=========================================1. Установки=========================================
modeSettings:
	mov acc, menuModes
	andi acc, 0x0f
	cpi acc, 0
	brne modeSettingsSubsLabels

	ldi acc, LOW(_labelMenu1<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu1<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

modeSettingsSubsLabels:
	ldi ZH, high(modeSettingsSubsLabelsSwitchTable)
	ldi ZL, low(modeSettingsSubsLabelsSwitchTable)
	cpi acc, 3;//TODO: добавить в алгоритмы
	brge modeSettingsSubsLabelsSwitchFix//TODO: добавить в алгоритмы
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs modeSettingsSubsLabelsSwitchOverflow

modeSettingsSubsLabelsSwitchContinue:
	ijmp

modeSettingsSubsLabelsSwitchFix://TODO: добавить в алгоритмы
	call keyBindingsLetterCDecSubMode//TODO: добавить в алгоритмы
	sbr programFlags, 4
	jmp modeSettingsSubsLabelsSwitchContinue//TODO: добавить в алгоритмы

modeSettingsSubsLabelsSwitchOverflow:
	inc r31
	jmp modeSettingsSubsLabelsSwitchContinue

modeSettingsSubsLabelsSwitchTable:
	call modeSettingsSetTimeLabel
	ret
	call modeSettingsSetOtherOptionsLabel
	ret
	call modeSettingsSetAvgSpendingLabel
	ret

modeSettingsSetTimeLabel:			
	ldi acc, LOW(_labelMenu11<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu11<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

modeSettingsSetOtherOptionsLabel:		
	ldi acc, LOW(_labelMenu12<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu12<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

modeSettingsSetAvgSpendingLabel:
	ldi acc, LOW(_labelMenu13<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu13<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret
;=========================================1.x Установки=========================================
											
modeSettingsSetTime:
	ldi acc, LOW(_labelMenu11In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu11In<<1)
	mov ZH, acc
	call DATA_WR_from_Z

	LDI		R17,(1<<7)|(6+0x40*0)
	RCALL	CMD_WR

	lds acc2, RTT_10H
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, RTT_1H
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	LDI		R17,(1<<7)|(9+0x40*0)
	RCALL	CMD_WR

	lds acc2, RTT_10M
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, RTT_1M
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	LDI		R17,(1<<7)|(12+0x40*0)
	RCALL	CMD_WR

	lds acc2, RTT_10S
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, RTT_1S
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	call LCD_blinkOn

	ldi acc, 6
	RCALL shiftCursorRight

	ldi acc, 0x00
	STS cursorCoords, acc

	ret
											
modeSettingsSetOptions:
	ldi acc, LOW(_labelMenu12In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu12In<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret
											
modeSettingsSetAvgSpending:
	ret

;=========================================ВВод в "установки"=========================================

enteringInfoSettingsTimeCursorPosSwitch:
	;занести значение клавиши в буфер взависимости от курсора
	lds acc, pressedKey
	cpi acc, 0x0A
	brge enteringInfoSettingsTimeKeysLettersCalling
	
	call enteringInfoWriteInKeyboardBuffer	

	;в зависимости от положения курсора надо сдвинуть курсор
	lds acc, cursorCoords
	cpi acc, 6
	brge enteringInfoSettingsTimeError
	ldi ZH, high(enteringInfoSettingsTimeCursorPosSwitchTable)
	ldi ZL, low(enteringInfoSettingsTimeCursorPosSwitchTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoSettingsTimeCursorPosSwitchOverflow

enteringInfoSettingsTimeCursorPosSwitchContinue:
	ijmp

enteringInfoSettingsTimeCursorPosSwitchOverflow:
	inc r31
	jmp enteringInfoSettingsTimeCursorPosSwitchContinue

enteringInfoSettingsTimeKeysLettersCalling: call enteringInfoSettingsTimeKeysLetters
	ret

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

enteringInfoSettingsTimeCursorPos0:
	lds acc2, pressedKey	
	cpi acc2, 3
	brge enteringInfoSettingsTimeError
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	jmp enteringInfoSettingsTimeIncCursor	;сохранение нового значение курсора

enteringInfoSettingsTimeError:
	lds acc, cursorCoords
	LDI YL, low(keyboardInputBuffer)
	LDI YH, high(keyboardInputBuffer)
	
	add YL, acc
	brcs enteringInfoSettingsTimeErrorOverflow
	jmp enteringInfoSettingsTimeErrorContinue
enteringInfoSettingsTimeErrorOverflow:
	inc r29
enteringInfoSettingsTimeErrorContinue:
	ldi acc, 0xFF 
	ST y, acc
	ret

enteringInfoSettingsTimeCursorPos1:
	LDS acc, pressedKey
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
	inc r31
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
	;если значение не менялось == ff, то и не менять данные

	lds acc, cursorCoords
	cpi acc, 6
	brge enteringInfoSettingsTimeKeysLettersAWeekDay
enteringInfoSettingsTimeKeysLettersAContinue:
	
	LDI YL, low(keyboardInputBuffer)
	LDI YH, high(keyboardInputBuffer)
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoSettingsTimeKeysLettersA1
	STS RTT_10H, acc
	mov acc2, acc
	ldi acc, 10
	mul acc, acc2
	mov acc2, r0
enteringInfoSettingsTimeKeysLettersA1:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoSettingsTimeKeysLettersA2
	STS RTT_1H, acc
	add acc, acc2
	STS RTT_24H, acc
enteringInfoSettingsTimeKeysLettersA2:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoSettingsTimeKeysLettersA3
	STS RTT_10m, acc
enteringInfoSettingsTimeKeysLettersA3:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoSettingsTimeKeysLettersA4
	STS RTT_1m	, acc
enteringInfoSettingsTimeKeysLettersA4:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoSettingsTimeKeysLettersA5
	STS RTT_10s, acc
enteringInfoSettingsTimeKeysLettersA5:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoSettingsTimeKeysLettersA6
	STS RTT_1s	, acc
enteringInfoSettingsTimeKeysLettersA6:
	call enteringInfoClearKeyInputBuffer

	jmp enteringInfoSettingsTimeKeysLettersB 

enteringInfoSettingsTimeKeysLettersAWeekDay:
	subi acc, 6
	STS RTT_7Days, acc
	rjmp enteringInfoSettingsTimeKeysLettersAContinue


enteringInfoSettingsTimeKeysLettersB:
	cbr programFlags, 8
	sbr programFlags, 4
	LDI		R17,0b00001100; выключить мигание и подсветку курсора
	RCALL	CMD_WR
	ret	
enteringInfoSettingsTimeKeysLettersC:
	lds acc, cursorCoords

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


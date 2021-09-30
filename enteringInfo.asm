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
	;call modeSettingsSetTankVolume
	ret
	;call modeSettingsSetAvgSpending
	ret


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
	;call mode2
	ret
	;call mode3
	ret

enteringInfoAutoHeatingScheduleCursorPosSwitch:
	;занести значение клавиши в буфер взависимости от курсора
	lds acc, pressedKey
	cpi acc, 0x0A
	brge enteringInfoAutoHeatingScheduleKeysLettersCalling 
	
	call enteringInfoWriteInKeyboardBuffer	

	;в зависимости от положения курсора надо сдвинуть курсор

	lds acc, cursorCoords
	cpi acc, 4
	brge enteringInfoAutoHeatingScheduleError
	ldi ZH, high(enteringInfoAutoHeatingScheduleCursorPosSwitchTable)
	ldi ZL, low(enteringInfoAutoHeatingScheduleCursorPosSwitchTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoAutoHeatingScheduleCursorPosSwitchOverflow

enteringInfoAutoHeatingScheduleCursorPosSwitchContinue:
	ijmp

enteringInfoAutoHeatingScheduleError:
	ret

enteringInfoAutoHeatingScheduleKeysLettersCalling: call enteringInfoAutoHeatingScheduleKeysLetters
	ret
enteringInfoAutoHeatingScheduleDaysInit:
	LDI		R17,0b00000010; вернуть курсор в начальное положение
	RCALL	CMD_WR

	ldi acc, LOW(_labelMenu21In2<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu21In2<<1)
	mov ZH, acc
	call DATA_WR_from_Z	
		
	LDI		R17,(1<<7)|(0+0x40*1)
	RCALL	CMD_WR

	ldi acc, 7
	;push acc
	LDS acc2, AutoHeatingTimeSchedule_DayOfWeek
	lsl acc2
	push acc2
enteringInfoAutoHeatingScheduleDaysInitLoop:
	pop acc2
	lsl acc2
	push acc2
	brcs enteringInfoAutoHeatingScheduleDaysInitV
	
	ldi acc2, 0x58; X
	jmp enteringInfoAutoHeatingScheduleDaysInitContinue
enteringInfoAutoHeatingScheduleDaysInitV:
	ldi acc2, 0x56; V
enteringInfoAutoHeatingScheduleDaysInitContinue:
	push acc
	RCALL DATA_WR
	pop acc
	dec acc
	cpi acc, 0
	brne enteringInfoAutoHeatingScheduleDaysInitLoop
	
	call enteringInfoAutoHeatingScheduleDaysInitLoop

	pop acc2
	RCALL shiftCursorSecondRow
	ldi acc, 0
	STS keyboardInputBuffer+4, acc

	ldi acc, 4
	STS cursorCoords, acc
	ret

enteringInfoAutoHeatingScheduleCursorPosSwitchOverflow:
	inc r31
	jmp enteringInfoAutoHeatingScheduleCursorPosSwitchContinue

enteringInfoAutoHeatingScheduleCursorPosSwitchTable:
	call enteringInfoAutoHeatingScheduleCursorPos0
	ret
	call enteringInfoAutoHeatingScheduleCursorPos1
	ret
	call enteringInfoAutoHeatingScheduleCursorPos2
	ret
	call enteringInfoAutoHeatingScheduleCursorPos3
	ret

enteringInfoAutoHeatingScheduleCursorPos0:
	jmp enteringInfoSettingsTimeCursorPos0

enteringInfoAutoHeatingScheduleCursorPos1:
	jmp enteringInfoSettingsTimeCursorPos1

enteringInfoAutoHeatingScheduleCursorPos2:
	jmp enteringInfoSettingsTimeCursorPos2

enteringInfoAutoHeatingScheduleCursorPos3:
	lds acc2, pressedKey
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	jmp enteringInfoAutoHeatingScheduleDaysInit

enteringInfoAutoHeatingScheduleKeysLetters:
	lds acc, pressedKey
	cpi acc, 0x0E
	brge enteringInfoSettingsTimeError3

	subi acc, 0x0A
	ldi ZH, high(enteringInfoAutoHeatingScheduleKeysLettersSwitchTable)
	ldi ZL, low(enteringInfoAutoHeatingScheduleKeysLettersSwitchTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoAutoHeatingScheduleKeysLettersSwitchOverflow

enteringInfoAutoHeatingScheduleKeysLettersSwitchContinue:
	ijmp

enteringInfoSettingsTimeError3:
	ret

enteringInfoAutoHeatingScheduleKeysLettersSwitchOverflow:
	inc r31
	jmp enteringInfoSettingsTimeKeysLettersSwitchContinue

enteringInfoAutoHeatingScheduleKeysLettersSwitchTable:
	call enteringInfoAutoHeatingScheduleKeysLettersA
	ret
	call enteringInfoAutoHeatingScheduleKeysLettersB
	ret
	call enteringInfoAutoHeatingScheduleKeysLettersC
	ret
	call enteringInfoAutoHeatingScheduleKeysLettersD
	ret

enteringInfoAutoHeatingScheduleKeysLettersA:

	lds acc, cursorCoords
	cpi acc, 4
	brlo enteringInfoAutoHeatingScheduleDaysInitCalling
	;TODO: если первое подменю, то перейти на второе, иначе вот то что снизу

	LDI YL, low(keyboardInputBuffer)
	LDI YH, high(keyboardInputBuffer)
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoAutoHeatingScheduleKeysLettersA1
	STS AutoHeatingTimeSchedule_10h, acc
enteringInfoAutoHeatingScheduleKeysLettersA1:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoAutoHeatingScheduleKeysLettersA2
	STS AutoHeatingTimeSchedule_1h, acc
enteringInfoAutoHeatingScheduleKeysLettersA2:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoAutoHeatingScheduleKeysLettersA3
	STS AutoHeatingTimeSchedule_10m, acc
enteringInfoAutoHeatingScheduleKeysLettersA3:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoAutoHeatingScheduleKeysLettersA4
	STS AutoHeatingTimeSchedule_1m	, acc
enteringInfoAutoHeatingScheduleKeysLettersA4:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoAutoHeatingScheduleKeysLettersA5
	STS AutoHeatingTimeSchedule_DayOfWeek, acc
enteringInfoAutoHeatingScheduleKeysLettersA5:
	call enteringInfoClearKeyInputBuffer;чистить буфер

	jmp enteringInfoAutoHeatingScheduleKeysLettersB

enteringInfoAutoHeatingScheduleDaysInitCalling:
	jmp enteringInfoAutoHeatingScheduleDaysInit

enteringInfoAutoHeatingScheduleKeysLettersB:
	jmp enteringInfoSettingsTimeKeysLettersB

enteringInfoAutoHeatingScheduleKeysLettersC:
	ldi acc2, 0x56; V
	RCALL DATA_WR
	
	call enteringInfoAutoHeatingScheduleWriteData
	
	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret	
enteringInfoAutoHeatingScheduleKeysLettersD:
	ldi acc2, 0x58; X
	RCALL DATA_WR
	
	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret	

enteringInfoAutoHeatingScheduleKeyBindingError:
	ret

enteringInfoAutoHeatingScheduleWriteData:
	ldi acc2, 0b01000000


	lds acc, cursorCoords
	subi acc, 4
	push acc
enteringInfoAutoHeatingScheduleWriteDataLoop:
	
	pop acc
	cpi acc, 0
	breq enteringInfoAutoHeatingScheduleWriteDataContinue
	dec acc
	push acc

	lsr acc2
	jmp enteringInfoAutoHeatingScheduleWriteDataLoop
enteringInfoAutoHeatingScheduleWriteDataContinue:
	LDS acc, keyboardInputBuffer+4
	OR acc, acc2
	STS keyboardInputBuffer+4, acc
	ret

;-----ввод информации-----;

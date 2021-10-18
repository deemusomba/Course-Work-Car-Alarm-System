
;=========================================2. Автоподогрев=========================================					
modeAutoHeatingSettings:
	mov acc, menuModes
	andi acc, 0x0f
	cpi acc, 0
	brne modeAutoHeatingSettingsSubsLabels

	ldi acc, LOW(_labelMenu2<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu2<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

modeAutoHeatingSettingsSubsLabels:
	ldi ZH, high(modeAutoHeatingSettingsSubsLabelsSwitchTable)
	ldi ZL, low(modeAutoHeatingSettingsSubsLabelsSwitchTable)
	cpi acc, 5;//TODO: добавить в алгоритмы
	brge modeAutoHeatingSettingsSubsLabelsSwitchFix//TODO: добавить в алгоритмы
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs modeAutoHeatingSettingsSubsLabelsSwitchOverflow

modeAutoHeatingSettingsSubsLabelsSwitchContinue:
	ijmp

modeAutoHeatingSettingsSubsLabelsSwitchFix:
	call keyBindingsLetterCDecSubMode//TODO: добавить в алгоритмы
	sbr programFlags, 4
	jmp modeSettingsSubsLabelsSwitchContinue//TODO: добавить в алгоритмы

modeAutoHeatingSettingsSubsLabelsSwitchOverflow:
	inc r31
	jmp modeAutoHeatingSettingsSubsLabelsSwitchContinue

modeAutoHeatingSettingsSubsLabelsSwitchTable:
	call modeAutoHeatingSettingsSetScheduleLabel
	ret
	call modeAutoHeatingSettingsSetWorkingTimeLabel
	ret
	call modeAutoHeatingSettingsSetTempControlLabel
	ret
	call modeAutoHeatingSettingsSetOtherSettingsLabel
	ret

modeAutoHeatingSettingsSetScheduleLabel:		
	ldi acc, LOW(_labelMenu21<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu21<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

modeAutoHeatingSettingsSetWorkingTimeLabel:		
	ldi acc, LOW(_labelMenu22<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu22<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

modeAutoHeatingSettingsSetTempControlLabel:	
	ldi acc, LOW(_labelMenu23<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu23<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret
modeAutoHeatingSettingsSetOtherSettingsLabel:
	ldi acc, LOW(_labelMenu24<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu24<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret
;=========================================2.х Автоподогрев=========================================
modeAutoHeatingSettingsSetSchedule:
	ldi acc, LOW(_labelMenu21In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu21In<<1)
	mov ZH, acc
	call DATA_WR_from_Z

	LDI		R17,(1<<7)|(6+0x40*0)
	RCALL	CMD_WR

	lds acc2, AutoHeatingTimeSchedule_10h
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, AutoHeatingTimeSchedule_1h
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	LDI		R17,(1<<7)|(9+0x40*0)
	RCALL	CMD_WR

	lds acc2, AutoHeatingTimeSchedule_10m
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, AutoHeatingTimeSchedule_1m
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	call LCD_blinkOn

	ldi acc, 6
	RCALL shiftCursorRight

	ldi acc, 0x00
	STS cursorCoords, acc

	ret

modeAutoHeatingSettingsSetWorkingTime:
	ldi acc, LOW(_labelMenu22In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu22In<<1)
	mov ZH, acc
	call DATA_WR_from_Z

	LDI		R17,(1<<7)|(9+0x40*0)
	RCALL	CMD_WR

	lds acc2, AutoHeatingWorkingTime_10m
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, AutoHeatingWorkingTime_1m
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	call LCD_blinkOn
	
	ldi acc, 9
	RCALL shiftCursorRight

	ldi acc, 0x00
	STS cursorCoords, acc

	ret
modeAutoHeatingSettingsSetTempControl:
	ldi acc, LOW(_labelMenu23In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu23In<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	
	LDI		R17,(1<<7)|(0x05+0x40*0)
	RCALL	CMD_WR

	lds acc2, AutoHeatingTempMin10
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, AutoHeatingTempMin1
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR	

	LDI		R17,(1<<7)|(5+0x40*1)
	RCALL	CMD_WR

	lds acc2, AutoHeatingTempMax10
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, AutoHeatingTempMax1
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR


	call LCD_blinkOn
	
	ldi acc, 5
	RCALL shiftCursorRight

	ldi acc, 0x00
	STS cursorCoords, acc

	ret
modeAutoHeatingSettingsSetOtherSettings:
	ldi acc, LOW(_labelMenu24In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu24In<<1)
	mov ZH, acc
	call DATA_WR_from_Z

	LDI		R17,(1<<7)|(0x01+0x40*1)
	RCALL	CMD_WR
	
	mov acc, functionsFlags
	lsl acc
	lsl acc
	lsl acc
	
	lsl acc
	brcs modeAutoHeatingSettingsSetOtherSettingsOutputV
	ldi acc2, 'X'
	jmp modeAutoHeatingSettingsSetOtherSettingsOutputContinue
modeAutoHeatingSettingsSetOtherSettingsOutputV:
	ldi acc2, 'V'
modeAutoHeatingSettingsSetOtherSettingsOutputContinue:
	push acc
	rcall DATA_WR

	LDI		R17,(1<<7)|(0x04+0x40*1)
	RCALL	CMD_WR
	
	pop acc; сдвинутый functionsFlags 

	ldi acc2, 4
	push acc2; итератор

modeAutoHeatingSettingsSetOtherSettingsOutputLoop:
	pop acc2
	dec acc2
	push acc2
	cpi acc2, 0
	breq modeAutoHeatingSettingsSetOtherSettingsRet
	lsl acc
	brcs modeAutoHeatingSettingsSetOtherSettingsOutput1V
	ldi acc2, 'X'
	jmp modeAutoHeatingSettingsSetOtherSettingsOutput1Continue
modeAutoHeatingSettingsSetOtherSettingsOutput1V:
	ldi acc2, 'V'
modeAutoHeatingSettingsSetOtherSettingsOutput1Continue:
	push acc
	rcall DATA_WR
	pop acc

	jmp modeAutoHeatingSettingsSetOtherSettingsOutputLoop
modeAutoHeatingSettingsSetOtherSettingsRet:
	pop acc
	
	rcall LCD_blinkOn
	rcall shiftCursorSecondRow
	ldi acc, 1
	rcall shiftCursorRight
	
	ldi acc, 0x00
	STS cursorCoords, acc	

	ret


;=========================================Ввод в "Автопогрев"=========================================
;=========================================Ввод в "Расписание"=========================================
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

enteringInfoAutoHeatingScheduleError:
	jmp enteringInfoSettingsTimeError

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
	
	pop acc2
	RCALL shiftCursorSecondRow
	ldi acc, 0x0
	STS keyboardInputBuffer+4, acc

	ldi acc, 4
	STS cursorCoords, acc
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
;=========================================/Ввод в "Расписание"=========================================
;=========================================Ввод в "Время работы"=========================================
enteringInfoAutoHeatingWorkingTimeCursorPosSwitch:
	lds acc, pressedKey
	cpi acc, 0x0A
	brge enteringInfoAutoHeatingWorkingTimeKeysLettersCalling 
	
	call enteringInfoWriteInKeyboardBuffer;занести значение клавиши в буфер взависимости от курсора

	;в зависимости от положения курсора надо сдвинуть курсор

	lds acc, cursorCoords
	cpi acc, 2
	brge enteringInfoAutoHeatingWorkingTimeError
	ldi ZH, high(enteringInfoAutoHeatingWorkingTimeCursorPosTable)
	ldi ZL, low(enteringInfoAutoHeatingWorkingTimeCursorPosTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoAutoHeatingWorkingTimeCursorPosOverflow

enteringInfoAutoHeatingWorkingTimeCursorPosContinue:
	ijmp

enteringInfoAutoHeatingWorkingTimeCursorPosOverflow:
	inc r31
	jmp enteringInfoAutoHeatingWorkingTimeCursorPosContinue

enteringInfoAutoHeatingWorkingTimeCursorPosTable:
	call enteringInfoAutoHeatingWorkingTimeCursorPos0
	ret
	call enteringInfoAutoHeatingWorkingTimeCursorPos1
	ret
enteringInfoAutoHeatingWorkingTimeKeysLettersCalling:
	call enteringInfoAutoHeatingWorkingTimeKeysLetters
	ret

enteringInfoAutoHeatingWorkingTimeError:
	jmp enteringInfoSettingsTimeError
	
enteringInfoAutoHeatingWorkingTimeCursorPos0:
	lds acc2, pressedKey
	cpi acc2, 6
	brge enteringInfoAutoHeatingWorkingTimeError
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	jmp enteringInfoSettingsTimeIncCursor	;сохранение нового значение курсора

enteringInfoAutoHeatingWorkingTimeCursorPos1:
	lds acc2, pressedKey
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR
	
	ret

enteringInfoAutoHeatingWorkingTimeKeysLetters:
	lds acc, pressedKey
	cpi acc, 0x0A
	breq enteringInfoAutoHeatingWorkingTimeKeysLettersA
	jmp enteringInfoAutoHeatingWorkingTimeKeysLettersB

enteringInfoAutoHeatingWorkingTimeKeysLettersA:
	LDI YL, low(keyboardInputBuffer)
	LDI YH, high(keyboardInputBuffer)
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoAutoHeatingWorkingTimeKeysLettersA1
	STS AutoHeatingWorkingTime_10m, acc
enteringInfoAutoHeatingWorkingTimeKeysLettersA1:
	LD acc, Y+
	cpi acc, 0xff
	breq enteringInfoAutoHeatingWorkingTimeKeysLettersA2
	STS AutoHeatingWorkingTime_1m, acc
enteringInfoAutoHeatingWorkingTimeKeysLettersA2:
	call enteringInfoClearKeyInputBuffer;чистить буфер
	jmp enteringInfoAutoHeatingWorkingTimeKeysLettersB

enteringInfoAutoHeatingWorkingTimeKeysLettersB:
	jmp enteringInfoSettingsTimeKeysLettersB
;=========================================/Ввод в "Время работы"=========================================
;=========================================Ввод в "Температура"=========================================
enteringInfoAutoHeatingTempControlCursorPosSwitch:
	lds acc, pressedKey
	cpi acc, 0x0A
	brge enteringInfoAutoHeatingTempControlKeysLettersCalling 
	
	call enteringInfoWriteInKeyboardBuffer;занести значение клавиши в буфер взависимости от курсора

	;в зависимости от положения курсора надо сдвинуть курсор

	lds acc, cursorCoords
	ldi ZH, high(enteringInfoAutoHeatingTempControlCursorPosTable)
	ldi ZL, low(enteringInfoAutoHeatingTempControlCursorPosTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoAutoHeatingTempControlCursorPosOverflow

enteringInfoAutoHeatingTempControlCursorPosContinue:
	ijmp

enteringInfoAutoHeatingTempControlCursorPosOverflow:
	inc r31
	jmp enteringInfoAutoHeatingTempControlCursorPosContinue

enteringInfoAutoHeatingTempControlCursorPosTable:
	call enteringInfoAutoHeatingTempControlCursorPos1
	ret
	call enteringInfoAutoHeatingTempControlCursorPos2
	ret
	call enteringInfoAutoHeatingTempControlCursorPos3
	ret
	call enteringInfoAutoHeatingTempControlCursorPos4
	ret
enteringInfoAutoHeatingTempControlKeysLettersCalling:
	call enteringInfoAutoHeatingTempControlKeysLetters
	ret

enteringInfoAutoHeatingTempControlError:
	jmp enteringInfoSettingsTimeError
	
enteringInfoAutoHeatingTempControlCursorPos1:
	lds acc2, pressedKey
	cpi acc2, 4
	brge enteringInfoAutoHeatingTempControlError
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	jmp enteringInfoSettingsTimeIncCursor	;сохранение нового значение курсора

	ret

enteringInfoAutoHeatingTempControlCursorPos2:
	lds acc2, pressedKey
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	RCALL shiftCursorSecondRow;сдвиг курсора на следующую строку
	ldi acc, 5
	rcall shiftCursorRight
	jmp enteringInfoSettingsTimeIncCursor;сохранение нового значение курсора
	ret

enteringInfoAutoHeatingTempControlCursorPos3:
	lds acc2, pressedKey
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR
	jmp enteringInfoSettingsTimeIncCursor
	ret
enteringInfoAutoHeatingTempControlCursorPos4:
	lds acc2, pressedKey
	ldi acc, 0x30
	add acc2, acc
	RCALL DATA_WR

	call LCD_BlinkOff
	ret

enteringInfoAutoHeatingTempControlKeysLetters:
	lds acc, pressedKey
	cpi acc, 0x0C
	brge enteringInfoAutoHeatingTempControlError1

	subi acc, 0x0A
	ldi ZH, high(enteringInfoAutoHeatingTempControlKeysLettersSwitchTable)
	ldi ZL, low(enteringInfoAutoHeatingTempControlKeysLettersSwitchTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoAutoHeatingTempControlKeysLettersSwitchOverflow

enteringInfoAutoHeatingTempControlKeysLettersSwitchContinue:
	ijmp

enteringInfoAutoHeatingTempControlError1:
	ret

enteringInfoAutoHeatingTempControlKeysLettersSwitchOverflow:
	inc r31
	jmp enteringInfoAutoHeatingTempControlKeysLettersSwitchContinue

enteringInfoAutoHeatingTempControlKeysLettersSwitchTable:
	call enteringInfoAutoHeatingTempControlKeysLettersA
	ret
	call enteringInfoAutoHeatingTempControlKeysLettersB
	ret

enteringInfoAutoHeatingTempControlKeysLettersA:
	ldi yl, low(keyboardInputBuffer)
	ldi yh, high(keyboardInputBuffer)
	ld acc, y+
	cpi acc, 0xff
	breq enteringInfoAutoHeationTempControlKeysLettersA1
	STS AutoHeatingTempMin10, acc
enteringInfoAutoHeationTempControlKeysLettersA1:
	ld acc, y+
	cpi acc, 0xff
	breq enteringInfoAutoHeationTempControlKeysLettersA2
	STS AutoHeatingTempMin1, acc
enteringInfoAutoHeationTempControlKeysLettersA2:
	ld acc, y+
	cpi acc, 0xff
	breq enteringInfoAutoHeationTempControlKeysLettersA3
	STS AutoHeatingTempMax10, acc
enteringInfoAutoHeationTempControlKeysLettersA3:
	ld acc, y+
	cpi acc, 0xff
	breq enteringInfoAutoHeationTempControlKeysLettersA4
	STS AutoHeatingTempMax1, acc
enteringInfoAutoHeationTempControlKeysLettersA4:

	call enteringInfoClearKeyInputBuffer;чистить буфер
	jmp enteringInfoAutoHeatingTempControlKeysLettersB

enteringInfoAutoHeatingTempControlKeysLettersB:
	jmp enteringInfoSettingsTimeKeysLettersB


;=========================================/Ввод в "Температура"=========================================
;=========================================Ввод в "Настройки"=========================================
enteringInfoAutoHeatingOtherOptionsCursorPosSwitch:
	lds acc, pressedKey
	cpi acc, 0x0A
	brlo enteringInfoAutoHeatingOtherOptionsError
	jmp enteringInfoAutoHeatingOtherOptionsKeysLetters

enteringInfoAutoHeatingOtherOptionsError:
	ret
	
enteringInfoAutoHeatingOtherOptionsKeysLetters:

	lds acc, pressedKey
	cpi acc, 0x0E
	brge enteringInfoAutoHeatingOtherOptionsError1

	subi acc, 0x0A
	ldi ZH, high(enteringInfoAutoHeatingOtherOptionsKeysLettersSwitchTable)
	ldi ZL, low(enteringInfoAutoHeatingOtherOptionsKeysLettersSwitchTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs enteringInfoAutoHeatingOtherOptionsKeysLettersSwitchOverflow

enteringInfoAutoHeatingOtherOptionsKeysLettersSwitchContinue:
	ijmp

enteringInfoAutoHeatingOtherOptionsError1:
	ret

enteringInfoAutoHeatingOtherOptionsKeysLettersSwitchOverflow:
	inc r31
	jmp enteringInfoAutoHeatingOtherOptionsKeysLettersSwitchContinue

enteringInfoAutoHeatingOtherOptionsKeysLettersSwitchTable:
	call enteringInfoAutoHeatingOtherOptionsKeysLettersA
	ret
	call enteringInfoAutoHeatingOtherOptionsKeysLettersB
	ret
	call enteringInfoAutoHeatingOtherOptionsKeysLettersC
	ret
	call enteringInfoAutoHeatingOtherOptionsKeysLettersD
	ret

enteringInfoAutoHeatingOtherOptionsKeysLettersA:
	jmp enteringInfoAutoHeatingOtherOptionsKeysLettersB

enteringInfoAutoHeatingOtherOptionsKeysLettersB:
	jmp enteringInfoSettingsTimeKeysLettersB

enteringInfoAutoHeatingOtherOptionsKeysLettersC:
	ldi acc2, 0x56; V
	RCALL DATA_WR	

	ldi acc, 1	
	call enteringInfoAutoHeatingOtherOptionsWriteData
	
	call enteringInfoAutoHeatingOtherOptionsIncCursor
	ret	
enteringInfoAutoHeatingOtherOptionsKeysLettersD:
	ldi acc2, 0x58; X
	RCALL DATA_WR

	ldi acc, 0
	call enteringInfoAutoHeatingOtherOptionsWriteData

	call enteringInfoAutoHeatingOtherOptionsIncCursor
	ret	

enteringInfoAutoHeatingOtherOptionsWriteData: 
	;в зависимости от положения курсора заменить байт на введенный
	;в acc лежит 0 или 1
	cpi acc, 1
	breq enteringInfoAutoHeatingOtherOptionsWriteData1
	jmp enteringInfoAutoHeatingOtherOptionsWriteData0
	
enteringInfoAutoHeatingOtherOptionsWriteData0:
	ldi acc, 0b11101111
	lds acc2, cursorCoords
	push acc2
enteringInfoAutoHeatingOtherOptionsWriteData0Loop:
	pop acc2
	cpi acc2, 0
	breq enteringInfoAutoHeatingOtherOptionsWriteData0Break
	dec acc2
	push acc2

	lsr acc
	ori acc, 0x80
	jmp enteringInfoAutoHeatingOtherOptionsWriteData0Loop

enteringInfoAutoHeatingOtherOptionsWriteData0Break:
	and functionsFlags, acc	
	ret
enteringInfoAutoHeatingOtherOptionsWriteData1:
	ldi acc, 0b00010000
	lds acc2, cursorCoords
	push acc2
enteringInfoAutoHeatingOtherOptionsWriteData1Loop:
	pop acc2
	cpi acc2, 0
	breq enteringInfoAutoHeatingOtherOptionsWriteData1Break
	dec acc2
	push acc2

	lsr acc
	jmp enteringInfoAutoHeatingOtherOptionsWriteData1Loop

enteringInfoAutoHeatingOtherOptionsWriteData1Break:
	or functionsFlags, acc	
	ret
enteringInfoAutoHeatingOtherOptionsIncCursor:
	lds acc, cursorCoords
	cpi acc, 0
	brne enteringInfoAutoHeatingOtherOptionsIncCursorContinue
	ldi acc, 2
	call shiftCursorRight
enteringInfoAutoHeatingOtherOptionsIncCursorContinue:
	inc acc
	STS cursorCoords, acc
	cpi acc, 4
	breq enteringInfoAutoHeatingOtherOptionsBreak
	ret
enteringInfoAutoHeatingOtherOptionsBreak:
	call LCD_blinkOff
	ret
;=========================================/Ввод в "Настройки"=========================================
;=========================================/Ввод в "Автопогрев"=========================================

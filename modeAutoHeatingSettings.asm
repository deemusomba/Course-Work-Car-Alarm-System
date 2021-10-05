
;=========================================2. ������������=========================================					
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
	cpi acc, 5;//TODO: �������� � ���������
	brge modeAutoHeatingSettingsSubsLabelsSwitchFix//TODO: �������� � ���������
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs modeAutoHeatingSettingsSubsLabelsSwitchOverflow

modeAutoHeatingSettingsSubsLabelsSwitchContinue:
	ijmp

modeAutoHeatingSettingsSubsLabelsSwitchFix:
	call keyBindingsLetterCDecSubMode//TODO: �������� � ���������
	sbr programFlags, 4
	jmp modeSettingsSubsLabelsSwitchContinue//TODO: �������� � ���������

modeAutoHeatingSettingsSubsLabelsSwitchOverflow:
	inc r31
	jmp modeAutoHeatingSettingsSubsLabelsSwitchContinue

modeAutoHeatingSettingsSubsLabelsSwitchTable:
	call modeAutoHeatingSettingsSetScheduleLabel
	ret
	call modeAutoHeatingSettingsSetTempControlLabel
	ret
	call modeAutoHeatingSettingsSetWorkingTimeLabel
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

modeAutoHeatingSettingsSetTempControlLabel:		
	ldi acc, LOW(_labelMenu22<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu22<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

modeAutoHeatingSettingsSetWorkingTimeLabel:	
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
;=========================================2.� ������������=========================================
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

	LDI		R17,0b00000010; 
	RCALL	CMD_WR

	LDI		R17,0b00001111; 
	RCALL	CMD_WR
	
	ldi acc, 6
	RCALL shiftCursorRight

	ldi acc, 0x00
	STS cursorCoords, acc

	ret
modeAutoHeatingSettingsSetTempControl:
	ldi acc, LOW(_labelMenu22In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu22In<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret
modeAutoHeatingSettingsSetWorkingTime:
	ldi acc, LOW(_labelMenu23In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu23In<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret
modeAutoHeatingSettingsSetOtherSettings:
	ldi acc, LOW(_labelMenu24In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu24In<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

;=========================================���� � "����������"=========================================

enteringInfoAutoHeatingScheduleCursorPosSwitch:
	;������� �������� ������� � ����� ������������ �� �������
	lds acc, pressedKey
	cpi acc, 0x0A
	brge enteringInfoAutoHeatingScheduleKeysLettersCalling 
	
	call enteringInfoWriteInKeyboardBuffer	

	;� ����������� �� ��������� ������� ���� �������� ������

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
	LDI		R17,0b00000010; ������� ������ � ��������� ���������
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
	;TODO: ���� ������ �������, �� ������� �� ������, ����� ��� �� ��� �����

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
	call enteringInfoClearKeyInputBuffer;������� �����

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

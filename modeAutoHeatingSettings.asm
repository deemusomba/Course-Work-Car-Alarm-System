					
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
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs modeAutoHeatingSettingsSubsLabelsSwitchOverflow

modeAutoHeatingSettingsSubsLabelsSwitchContinue:
	ijmp
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
;подменю
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

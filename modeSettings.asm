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
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs modeSettingsSubsLabelsSwitchOverflow

modeSettingsSubsLabelsSwitchContinue:
	ijmp
modeSettingsSubsLabelsSwitchOverflow:
	inc r31
	jmp modeSettingsSubsLabelsSwitchContinue

modeSettingsSubsLabelsSwitchTable:
	call modeSettingsSetTimeLabel
	ret
	call modeSettingsSetTankVolumeLabel
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

modeSettingsSetTankVolumeLabel:		
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
;подменю
											
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

	LDI		R17,0b00000010; 
	RCALL	CMD_WR

	LDI		R17,0b00001111; 
	RCALL	CMD_WR
	
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


updatingDisplay:	
	LDI R17,(1<<0)
	RCALL CMD_WR;
		
	sbrc programFlags, 3
	jmp displayEnteringMenuMenuSwitchCalling

	mov acc, menuModes
	andi acc, 0xf0
	lsr acc
	lsr acc
	lsr acc
	lsr acc
	
updateDisplayMenuSwitch:
	ldi ZH, high(updateDisplayMenuSwitchTable)
	ldi ZL, low(updateDisplayMenuSwitchTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs updateDisplayMenuSwitchOverflow

updateDisplayMenuSwitchContinue:
	ijmp

updateDisplayMenuSwitchOverflow:
	inc r31
	jmp updateDisplayMenuSwitchContinue

updateDisplayMenuSwitchTable:
	call modeMain
	ret
	call modeSettings
	ret
	call modeAutoHeatingSettings
	ret
	call updDisp3
	ret
	call updDisp4
	ret
	call updDisp5
	ret

updDisp3:
	ret
updDisp4:
	ret
updDisp5:
	ret

modeMain:	
	ldi acc, LOW(_labelMainMenu<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMainMenu<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	
	LDI		R17,(1<<7)|(0+0x40*0)
	RCALL	CMD_WR

	lds acc2, RTT_10H
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, RTT_1H
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	LDI		R17,(1<<7)|(3+0x40*0)
	RCALL	CMD_WR

	lds acc2, RTT_10M
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, RTT_1M
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	LDI		R17,(1<<7)|(6+0x40*0)
	RCALL	CMD_WR

	lds acc2, RTT_10S
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR

	lds acc2, RTT_1S
	ldi acc, 0x30
	adc acc2, acc
	RCALL DATA_WR


	LDI		R17,(1<<7)|(9+0x40*0)
	RCALL	CMD_WR	

	lds acc, RTT_7Days
	ldi ZH, high(_labelsDaysOfTheWeek<<1)
	ldi ZL, low(_labelsDaysOfTheWeek<<1)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs modeMainDayOfWeekOverflow
	jmp modeMainContinue
modeMainDayOfWeekOverflow:
	inc r31

modeMainContinue:
	call DATA_WR_from_Z
	ret

displayEnteringMenuMenuSwitchCalling: call displayEnteringMenuMenuSwitch
	ret
displayEnteringMenuMenuSwitch:	
	mov acc, menuModes
	andi acc, 0xf0
	lsr acc	
	lsr acc
	lsr acc
	lsr acc

	ldi ZH, high(displayEnteringMenuMenuSwitchTable)
	ldi ZL, low(displayEnteringMenuMenuSwitchTable)
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs displayEnteringMenuMenuSwitchOverflow

displayEnteringMenuMenuSwitchContinue:
	ijmp

displayEnteringMenuMenuSwitchOverflow:
	inc r31
	jmp displayEnteringMenuMenuSwitchContinue

displayEnteringMenuMenuSwitchTable:
	call displayEnteringMenu1Switch
	ret
	call displayEnteringMenu2Switch
	ret
	;call displayEnteringMenu3Switch
	ret
	;call displayEnteringMenu4Switch
	ret
	;call displayEnteringMenu5Switch
	ret

displayEnteringMenu1Switch:
	mov acc, menuModes
	andi acc, 0x0f

	ldi ZH, high(displayEnteringMenu1SwitchTable)
	ldi ZL, low(displayEnteringMenu1SwitchTable)
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs displayEnteringMenu1SwitchOverflow

displayEnteringMenu1SwitchContinue:
	ijmp

displayEnteringMenu1SwitchOverflow:
	inc r31
	jmp displayEnteringMenu1SwitchContinue

displayEnteringMenu1SwitchTable:
	call modeSettingsSetTime
	ret
	call modeSettingsSetOptions
	ret
	call modeSettingsSetAvgSpending
	ret


displayEnteringMenu2Switch:
	mov acc, menuModes
	andi acc, 0x0f

	ldi ZH, high(displayEnteringMenu2SwitchTable)
	ldi ZL, low(displayEnteringMenu2SwitchTable)
	dec acc
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	brcs displayEnteringMenu2SwitchOverflow

displayEnteringMenu2SwitchContinue:
	ijmp

displayEnteringMenu2SwitchOverflow:
	inc r31
	jmp displayEnteringMenu2SwitchContinue

displayEnteringMenu2SwitchTable:
	call modeAutoHeatingSettingsSetSchedule
	ret
	call modeAutoHeatingSettingsSetTempControl
	ret
	call modeAutoHeatingSettingsSetWorkingTime
	ret
	call modeAutoHeatingSettingsSetOtherSettings
	ret



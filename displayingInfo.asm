											;-----отображение информации-----;
updatingDisplay:	
	LDI R17,(1<<0)
	RCALL CMD_WR; очистка дисплея
		
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
	add r30, acc
	brcs updateDisplayMenuSwitchOverflow

updateDisplayMenuSwitchContinue:
	ijmp

updateDisplayMenuSwitchOverflow:
	ldi acc, 1
	add r30, acc
	jmp updateDisplayMenuSwitchContinue

updateDisplayMenuSwitchTable:
	rjmp updDisp0Calling
	rjmp updDisp1Calling
	rjmp updDisp2Calling	
	rjmp updDisp3Calling
	rjmp updDisp4Calling
	rjmp updDisp5Calling

updDisp0Calling: call modeMain
	ret
updDisp1Calling: call modeSettings
	ret
updDisp2Calling: call modeAutoHeatingSettings
	ret
updDisp3Calling: call updDisp3
	ret
updDisp4Calling: call updDisp4
	ret
updDisp5Calling: call updDisp5
	ret

updDisp3:
	ret
updDisp4:
	ret
updDisp5:
	ret

modeMain:	;главное меню
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

	ret
											;-----1. Установки-----;
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
	add r30, acc
	brcs modeSettingsSubsLabelsSwitchOverflow

modeSettingsSubsLabelsSwitchContinue:
	ijmp
modeSettingsSubsLabelsSwitchOverflow:
	ldi acc, 1
	add r30, acc
	jmp modeSettingsSubsLabelsSwitchContinue

modeSettingsSubsLabelsSwitchTable:
	mov acc, acc	;нулевогго меню нет
	jmp modeSettingsSetTimeLabelCalling
	jmp modeSettingsSetTankVolumeLabelCalling
	jmp modeSettingsSetAvgSpendingLabelCalling

modeSettingsSetTimeLabelCalling:	call modeSettingsSetTimeLabel
	ret
modeSettingsSetTankVolumeLabelCalling: call modeSettingsSetTankVolumeLabel
	ret
modeSettingsSetAvgSpendingLabelCalling: call modeSettingsSetAvgSpendingLabel
	ret

modeSettingsSetTimeLabel:			;отображение подпункта настроек времени и дня недели 
	ldi acc, LOW(_labelMenu11<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu11<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

modeSettingsSetTankVolumeLabel:		;отображение подпункта настройки объема бака
	ldi acc, LOW(_labelMenu12<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu12<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

modeSettingsSetAvgSpendingLabel:	;отображение подпункта настройки среднего рассхода
	ldi acc, LOW(_labelMenu13<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu13<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

											;-----2. Автоподогрев-----;
modeAutoHeatingSettings:
	ldi acc, LOW(_labelMenu2<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu2<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

											;-----Ввод в подрежимах-----;
displayEnteringMenuMenuSwitchCalling: call displayEnteringMenuMenuSwitch
	ret
displayEnteringMenuMenuSwitch:	
	mov acc, menuModes
	andi acc, 0xf0
	lsl acc	
	lsl acc
	lsl acc
	lsl acc

	ldi ZH, high(displayEnteringMenuMenuSwitchTable)
	ldi ZL, low(displayEnteringMenuMenuSwitchTable)
	add r30, acc
	brcs displayEnteringMenuMenuSwitchOverflow

displayEnteringMenuMenuSwitchContinue:
	ijmp

displayEnteringMenuMenuSwitchOverflow:
	ldi acc, 1
	add r30, acc
	jmp displayEnteringMenuMenuSwitchContinue

displayEnteringMenuMenuSwitchTable:
	jmp displayEnteringMenu1SwitchCalling
	jmp displayEnteringMenu2SwitchCalling
	jmp displayEnteringMenu3SwitchCalling
	jmp displayEnteringMenu4SwitchCalling
	jmp displayEnteringMenu5SwitchCalling

displayEnteringMenu1SwitchCalling: call displayEnteringMenu1Switch
	ret
displayEnteringMenu2SwitchCalling: call displayEnteringMenu2Switch
	ret
displayEnteringMenu3SwitchCalling: ;call displayEnteringMenu3Switch
	ret
displayEnteringMenu4SwitchCalling: ;call displayEnteringMenu4Switch
	ret
displayEnteringMenu5SwitchCalling: ;call displayEnteringMenu5Switch
	ret

displayEnteringMenu1Switch:
	mov acc, menuModes
	andi acc, 0x0f

	ldi ZH, high(displayEnteringMenu1SwitchTable)
	ldi ZL, low(displayEnteringMenu1SwitchTable)
	add r30, acc
	brcs displayEnteringMenu1SwitchOverflow

displayEnteringMenu1SwitchContinue:
	ijmp

displayEnteringMenu1SwitchOverflow:
	ldi acc, 1
	add r30, acc
	jmp displayEnteringMenu1SwitchContinue

displayEnteringMenu1SwitchTable:
	breq displayEnteringMenu1Submenu1Calling
	breq displayEnteringMenu1Submenu2Calling
	breq displayEnteringMenu1Submenu3Calling


displayEnteringMenu1Submenu1Calling: call modeSettingsSetTime
	ret
displayEnteringMenu1Submenu2Calling: call modeSettingsSetTankVolume
	ret
displayEnteringMenu1Submenu3Calling: call modeSettingsSetAvgSpending
	ret
											;-----1.1. Время-----;
modeSettingsSetTime:
	ldi acc, LOW(_labelMenu11In<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu11In<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	
	LDI		R17,0b00000010; вернуть курсор в начальное положение
	RCALL	CMD_WR

	LDI		R17,0b00001111; включить мигание и подсветку курсора
	RCALL	CMD_WR
	;сдвинуть до ввода цифр
	ldi acc, 7
	RCALL shiftCoursorRight

	ldi acc, 0x07

	ret
											;-----1.2. Объем бака-----;
modeSettingsSetTankVolume:
	ret
											;-----1.3. Средний расход-----;
modeSettingsSetAvgSpending:
	ret

displayEnteringMenu2Switch:
	ret

;-----отображение информации-----;

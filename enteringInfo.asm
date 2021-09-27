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
	add r30, acc
	brcs enteringInfoMenuSwitchOverflow

enteringInfoMenuSwitchContinue:
	ijmp

enteringInfoMenuSwitchOverflow:
	ldi acc, 1
	add r31, acc
	jmp enteringInfoMenuSwitchContinue

enteringInfoMenuSwitchTable:
	nop	;нулевогго меню нет
	rjmp enteringInfoMenu1SwitchCalling
	rjmp enteringInfoMenu2SwitchCalling
	rjmp enteringInfoMenu3SwitchCalling
	rjmp enteringInfoMenu4SwitchCalling
	rjmp enteringInfoMenu5SwitchCalling

enteringInfoMenu1SwitchCalling: call enteringInfoMenu1Switch
	ret
enteringInfoMenu2SwitchCalling: ;call enteringInfoMenu2Switch
	ret
enteringInfoMenu3SwitchCalling: ;call enteringInfoMenu3Switch
	ret
enteringInfoMenu4SwitchCalling: ;call enteringInfoMenu4Switch
	ret
enteringInfoMenu5SwitchCalling: ;call enteringInfoMenu5Switch
	ret

enteringInfoMenu1Switch:
	mov acc, menuModes
	andi acc, 0x0f

	ldi ZH, high(enteringInfoMenu1SwitchTable)
	ldi ZL, low(enteringInfoMenu1SwitchTable)
	add r30, acc
	brcs enteringInfoMenu1SwitchOverflow

enteringInfoMenu1SwitchContinue:
	ijmp

enteringInfoMenu1SwitchOverflow:
	ldi acc, 1
	add r31, acc
	jmp enteringInfoMenu1SwitchContinue

enteringInfoMenu1SwitchTable:
	nop
	rjmp enteringInfoMenu1Submenu1Calling
	rjmp enteringInfoMenu1Submenu2Calling
	rjmp enteringInfoMenu1Submenu3Calling


enteringInfoMenu1Submenu1Calling: call enteringInfoSettingsTime
	ret
enteringInfoMenu1Submenu2Calling: ;call modeSettingsSetTankVolume
	ret
enteringInfoMenu1Submenu3Calling: ;call modeSettingsSetAvgSpending
	ret


enteringInfoSettingsTime:
	;учитывать меню, координаты курсора

	LDI		R17,(1<<4)|(1<<2); сдвинуть курсор вправо
	RCALL	CMD_WR

	
	;LDI		R17,(1<<4); сдвинуть курсор влево
	;RCALL	CMD_WR

	ret




;-----ввод информации-----;

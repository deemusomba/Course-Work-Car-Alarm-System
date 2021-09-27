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
	lds acc, cursorCoords
	andi acc, 0xf0
	cpi acc, 0
	breq enteringInfoSettingsTimeRow0Switch
	jmp enteringInfoSettingsTimeRow1Switch


enteringInfoSettingsTimeRow0Switch:
	lds acc, cursorCoords
	andi acc, 0x0F
	ldi ZH, high(enteringInfoSettingsTimeRow0SwitchTable)
	ldi ZL, low(enteringInfoSettingsTimeRow0SwitchTable)
	add r30, acc
	brcs enteringInfoSettingsTimeRow0SwitchOverflow

enteringInfoSettingsTimeRow0SwitchContinue:
	ijmp

enteringInfoSettingsTimeRow0SwitchOverflow:
	ldi acc, 1
	add r31, acc
	jmp enteringInfoMenuSwitchContinue

enteringInfoSettingsTimeRow0SwitchTable:
	rjmp enteringInfoSettingsTimeRow0Col0
	rjmp enteringInfoSettingsTimeRow0Col1
	rjmp enteringInfoSettingsTimeRow0Col2
	rjmp enteringInfoSettingsTimeRow0Col3
	rjmp enteringInfoSettingsTimeRow0Col4
	rjmp enteringInfoSettingsTimeRow0Col5

enteringInfoSettingsTimeRow0Col0Calling: call enteringInfoSettingsTimeRow0Col0
	ret
enteringInfoSettingsTimeRow0Col1Calling: call enteringInfoSettingsTimeRow0Col1
	ret
enteringInfoSettingsTimeRow0Col2Calling: call enteringInfoSettingsTimeRow0Col2
	ret
enteringInfoSettingsTimeRow0Col3Calling: call enteringInfoSettingsTimeRow0Col3
	ret
enteringInfoSettingsTimeRow0Col4Calling: call enteringInfoSettingsTimeRow0Col4
	ret
enteringInfoSettingsTimeRow0Col5Calling: call enteringInfoSettingsTimeRow0Col5
	ret

enteringInfoSettingsTimeRow0Col0:
	lds acc, pressedKey
	STS keyboardInputBuffer, acc;запись в буфер
	;сдвиг курсора
	ldi acc, 1
	RCALL shiftCursorRight
	;сохранение нового значение курсора
	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret
enteringInfoSettingsTimeRow0Col1:
	lds acc, pressedKey
	STS keyboardInputBuffer+1, acc;запись в буфер
	;сдвиг курсора
	ldi acc, 2
	RCALL shiftCursorRight
	;сохранение нового значение курсора
	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret
enteringInfoSettingsTimeRow0Col2:
	lds acc, pressedKey
	STS keyboardInputBuffer+2, acc;запись в буфер
	;сдвиг курсора
	ldi acc, 1
	RCALL shiftCursorRight
	;сохранение нового значение курсора
	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret
enteringInfoSettingsTimeRow0Col3:
	lds acc, pressedKey
	STS keyboardInputBuffer+3, acc;запись в буфер
	;сдвиг курсора
	ldi acc, 2
	RCALL shiftCursorRight
	;сохранение нового значение курсора
	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret
enteringInfoSettingsTimeRow0Col4:
	lds acc, pressedKey
	STS keyboardInputBuffer+4, acc;запись в буфер
	;сдвиг курсора
	ldi acc, 1
	RCALL shiftCursorRight
	;сохранение нового значение курсора
	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret
enteringInfoSettingsTimeRow0Col5:
	lds acc, pressedKey
	STS keyboardInputBuffer+5, acc;запись в буфер
	;сдвиг курсора на следующую строку
	RCALL shiftCursorSecondRow
	;сохранение нового значение курсора
	ldi acc, 0x10
	STS cursorCoords, acc
	ret

enteringInfoSettingsTimeRow1Switch:
	call enteringInfoSettingsTimeRow1Cols
	ret

enteringInfoSettingsTimeRow1Cols:
	lds acc, pressedKey
	STS keyboardInputBuffer+6, acc;запись в буфер
	;сдвиг курсора
	ldi acc, 1
	RCALL shiftCursorRight
	;сохранение нового значение курсора
	lds acc, cursorCoords
	inc acc
	STS cursorCoords, acc
	ret

enteringInfoSettingsTimeSetInfo:
	;выгрузить инфу из keyboardInputBuffer в нужные регистры
	ret
;-----ввод информации-----;

;-----обработка клавиш-----;
keyBindings:
	;тут какая-то логика для кнопок	
	cbr programFlags, 16; по умолчанию, клавиша в режиме ввода не установлена
	sbrc programFlags, 3
	jmp keyBindingsEnteringInModes
	mov acc, r0
	cpi acc, 10
	brge keyBindingsLetters
	call keyBindingsNumbers

keyBindingsRet:	ret

keyBindingsNumbers:
	mov acc, menuModes
	andi acc, 0xF0
	cpi acc, 0; если левая часть (режим) == 0, то вводим его
	breq keyBindingsEnterMode
	
	mov acc, menuModes
	andi acc, 0x0F
	cpi acc, 0;если правая часть (подменю) == 0, то вводим его
	breq keyBindingsEnterSubMode
	; иначе - это ввод внутри функции
	ret

keyBindingsEnterMode: 			;ввод пункта меню
	mov acc, r0
	cpi acc, 0x06; количество режимов, но +1
	brge keyBindingsRet; нет такого режима, уходим
	mov acc, r0
	andi menuModes, 0x0F
	lsl acc
	lsl acc
	lsl acc
	lsl acc
	add menuModes, acc	;записали режим
	jmp keyBindingsRet
keyBindingsEnterSubMode:		;ввод пункта подменю
	mov acc, r0
	andi menuModes, 0xF0
	add menuModes, acc			;ввели пункт подменю
	jmp keyBindingsRet
	
keyBindingsLetters:
	mov acc, r0
	subi acc, 10; --10
	ldi ZH, high(keyBindingsLetterCallingTable)
	ldi ZL, low(keyBindingsLetterCallingTable)
	ldi acc2, 3
	mul acc, acc2
	add r30, r0
	;проверка на выходной перенос
	brcs keyBindingsLettersOverflow

keyBindingsLettersContinue:
	ijmp

keyBindingsLettersOverflow:
	inc acc
	jmp keyBindingsLettersContinue

keyBindingsLetterCallingTable:	
keyBindingsLetterACalling: call keyBindingsLetterA
	ret
keyBindingsLetterBCalling: call keyBindingsLetterB
	ret
keyBindingsLetterCCalling: call keyBindingsLetterC
	ret
keyBindingsLetterDCalling: call keyBindingsLetterD
	ret
keyBindingsLetterECalling: call keyBindingsLetterE
	ret
keyBindingsLetterFCalling: call keyBindingsLetterF
	ret

keyBindingsLetterA:
	;если главное меню - ничего не делать
	mov acc, menuModes
	andi acc, 0xF0
	cpi acc, 0
	breq keyBindingsRet2
	;если выбран режим, то выбрать первый подрежим
	mov acc, menuModes
	andi acc, 0x0F
	cpi acc, 0
	breq keyBindingLetterASubMode
	;если выбран подрежим, то ввод в режимах
	sbr programFlags, 8;	установка флага перехода в подрежим
	sbr programFlags, 4; установка флага "обновить дисплей"
	jmp keyBindingsRet

keyBindingLetterASubMode:	;при входе в выбор подрежимов, выбрать самый первый из них
	mov acc, menuModes
	andi acc, 0xF0
	ori acc, 0x01
	mov menuModes, acc
	jmp keyBindingsRet2

keyBindingsLetterB:
	mov acc, menuModes
	cpi acc, 0				;если главное меню - то ничего не делать
	breq keyBindingsRet2

	mov acc, menuModes
	andi acc, 0x0f			
	cpi acc, 0				;если подпункт не выбран, то назад в главное меню
	breq keyBindingsBackFromMode
	;значит все выбрано
	
	sbrc programFlags, 3	;если флаг "в режиме" установлен, то сброс его
	jmp keyBindingsLetterBExit	;выход из подпункта и переход к выбору подпунктов
		
	andi menuModes, 0xf0	;иначе выходим из выбора подпунктов обратно к выбору пунктов меню	
	jmp keyBindingsRet2

keyBindingsLetterBExit:	
	cbr programFlags, 8
	jmp keyBindingsRet2

keyBindingsBackFromMode:
	ldi menuModes, 0x00		;назад в главное меню
	jmp keyBindingsRet2

keyBindingsLetterC:
	jmp keyBindingsRet2
keyBindingsLetterD:
	mov acc, menuModes
	andi acc, 0xf0
	cpi acc, 0x60; количество режимов, но +1
	brge keyBindingsBackToMainMenu
	ldi acc2, 0x10
	add acc, acc2
	mov menuModes, acc
	jmp keyBindingsRet2
keyBindingsBackToMainMenu:
	ldi acc, 0x00
	mov menuModes, acc
	jmp keyBindingsRet2
keyBindingsLetterE:
	ret
keyBindingsLetterF:
	ret
keyBindingsRet2: jmp keyBindingsRet
keyBindingsEnteringInModes:
	sbr programFlags, 16
	STS pressedKey, r0
	ret


;-----обработка клавиш-----;

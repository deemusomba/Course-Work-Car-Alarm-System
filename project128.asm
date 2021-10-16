.device ATmega128             
.INCLUDE "m128def.inc"

.def scan=R18;   
.def cpg=R19;  
.def keyRow=R20;
.def menuModes=R21;старшая часть отвечает за пункты меню, младшая - за подпункты
.def acc=R16;аккумулятор
.def acc2=R17;вспомогательный регистр для передачи данных между блоками
.def programFlags=R22; 0|0|carThing I dont remember|inModeEntered|inMode|updateDisplay|DebouncingEnd|keyPress
.def RTTFlags=R23; real-time timer programFlags  0|0|0|0|0|autoHeatingTemp|autoHeatingSchedule|keyScan|msAdd
.def functionsFlags=R24; 0|0|0|0|autoHeatingTime|autoHeatingTemp|autoHeatingSchedule|autoHeatingTurnOn
.def temperature=R15
.dseg
.ORG SRAM_START+100
RTT_mS: .BYTE 1; милисекунда
RTT_qS: .BYTE 1; quarterS, четверть секунды
RTT_1S: .BYTE 1;секунды
RTT_10S: .BYTE 1;десятки секунд
RTT_1M: .BYTE 1;минуты
RTT_10M: .BYTE 1;десятки минут
RTT_1H: .BYTE 1;часы
RTT_10H: .BYTE 1;десятки часов
RTT_24H: .BYTE 1;подсчет суток (24 часа)
RTT_7Days: .BYTE 1; день недели

AutoHeatingTimeSchedule_10h: .BYTE 1
AutoHeatingTimeSchedule_1h: .BYTE 1
AutoHeatingTimeSchedule_10m: .BYTE 1
AutoHeatingTimeSchedule_1m: .BYTE 1
AutoHeatingTimeSchedule_DayOfWeek: .BYTE 1
AutoHeatingWorkingTime_1m: .BYTE 1
AutoHeatingWorkingTime_10m: .BYTE 1
AutoHeatingTempMin10: .BYTE 1
AutoHeatingTempMin1: .BYTE 1
AutoHeatingTempMax10: .BYTE 1
AutoHeatingTempMax1: .BYTE 1
AutoHeatingTempControlOn: .BYTE 1
AutoHeatingPreviousStartTime_10h: .BYTE 1
AutoHeatingPreviousStartTime_1h: .BYTE 1
AutoHeatingPreviousStartTime_10m: .BYTE 1
AutoHeatingPreviousStartTime_1m: .BYTE 1



KeyScanTimer: .BYTE 1; таймер опроса клавиатуры 
KeyDebouncingTimer: .BYTE 1; таймер дребезга клавиатуры 

keyboardInputBuffer: .BYTE 16; буфер ввода клавиатуры

AccReserve: .BYTE 1; сохранить аккумулятор перед тем, как изменять его в прерываниях 
pressedKey: .BYTE 1; нажатая клавиша - для ввода в режимах
cursorCoords: .BYTE 1;координаты курсора

.cseg

.org 0x00
	jmp start
.org 0x18
	jmp RTT_1msInt; 
.org 0x2A
	jmp ADC_Int
.org 0x30
	jmp start

KeyTable:
.DB 0x0C,0x03,0x02,0x01 ; 1, 2, 3, C
.DB 0x0D,0x06,0x05,0x04 ; 4, 5, 6, D
.DB 0x0E,0x09,0x08,0x07 ; 7, 8, 9, E
.DB 0x0F,0x0A,0x00,0x0B ; B, 0, A, F

; dp|g|f|e| d|c|b|a|
; |-a-|
; f   b
; |-g-|
; e   c
; |-d-| dp

.include "LCD.asm"
.include "keyboardProcessing.asm"
.include "displayingInfo.asm"
.include "enteringInfo.asm"
.include "autoHeating.asm"
.include "modeSettings.asm"
.include "modeAutoHeatingSettings.asm"
start:
;=========================================Инициализация=========================================
	ldi acc,low(ramend)
	out spl,acc
	ldi acc,high(ramend)
	out sph,acc;иницилизация адресации
	ldi scan, 0b11101110;0b00010001
	ldi cpg, 0x00
	ldi keyRow, 0x04; по кол-ву строк - 4
	ldi programFlags, 0x04
	ldi RTTFlags, 0x00
	ldi menuModes, 0x00; точка входа - главная страница
	ldi acc,0xF0
	out ddrc, acc; младшая тетрада порта C на ввод,старшая - на вывод
	ldi acc, 0xFF
	out ddra, acc; port a assigned to output
	ldi acc,0xFF
	out ddre, acc
	;ldi acc,0x01
	;out eimsk,acc;разрешение локального прерывания по int0
	ldi acc,0b00000001
	out ddrd,acc;pinD на вывод
	ldi acc, 0x50; для timer2 по переполнению + OCF1A
	out timsk,acc;разрешение локальных прерываний для таймеров

	ldi acc, 0x0F
	out OCR1AH, acc
	ldi acc, 0xA0
	out OCR1AL, acc; в регистр сравнения загружаем 4000 чтобы получить 1ms
	ldi acc, 0x01
	out TCCR1B, acc;
	
	ldi acc, 0x0; инициализация переменных
	STS RTT_mS, acc
	STS RTT_qS, acc
	STS RTT_1S, acc
	STS RTT_10S, acc
	STS RTT_1M, acc
	STS RTT_10M, acc
	STS RTT_1H, acc
	STS RTT_10H, acc
	STS RTT_24H, acc
	STS AutoHeatingTimeSchedule_10h, acc
	STS AutoHeatingTimeSchedule_1h, acc
	STS AutoHeatingTimeSchedule_10m, acc
	STS AutoHeatingTimeSchedule_1m, acc
	STS AutoHeatingWorkingTime_1m, acc
	STS AutoHeatingPreviousStartTime_10h, acc
	STS AutoHeatingPreviousStartTime_1h, acc
	STS AutoHeatingPreviousStartTime_10m, acc
	STS AutoHeatingPreviousStartTime_1m, acc
	sts AutoHeatingTempControlOn, acc
	ldi acc, 0x01
	STS AutoHeatingWorkingTime_10m, acc
	ldi acc, 0x0
	STS KeyScanTimer, acc
	STS KeyDebouncingTimer, acc

	STS pressedKey, acc	
	STS cursorCoords, acc
	STS keyboardInputBuffer, acc
	
	ldi acc, 0xff
	STS AutoHeatingTimeSchedule_DayOfWeek, acc
	
	ldi acc, 1;
	STS AutoHeatingTempMin10, acc
	ldi acc, 5;
	STS AutoHeatingTempMin1, acc
	ldi acc, 4
	STS AutoHeatingTempMax10, acc
	ldi acc, 0
	STS AutoHeatingTempMax1, acc
	
	ldi acc, 0xff
	ldi acc2, 0x11 
	LDI YL, low(keyboardInputBuffer)
	LDI YH, high(keyboardInputBuffer)
startkeyboardInputBufferInit:
	ST y, acc
	adiw y,1
	dec acc2
	cpi acc2, 0
	brne startkeyboardInputBufferInit	  	

	LDI r16, 0xff
	OUT DDRE, r16
	
	LDI r16, 0xff
	OUT DDRB, r16	
	;инициализация дисплея
	LDI		R17,0x38;(1<<LCD_F)|(1<<LCD_F_8B)|(1<<LCD_F_2L)	;установка режима, 8-мибитный режим, 2 строки
	RCALL	CMD_WR
	LDI		R17,0x01;(1<<LCD_CLR); очистка дисплея
	RCALL	CMD_WR
	LDI		R17,0x06;(1<<LCD_ENTRY_MODE)|(1<<LCD_ENTRY_INC); режим ввода, режим ввода инкрементом
	RCALL	CMD_WR
	LDI		R17,0x0C;(1<<LCD_ON)|(1<<LCD_ON_DISPLAY)|(0<<LCD_ON_CURSOR)|(0<<LCD_ON_BLINK); включить дисплей: вкл, курсор, моргание курсора
	RCALL	CMD_WR
	LDI		R17,0x02;(1<<LCD_HOME)	
	RCALL	CMD_WR
	
	;инициализация spi	

	ldi acc, (1<<SPE)|(1<<MSTR);|(1<<SPR0) 
	out SPCR, acc
	
	ldi acc, 0xff; обнуление семисигментного индикатора
	call updateSevenSigmDisplay
	;инициализация АЦП
	ldi acc, 0b10001101;включить АЦП, установить частоту в 125кГЦ, разрешение прерывания
	out ADCSRA, acc
	ldi acc, 0b00000000;Настройки: AREF, ADC0
	out ADMUX, acc

	sei; разрешение прерываний   
;=========================================/Инициализация=========================================
;для отладочных вещей
backdoor:
	
	ldi r16, 0x00
	cpi r16, 0x00
	;brne backgroundLoop

bkdr:
	jmp backgroundLoop

;=========================================Фоновый цикл=========================================
backgroundLoop:
	jmp carScanning;сканирование датчиков дверей и тп
	
backLoopAfterCarScan:
	sbrc programFlags, 0; если 1, тогда следующую строку, иначе пропустить
	jmp backLoopAfterKeyScan;ждем таймер дребезга

	sbrc RTTFlags, 1; если 1, то перейти 
	call keyboardScanning; проверка портов на нажатие

backLoopAfterKeyScan:
	sbrc programFlags, 1
	jmp keyboardColumnDetection; определение кнопки

backLoopAfterOpScan:
	sbrc RTTFlags, 0; добавить мс
	jmp RTT_main

backLoopAfterRTTFlagsScan:
	sbrc programFlags, 2
	call updateDisplay
	sbrc programFlags, 3
	call enteringInfo

	jmp backgroundLoop

;=========================================/Фоновый цикл=========================================

updateDisplay:
	cbr programFlags,4; очистка флага "обновить дисплей"	
	call updatingDisplay
	ret
;=========================================Клавиатура=========================================
keyboardScanning:
	;первоначальная инициализация
	cbr RTTFlags,2
	cpi keyRow, 0; если 0, то выход   
	breq keyScanRestoreNumberRow;  
keyScanAfterRestore:
	dec keyRow; keyRow--

	mov acc, scan
	andi acc, 0b11110000
	out portC, acc
	nop
	
	in acc, pinC;pinC
	andi acc, 0x0F
	cpi acc, 0x0F
	breq keyAfterInt
	jmp keyboardPressInt

keyAfterInt:
	lsl scan ;сдвиг логический левый
	brcc keyScanSkipInc; если выходной перенос = 0, то пропускаем
	inc scan; scan++
keyScanSkipInc:
	;если ноль
	ret
;восстановить кол-во строк
keyScanRestoreNumberRow:
	ldi keyRow, 0x04
	jmp keyScanAfterRestore;
	
;прерывание по нажатию на клавишу
keyboardPressInt:
	in cpg, pinC;сохранение данных о столбце

	;инициализация таймера дребезга
	ldi acc, 200
	STS KeyDebouncingTimer, acc

	sbr programFlags,1	
	jmp keyAfterInt

;входная точка определения клавиши
keyboardColumnDetection:
	ldi ZL,	LOW(KeyTable<<1)
	ldi ZH, HIGH(KeyTable<<1)
	
	mov acc, keyRow
	push keyRow
	ldi acc, 4
	mul acc, keyRow
	mov acc, r0
	add r30, acc
	pop keyRow
keyRowFound:
	;строка найдена 
	mov acc, cpg
keyRowFoundLoop:
	;определение кнопки
	lsr acc
	brcc keyFound
	adiw ZL, 1;   перебираем кнопки

	rjmp keyRowFoundLoop

keyFound:
	;кнопка найдена
	lpm
	cbr programFlags, 2
	
	call keyBindings	

	sbrs programFlags, 3; если в "режиме", то по умолчанию не обновлять дисплей
	sbr programFlags, 4; установка флага "обновить дисплей" после нажатия на клавишу

	ldi acc, 0
	STS KeyScanTimer, acc
	cbr RTTFlags, 2

	jmp backgroundLoop
	
;=========================================/Клавиатура=========================================
;=========================================Часы=========================================
RTT_1msInt:
	push acc
	ldi acc, 0x00
	CLI; запрет прерываний
	out TCNT1H, acc
	out TCNT1L, acc; обнуление таймера
	SEI; разрешение прерываний

	sbr RTTFlags,1;установка флага "добавилась мсекунда"
	ldi acc, 0
	out OCF1A,acc;
	pop acc
	reti

RTT_main:
	cbr RTTFlags,1;снятие флага "добавилась мсекунда"

	sbrs programFlags, 0
	jmp RTT_KeyScanTimer
	lds acc, KeyDebouncingTimer
	SUBI acc, 1
	STS KeyDebouncingTimer, acc
	cpi acc, 0
	brne RTT_ProgrammTimer

	cbr programFlags, 1; зануление флага нажатия клавиши
	sbr programFlags,2
	
	jmp RTT_ProgrammTimer
RTT_KeyScanTimer:
	;программный таймер опроса клавиатуры
	lds acc, KeyScanTimer
	inc acc
	STS KeyScanTimer, acc
	cpi acc, 10
	brne RTT_ProgrammTimer

	sbr RTTFlags, 2; установка флага по инициализации опроса клавиатуры
	ldi acc, 0
	STS KeyScanTimer, acc
			
RTT_ProgrammTimer:


	lds acc, RTT_mS
	inc acc
	STS RTT_mS, acc
	;проверка на четверть секунды
	cpi acc, 250
	brne RTT_end
	ldi acc, 0
	STS RTT_mS, acc
	
	ldi acc, 0b11001101;запустить преобразование
	out ADCSRA, acc

	lds acc, RTT_qS
	inc acc
	STS RTT_qS, acc
	;проверка на секунду
	cpi acc, 4
	brne RTT_end
	ldi acc, 0
	STS RTT_qS, acc

	sbrs programFlags, 3; если находится в состоянии "в режиме", то не обновлять
	sbr programFlags, 4; установка флага "обновить дисплей" раз в секунду
	call autoHeatingMain; обработка автоподогрева

	lds acc, RTT_1S
	inc acc
	STS RTT_1S, acc
	;проверка на количество секунд
	cpi acc, 10
	brne RTT_end
	ldi acc, 0
	STS RTT_1S, acc

	lds acc, RTT_10S
	inc acc
	STS RTT_10S, acc
	;проверка на количество десятков секунд
	cpi acc, 6
	brne RTT_end
	ldi acc, 0
	STS RTT_10S, acc

	sbrs functionsFlags, 0
	call RTT_checkSchedule

	lds acc, RTT_1M
	inc acc
	STS RTT_1M, acc
	;проверка на количество минут
	cpi acc, 10
	brne RTT_end
	ldi acc, 0
	STS RTT_1M, acc
	rjmp RTT_continue;
RTT_end:
	jmp backLoopAfterRTTFlagsScan
RTT_continue:
	lds acc, RTT_10M
	inc acc
	STS RTT_10M, acc
	;проверка на количество десятков минут
	cpi acc, 6
	brne RTT_end2
	ldi acc, 0
	STS RTT_10M, acc

	lds acc, RTT_24H
	inc acc
	STS RTT_24H, acc
	;проверка суток
	cpi acc, 24
	breq RTT_24h_inc

RTT_continue2:
	lds acc, RTT_1H
	inc acc
	STS RTT_1H, acc
	;проверка часов
	cpi acc, 10
	brne RTT_end2
	ldi acc, 0
	STS RTT_1H, acc

	lds acc, RTT_10H
	inc acc
	STS RTT_10H, acc
	;проверка на количество десятков часов
	cpi acc, 3
	brne RTT_end2
	ldi acc, 0
	STS RTT_10H, acc

RTT_end2:
	jmp backLoopAfterRTTFlagsScan

RTT_24h_inc:
	ldi acc, 0
	STS RTT_24H, acc
	STS RTT_1H, acc
	STS RTT_10H, acc
	lds acc, RTT_7Days
	inc acc
	STS RTT_7Days, acc
	;проверка кол-во дней
	cpi acc, 7
	brne RTT_end2
	ldi acc, 0
	STS RTT_7Days, acc
	call RTT_checkSchedule
	jmp backLoopAfterRTTFlagsScan
;=========================================/Часы=========================================
;=========================================Проверка расписания автоподогрева=========================================
RTT_checkSchedule:
	lds acc, RTT_7Days
	lds acc2, AutoHeatingTimeSchedule_DayOfWeek

	lsl acc2
RTT_checkScheduleLoop:
	lsl acc2
	brcs RTT_checkScheduleLoopBreak
	cpi acc, 0
	breq RTT_checkScheduleRet
	dec acc
	jmp RTT_checkScheduleLoop

RTT_checkScheduleLoopBreak:
	lds acc, RTT_10h
	lds acc2, AutoHeatingTimeSchedule_10h
	cp acc, acc2
	brne RTT_checkScheduleRet
	lds acc, RTT_1h
	lds acc2, AutoHeatingTimeSchedule_1h
	cp acc, acc2
	brne RTT_checkScheduleRet
	lds acc, RTT_10m
	lds acc2, AutoHeatingTimeSchedule_10m
	cp acc, acc2
	brne RTT_checkScheduleRet
	lds acc, RTT_1m
	lds acc2, AutoHeatingTimeSchedule_1m
	cp acc, acc2
	brne RTT_checkScheduleRet

	call autoHeatingTurnOn	

RTT_checkScheduleRet:	ret
;=========================================/Проверка расписания автоподогрева=========================================
;=========================================Сигнализация=========================================
carScanning:
	jmp backLoopAfterCarScan
updateSevenSigmDisplay: ;в acc (r16) находится то, что нужно отобразить
	out SPDR, acc
updateSevenSigmDisplayLoop:
	sbis SPSR, SPIF
	rjmp updateSevenSigmDisplayLoop
	sbi portB, 0
	cbi portB, 0
	ret
;=========================================/Сигнализация=========================================
;=========================================Получение температуры=========================================
ADC_Int:
	push acc
	push acc2

getTemperature:
	in acc, ADCL
	in acc2, ADCH
	subi acc2, 1
	subi acc, 0xDD; -40C
	brcs getTemperatureBelowZero
	jmp getTemperatureBelowZeroContinue

getTemperatureBelowZero:
	subi acc2, 1
getTemperatureBelowZeroContinue:
	cpi acc2, 1
	brge getTemperatureCarryOn; готовимся к сдвигу. Если в старшей части 1, то его в младшую часть
	jmp getTemperatureCarryOnContinue
getTemperatureCarryOn:
	ldi acc2, 0x80
getTemperatureCarryOnContinue:
	lsr acc; acc/=2
	or acc, acc2
	subi acc, 40
	brmi getTemperatureNegativeOutput
	jmp getTemperatureNegativeOutputContinue
getTemperatureNegativeOutput:
	com acc
	ldi acc2, 0x80
	or acc, acc2		;прямой код. Если старший бит 1 - то это отрицательное число
getTemperatureNegativeOutputContinue:
	mov temperature, acc
	pop acc2
	pop acc
	reti
;=========================================/Получение температуры=========================================
displayRecodingTable:
.DB 0x41,0xA0,0x42,0xA1,0x44,0x45,0xA3,0xA4,0xA5,0xA6,0x4B,0xA7,0x4D,0x48,0x4F,0xA8,0x50,0x43,0x54,0xA9,0xAA,0x58,0xE1,0xAB,0xAC,0xE2,0xAD,0xAE,0x62,0xAF,0xB0,0xB1

_labelTest:
.DB 'А','Б','В','Г','Д','Е','Ё','Ж','З','И','Й','К','Л','М','Н',1,0,'О','П','Р','С','Т','У','Ф','Х','Ц','Ч','Ш','Щ','Ъ','Ы','Ь','Э','Ю','Я','e'
_labelError:
.DB "ПРОИЗОШЛА", 1,0, "ПРОГ. ОШИБКА",'e'
_labelMainMenu:
.DB "00:00:00",'e',0
_labelsDaysOfTheWeek:
.DB "ПН",'e',"ВТ",'e',"СР",'e',"ЧТ",'e',"ПТ",'e',"СБ",'e',"ВС",'e',0
_labelMenu1:
.DB "1.УСТАНОВКИ", 1, 0, "А-ВOЙТИ  B-НАЗАД",'e'
_labelMenu11:
.DB "1.1 ВРЕМЯ",1,0,"А-ВOЙТИ  B-НАЗАД",'e'
_labelMenu11In:
.DB "ВРЕМЯ 00:00:00",1,0,"ПВСЧПСВ  A-V B-X",'e',0
_labelMenu12:
.DB "1.2 ОПЦИИ",1,0,"А-ВOЙТИ  B-НАЗАД",'e'
_labelMenu12In:
.DB "A",1,0,"V",0,9,"С-V D-X",1,7,"A-ОК B-ВХ",'e',0
_labelMenu13:
.DB "1.3 СР.РАСХОД",1,0,"А-ВOЙТИ  B-НАЗАД",'e'
_labelMenu2:
.DB "2.АВТОПОДОГРЕВ",1,0,"А-ВOЙТИ  B-НАЗАД",'e',0
_labelMenu21:
.DB "2.1 РАСПИСАНИЕ",1,0,"А-ВOЙТИ  B-НАЗАД",'e',0
_labelMenu21In:
.DB "ВРЕМЯ 00:00",1,8,"A-СЛ B-X",'e'
_labelMenu21In2:
.DB "ПВСЧПСВ  С-V D-X",1,7,"A-ОК B-ВХ",'e'
_labelMenu22:
.DB "2.2 ВРЕМЯ РАБОТЫ",1,0,"А-ВOЙТИ  B-НАЗАД",'e',0
_labelMenu22In:
.DB "РАБОТАТЬ 10МИНУТ",1,9,"A-V B-X",'e'
_labelMenu23:
.DB "2.3 ТЕМПЕРАТУРА",1,0,"А-ВOЙТИ  B-НАЗАД",'e'
_labelMenu23In:
.DB "ИСП. V  ВКЛ -15С",1,0,"ВЫКЛ 40С CVDX AO",'e',0
_labelMenu24:
.DB "2.4 ДОП. ОПЦИИ",1,0,"А-ВOЙТИ  B-НАЗАД",'e',0
_labelMenu24In:
.DB "П:V С:V",0,12,"A-ОК",1,3,"C-V D-X В-ВЫХ",'e',0



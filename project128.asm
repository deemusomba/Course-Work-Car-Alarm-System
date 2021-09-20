.device ATmega128             
.INCLUDE "m128def.inc"
;.include "m103def.inc"

.def scan=R18;   
.def cpg=R19;  
.def keyRow=R20;
.def menuModes=R21;старшая часть отвечает за пункты меню, младшая - за подпункты
.def acc=R16;аккумулятор
.def programFlags=R22; 0|0|0|0|0|updateDisplay|DebouncingEnd|keyPress
.def RTTFlags=R23; real-time timer programFlags  0|0|0|0|0|0|keyScan|msAdd|0
.def prK=R5; pressed key
.def keyboardPointer=R24

.dseg
RTT_mS: .BYTE 1; милисекунда
RTT_qS: .BYTE 1; quarterS, четверть секунды
RTT_1S: .BYTE 1;секунды
RTT_10S: .BYTE 1;десятки секунд
RTT_1M: .BYTE 1;минуты
RTT_10M: .BYTE 1;десятки минут
RTT_1H: .BYTE 1;часы
RTT_10H: .BYTE 1;десятки часов
RTT_24H: .BYTE 1;подсчет суток в целом

KeyScanTimer: .BYTE 1; таймер для дребезга клавиатуры 

KeyTablePointer: .BYTE 1; указатель на таблицу с клавиатурой
SevSegPointer: .BYTE 1; указатель на таблицу со значениями семисигментного индикатора //TODO: удалить

.cseg

.org 0x00
	jmp start
.org 0x02
	jmp keyboardPressInt; процедура прерывания клав.
.org 0x14
	jmp keyboardDebouncingInt;  переход на процедуру прерывания таймера дребезга  
.org 0x18
	jmp RTT_1msInt; 
.org 0x20
	;jmp rop;процедура по прирывании реакция таймера оператора
.org 0x30
	jmp start

KeyTable:
.DB 0x0C,0x03,0x02,0x01 ; 1, 2, 3, C
.DB 0x0D,0x06,0x05,0x04 ; 4, 5, 6, D
.DB 0x0E,0x09,0x08,0x07 ; 7, 8, 9, E
.DB 0x0F,0x0A,0x00,0x0B ; B, 0, A, F

; dp|g|f|e| d|c|b|a|
SevenSegmentValues:
.DB 0xC0,0xF9,0xA4,0xB0 ; 0, 1, 2, 3  |-a-|
.DB 0x99,0x92,0x82,0xF8 ; 4, 5, 6, 7  f   b
.DB 0x80,0x90,0x88,0x83 ; 8, 9, A. B  |-g-|
.DB 0xC6,0xA1,0x86,0x8E ; C, D, E, F  e   c
						;             |-d-| dp
.include "LCD_macro.inc"
.include "LCD.asm"
.include "symToHexConverter.asm"
start:
	ldi acc,low(ramend)
	out spl,acc
	ldi acc,high(ramend)
	out sph,acc;иницилизация адресации
	ldi scan, 0b00010001
	ldi cpg, 0x00
	ldi keyRow, 0x04; по кол-ву строк - 4
	ldi programFlags, 0x04
	ldi RTTFlags, 0x00
	ldi commands, 0x00
	ldi acc,0xF0
	out ddrc, acc; младшая тетрада порта C на ввод,старшая - на вывод
	ldi acc, 0xFF
	out ddra, acc; port a assigned to output
	ldi acc,0xFF
	out ddre, acc
	;ldi acc,0x01
	;out eimsk,acc;разрешение локального прерывания по int0
	ldi acc,0xF8
	out ddrd,acc;вход на ввод int0, int1, int2
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

	STS KeyScanTimer, acc

	ldi acc, LOW(KeyTable<<1)
	STS KeyTablePointer, acc	
	
	ldi acc, LOW(SevenSegmentValues<<1)
	STS SevSegPointer, acc		

	ldi acc, 0x01
	out pind, acc;  если 1 в младшем бите, то не нажато	  	

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

	sei; разрешение прерываний   

;для отладочных вещей
backdoor:
	ldi r16, 0x00
	cpi r16, 0x00
	;brne backgroundLoop

bkdr:
	jmp backgroundLoop

;-----главный цикл обработки флагов-----;
backgroundLoop:
	jmp carScanning;сканирование датчиков дверей и тп

backLoopAfterCarScan:
	sbrc programFlags, 0; если 1, тогда следующую строку, иначе пропустить
	jmp backLoopAfterKeyScan;ждем таймер дребезга

	sbrc programFlags, 1; если 1, то следующая.; если конец дребезга, то определяем кнопку
	jmp keyboardColumnDetection

	sbrc RTTFlags, 1; если 1, то перейти 
	call keyboardScanning; проверка портов на нажатие

backLoopAfterKeyScan:
	sbrc programFlags, 1
	jmp keyboardColumnDetection; определение кнопки

backLoopFlag2:
	;jmp displaySigments;отображение значений на индикаторах

backLoopAfterDispSigms:
	;cpi commands, 0; если 0, то ни одна команда не выбрана
	;brne operationScanning; обработка команд

backLoopAfterOpScan:
	sbrc RTTFlags, 0; если 0, то флаги не установлены, пропустить
	jmp RTT_main

backLoopAfterRTTFlagsScan:
	sbrc programFlags, 2
	call updateDisplay
	jmp backgroundLoop

;-----конец обработки флагов-----;

;входная точка обработки команд
;operationScanning:
	;cpi commands, 1
	;breq displayNumber;
	;jmp backLoopAfterOpScan

updateDisplay:
	cbr programFlags,4; очистка флага "обновить дисплей"

	LDI R17,(1<<0)
	RCALL CMD_WR	

	;LDI	R17,(1<<LCD_DDRAM)|(0+0x40*1); x, y
	;RCALL CMD_WR
	
	ldi acc, LOW(_labelTest<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelTest<<1)
	mov ZH, acc

loop:
	lpm
	mov acc, r0
	cpi acc, 0
	breq exitLoop

	RCALL symToHex
	mov r17, acc

	RCALL	DATA_WR
	adiw ZL, 1

	jmp loop
	
exitLoop:
	ret

;-----КЛАВИАТУРА-----;

;входная точка перебора строк клавиатуры
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
	
	in acc, pinC
	andi acc, 0x0F
	cpi acc, 0x00
	breq keyAfterInt
	jmp keyboardPressInt

keyAfterInt:
	ldi acc, 0xFF
	out portE, acc
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
	sbr programFlags,1
	in cpg, pinC;сохранение данных о столбце

	;инициализация таймера дребезга
	ldi acc, 0xB1
	out tcnt2, acc;  выбор времени = ff - tcnt0
	ldi acc, 0x05; 20 мc при 0хB1 и 0х05, 256uS - 1 тик
	out tccr2, acc; делитель частоты для таймера
	
	jmp keyAfterInt

;прерывание по таймеру дребезга
keyboardDebouncingInt:; окончание дребезга

	ldi acc, 0x0
	out tccr2, acc; остановка таймера
	cbr programFlags, 1; зануление флага нажатия клавиши

	sbr programFlags,2
	reti

;входная точка определения клавиши
keyboardColumnDetection:
	
	lds acc, KeyTablePointer
	clr ZH
	mov ZL, acc
	
	mov acc, keyRow

	cpi acc, 4
	brne keyColDecLoop;
	dec acc;

keyColDecLoop:
	;определение строки
	cpi acc, 0; если 0, то выход   
	breq keyRowFound; 

	adiw ZL, 4; перемещаем курсор на 4 
	dec acc; keyRow--

	jmp keyColDecLoop

keyRowFound:
	;строка найдена 

	mov acc, cpg
keyRowFoundLoop:
	;определение кнопки

	lsr acc
	brcs keyFound
	adiw ZL, 1;   перебираем кнопки

	rjmp keyRowFoundLoop

keyFound:
	;кнопка найдена
	lpm
	mov prK, r0

	;тут какая-то логика для кнопок
	ldi commands, 1; функция вывода на индикатор

	;ldi scan, 0b00010001
	cbr programFlags, 2

	ldi acc, 0
	STS KeyScanTimer, acc
	cbr RTTFlags, 2
	nop	

	jmp backgroundLoop
;-----КЛАВИАТУРА-----;

RTT_1msInt:
	ldi acc, 0x00
	CLI; запрет прерываний
	out TCNT1H, acc
	out TCNT1L, acc; обнуление таймера
	SEI; разрешение прерываний

	sbr RTTFlags,1;установка флага "добавилась мсекунда"
	ldi acc, 0
	out OCF1A,acc;
	reti

RTT_main:
	;тут какая-то логика для программных таймеров и их флагов
	;программный таймер опроса клавиатуры
	lds acc, KeyScanTimer
	SUBI acc, (-1)
	STS KeyScanTimer, acc
	cpi acc, 10
	brne RTT_ProgrammTimer

RTT_KeyDebouncingTimer:
	sbr RTTFlags, 2; установка флага по инициализации опроса клавиатуры
	ldi acc, 0
	STS KeyScanTimer, acc
			
RTT_ProgrammTimer:
	cbr RTTFlags,1;снятие флага "добавилась мсекунда"

	lds acc, RTT_mS
	SUBI acc, (-1)
	STS RTT_mS, acc
	;проверка на четверть секунды
	cpi acc, 250
	brne RTT_end
	ldi acc, 0
	STS RTT_mS, acc
	;тут можно выставить какой-нибудь флаг

	lds acc, RTT_qS
	SUBI acc, (-1)
	STS RTT_qS, acc
	;проверка на секунду
	cpi acc, 4
	brne RTT_end
	
	sbr programFlags, 4; установка флага "обновить дисплей" раз в секунду

	ldi acc, 0
	STS RTT_qS, acc

	lds acc, RTT_1S
	SUBI acc, (-1)
	STS RTT_1S, acc
	;проверка на количество секунд
	cpi acc, 10
	brne RTT_end
	ldi acc, 0
	STS RTT_1S, acc

	lds acc, RTT_10S
	SUBI acc, (-1)
	STS RTT_10S, acc
	;проверка на количество десятков секунд
	cpi acc, 6
	brne RTT_end
	ldi acc, 0
	STS RTT_10S, acc

	lds acc, RTT_1M
	SUBI acc, (-1)
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
	SUBI acc, (-1)
	STS RTT_10M, acc
	;проверка на количество десятков минут
	cpi acc, 6
	brne RTT_end2
	ldi acc, 0
	STS RTT_10M, acc

	lds acc, RTT_24H
	SUBI acc, (-1)
	STS RTT_24H, acc
	;проверка суток
	cpi acc, 24
	brne RTT_end2
	ldi acc, 0
	STS RTT_24H, acc

	lds acc, RTT_1H
	SUBI acc, (-1)
	STS RTT_1H, acc
	;проверка часов
	cpi acc, 10
	brne RTT_end2
	ldi acc, 0
	STS RTT_1H, acc

	lds acc, RTT_10H
	SUBI acc, (-1)
	STS RTT_10H, acc
	;проверка на количество десятков часов
	cpi acc, 6
	brne RTT_end2
	ldi acc, 0
	STS RTT_10H, acc

RTT_end2:
	jmp backLoopAfterRTTFlagsScan

carScanning:
	jmp backLoopAfterCarScan
	in acc, pinA; CentralLock|GlassBreaking|Bumper|LeftFront|RightFront|LeftBack|RightBack|Trunk
	lsl acc ;сдвиг логический левый
	brcc carScanCL1; если выходной перенос = 1
carScanCL1:
	lsl acc;
	brcc carScanGB0; если выходной перенос = 0
carScanGB0:
	
carScanAlarm:
	ldi acc, 0;pass

	;часть про вывод через последовательный вывод, но это не понадобится скорее всего
	;ldi acc, (1<<0)|(1<<1)|(1<<2)
	;out DDRB, acc
;	ldi acc, (1<<SPE)|(1<<MSTR);|(1<<SPR0) 
	;out SPCR, acc
	;ldi acc, 0xF9
	;out SPDR, acc

;bkdr1:
	;sbis SPSR, SPIF
	;rjmp bkdr1
	;ldi acc, 0x01
	;out PINB, acc
	
_labelHelloWorld:
.DB 'П','Р','И','В','Е','Т',',',' ','М','И','Р', 0
_labelTest:
.DB 'Н', 'Е', 'С', 'Т', 'Е', 'Р', 'У', 'К', ' ','1', ' ', 'L' , 'O', 'V', 'E', 0

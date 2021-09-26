.device ATmega128             
.INCLUDE "m128def.inc"
;.include "m103def.inc"

.def scan=R18;   
.def cpg=R19;  
.def keyRow=R20;
.def menuModes=R21;старшая часть отвечает за пункты меню, младшая - за подпункты
.def acc=R16;аккумулятор
.def acc2=R17;вспомогательный регистр для передачи данных между блоками
.def programFlags=R22; 0|0|0|inModeEntered|inMode|updateDisplay|DebouncingEnd|keyPress
.def RTTFlags=R23; real-time timer programFlags  0|0|0|0|0|0|keyScan|msAdd|0
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

KeyScanTimer: .BYTE 1; таймер опроса клавиатуры 
KeyDebouncingTimer: .BYTE 1; таймер дребезга клавиатуры 


KeyTablePointer: .BYTE 1; указатель на таблицу с клавиатурой
AccReserve: .BYTE 1; сохранить аккумулятор перед тем, как изменять его в прерываниях 
pressedKey: .BYTE 1; нажатая клавиша - для ввода в режимах
cursorCoords: .BYTE 1;координаты курсора

.cseg

.org 0x00
	jmp start
.org 0x02
	;jmp keyboardPressInt; процедура прерывания клав.
.org 0x14
	;jmp keyboardDebouncingInt;  переход на процедуру прерывания таймера дребезга  
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
; |-a-|
; f   b
; |-g-|
; e   c
; |-d-| dp

.include "LCD_macro.inc"
.include "LCD.asm"
.include "symToHexConverter.asm"
.include "keyboardProcessing.asm"
.include "displayingInfo.asm"
.include "enteringInfo.asm"
start:
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
	STS KeyDebouncingTimer, acc

	ldi acc, LOW(KeyTable<<1)
	STS KeyTablePointer, acc	
	
	ldi acc, 0x00
	STS pressedKey, acc	
	STS cursorCoords, acc

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

backLoopAfterOpScan:
	sbrc RTTFlags, 0; добавить мс
	jmp RTT_main

backLoopAfterRTTFlagsScan:
	sbrc programFlags, 2
	call updateDisplay
	sbrc programFlags, 3
	call enteringInfo
	jmp backgroundLoop

;-----конец обработки флагов-----;

updateDisplay:
	cbr programFlags,4; очистка флага "обновить дисплей"
		
	call updatingDisplay
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
	lds acc, KeyTablePointer
	clr ZH
	mov ZL, acc
	
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
	
;-----КЛАВИАТУРА-----;
;--------ЧАСЫ--------;
RTT_1msInt:
	sts AccReserve, acc
	ldi acc, 0x00
	CLI; запрет прерываний
	out TCNT1H, acc
	out TCNT1L, acc; обнуление таймера
	SEI; разрешение прерываний

	sbr RTTFlags,1;установка флага "добавилась мсекунда"
	ldi acc, 0
	out OCF1A,acc;
	lds acc, AccReserve
	reti

RTT_main:
	;тут какая-то логика для программных таймеров и их флагов
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
	SUBI acc, (-1)
	STS KeyScanTimer, acc
	cpi acc, 10
	brne RTT_ProgrammTimer

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
	
	sbrs programFlags, 3; если находится в состоянии "в режиме", то не обновлять
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
;--------ЧАСЫ--------;

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

displayRecodingTable:
.DB 0x41,0xA0,0x42,0xA1,0x44,0x45,0xA3,0xA4,0xA5,0xA6,0x4B,0xA7,0x4D,0x48,0x4F,0xA8,0x50,0x43,0x54,0xA9,0xAA,0x58,0x75,0xAB,0xAC,0xAC,0xAD,0xAE,0x62, 0xAF,0xB0,0xB1
	
_labelTest:
.DB 'А','Б','В','Г','Д','Е','Ё','Ж','З','И','Й','К','Л','М','Н',1,0,'О','П','Р','С','Т','У','Ф','Х','Ц','Ч','Ш','Щ','Ъ','Ы','Ь','Э','Ю','Я','e'
_labelMainMenu:
.DB '0','0',':','0','0',':','0','0','e'
_labelMenu1:
.DB '1','.','У','С','Т','А','Н','О','В','К','И',1,0,'A','-','В','О','Й','T','И',' ',' ','B','-','Н','А','З','А','Д','e'
_labelMenu11:
.DB '1','.','1',' ','В','Р','Е','М','Я',1,0,'A','-','В','О','Й','Т','И',' ',' ','B','-','Н','А','З','А','Д','e'
_labelMenu11In:
.DB 'В','Р','Е','М','Я',' ','0','0',':','0','0',':','0','0',1,0,'П','В','С','Ч','П','С','В',' ',' ','А','-','V',' ','B','-','X','e'
_labelMenu12:
.DB '1','.','2',' ','О','Б','Ъ','Е','М',' ','Б','А','К','А',1,0,'A','-','В','О','Й','Т','И',' ',' ','B','-','Н','А','З','А','Д','e'
_labelMenu13:
.DB '1','.','3',' ','С','Р','.',' ','Р','А','С','Х','О','Д',1,0,'A','-','В','О','Й','Т','И',' ',' ','B','-','Н','А','З','А','Д','e'
_labelMenu2:
.DB '2','.','А','В','Т','О','П','О','Д','О','Г','Р','Е','В',1,0,'A','-','В','О','Й','Т','И',' ',' ','B','-','Н','А','З','А','Д','e'




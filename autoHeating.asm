
;=========================================Автоподогрев=========================================
autoHeatingMain:
	sbrs functionsFlags,0
	jmp autoHeatingTempChecking; автоподогрев не включен, но проверить, надо ли его включать по температуре
	;автоподогрев включен, проверить а не пора ли выключать
	;по температуре
	lds acc, AutoHeatingTempMax10
	ldi acc2, 10
	mul acc, acc2
	mov acc, r0
	lds acc2, AutoHeatingTempMax1
	add acc, acc2
	push acc
	mov acc2, temperature
	andi acc, 0x80
	cpi acc, 0x80	;если отрицательное, то проверить время
	breq AutoHeatingTimeChecking
	;если не отрицательное, то если температура больше максимальной - отключить
	pop acc
	cp acc2, acc
	brge autoHeatingTurnOff

	;иначе - проверить время
AutoHeatingTimeChecking:
	;

	ret

autoHeatingTempChecking:
	lds acc, AutoHeatingTempMin10
	ldi acc2, 10
	mul acc, acc2
	mov acc, r0
	lds acc2, AutoHeatingTempMin1
	add acc, acc2;получили значение минимальной темп-ры
	push acc
	mov acc, temperature; получить значение текущей темп-ры
	cpi acc, 0x80
	brlo autoHeatingTempCheckingPositive; положительное значение темп-ры
	mov acc2, acc
	andi acc2, 0b01111111
	pop acc
	cp acc2, acc
	brge autoHeatingTurnOn
autoHeatingTempCheckingRet:
	ret

autoHeatingTempCheckingPositive:
	pop acc
	ret

autoHeatingTurnOn:
	;//TODO:записать текущее время в переменные



	sbi portD, 0
	sbr functionsFlags,1
	ret
autoHeatingTurnOff:
	cbi portD, 0
	cbr functionsFlags,1
	ret
autoHeatingGetTemps:
	
;=========================================/Автоподогрев=========================================

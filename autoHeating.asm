
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

	;если не отрицательное, то если температура больше максимальной - отключить
	cp temperature, acc
	brge autoHeatingTurnOffCalling
	jmp AutoHeatingTimeChecking;иначе - проверить время

autoHeatingTurnOffCalling:
	jmp autoHeatingTurnOff

AutoHeatingTimeChecking:
	lds acc, RTT_10h
	ldi acc2, 10
	mul acc, acc2
	mov acc, r0
	lds acc2, RTT_1h
	add acc, acc2; кол-во часов текущее
	push acc
	lds acc, AutoHeatingPreviousStartTime_10h
	ldi acc2, 10
	mul acc, acc2
	mov acc, r0
	lds acc2, AutoHeatingPreviousStartTime_1h
	add acc, acc2; кол-во часов при прошлом запуске
	pop acc2; текущее
	sub acc2, acc; разница
	brmi AutoHeatingTimeChecking1hFix; 0-23 = -23, час изменился
	cpi acc2, 1
	breq AutoHeatingTimeChecking1hFix; 23-22=1, час изменился
	ldi acc, 0
	;час не менялся
AutoHeatingTimeChecking1hFixContinue:
	lds acc2, RTT_10m
	push acc
	ldi acc, 10
	mul acc2, acc
	mov acc2, r0
	pop acc
	add acc, acc2; добавили 60, если час сменился
	lds acc2, RTT_1m
	add acc, acc2; кол-во минут текущее
	push acc
	
	lds acc, AutoHeatingPreviousStartTime_10m
	ldi acc2, 10
	mul acc, acc2
	mov acc, r0
	lds acc2, AutoHeatingPreviousStartTime_1m
	add acc2, acc; кол-во минут при прошлом запуске
	
	pop acc
	sub acc, acc2
	push acc; кол-во минут, которые прошли
	
	lds acc, AutoHeatingWorkingTime_10m
	ldi acc2, 10
	mul acc, acc2
	mov acc, r0
	lds acc2, AutoHeatingWorkingTime_1m
	add acc, acc2; кол-во минут заданное
	
	pop acc2
	sub acc, acc2
	cpi acc, 0
	breq autoHeatingTurnOff

	ret

AutoHeatingTimeChecking1hFix:
	ldi acc, 60; добавляем 60 минут в кол-во минут текущих
	jmp AutoHeatingTimeChecking1hFixContinue

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
	lds acc, RTT_10H
	STS AutoHeatingPreviousStartTime_10h, acc
	lds acc, RTT_1H
	STS AutoHeatingPreviousStartTime_1h, acc
	lds acc, RTT_10m
	STS AutoHeatingPreviousStartTime_10m, acc
	lds acc, RTT_1m
	STS AutoHeatingPreviousStartTime_1m, acc

	sbi portD, 0
	sbr functionsFlags,1
	ret
autoHeatingTurnOff:
	cbi portD, 0
	cbr functionsFlags,1
	ret
autoHeatingGetTemps:
	
;=========================================/Автоподогрев=========================================

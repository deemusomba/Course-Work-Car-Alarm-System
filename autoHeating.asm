
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
	rcall getTemperature
	mov acc2, acc
	andi acc, 0x80
	cpi acc, 0x80	;если отрицательное, то проверить время
	breq AutoHeatingTimeChecking
	;если не отрицательное, то если температура больше максимальной - отключить
	pop acc
	cp acc2, acc
	brge autoHeatingTurnOff

	;иначе - проверить время
AutoHeatingTimeChecking:
	sbrc acc, 7
	pop acc
	

	ret

autoHeatingTempChecking:
	lds acc, AutoHeatingTempMin10
	ldi acc2, 10
	mul acc, acc2
	mov acc, r0
	lds acc2, AutoHeatingTempMin1
	add acc, acc2
	push acc
	rcall getTemperature
	mov acc2, acc
	andi acc2, 0b01111111
	pop acc
	cp acc2, acc
	brge autoHeatingTurnOn
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

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
modeSettings:
	ldi acc, LOW(_labelMenu1<<1)
	mov ZL, acc
	ldi acc, HIGH(_labelMenu1<<1)
	mov ZH, acc
	call DATA_WR_from_Z
	ret

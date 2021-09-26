;-----ввод информации-----;
enteringInfo:
	sbrs programFlags, 4
	ret
	call enteringInfoMain
	cbr programFlags, 16
	ret

enteringInfoMain:
	;учитывать меню, координаты курсора

	LDI		R17,(1<<4)|(1<<2); сдвинуть курсор вправо
	RCALL	CMD_WR

	
	;LDI		R17,(1<<4); сдвинуть курсор влево
	;RCALL	CMD_WR

	ret
;-----ввод информации-----;

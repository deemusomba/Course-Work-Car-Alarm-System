symToHex:;sym in acc (r16)
	cpi acc, 192
	brlo brOther; если меньше кода буквы A, то код символа введенного равен коду для вывода на дисплей				
	cpi acc, 'А'
	breq brRuA
	cpi acc, 'Б'
	breq brRuB
	cpi acc, 'В'
	breq brRuV
	cpi acc, 'Г'
	breq brRuG
	cpi acc, 'Д'
	breq brRuD
	cpi acc, 'Е'
	breq brRuE
	cpi acc, 'Ё'
	breq brRuYo
	jmp brContinue
brOther: ret
brRuA:	ldi acc, 0x41
	ret
brRuB:	ldi acc, 0xA0
	ret
brRuV:	ldi acc, 0x42
	ret
brRuG:	ldi acc, 0xA1
	ret
brRuD:	ldi acc, 0x44 ;D
	ret
brRuE:	ldi acc, 0x45 ;E
	ret
brRuYo:	ldi acc, 0xA2 ;Ё
	ret
brContinue:
	cpi acc, 'Ж'
	breq brRuJ
	cpi acc, 'З'
	breq brRuZ
	cpi acc, 'И'
	breq brRuI
	cpi acc, 'Й'
	breq brRuJi
	cpi acc, 'К'
	breq brRuK
	cpi acc, 'Л'
	breq brRuL
	cpi acc, 'М'
	breq brRuM
	jmp brContinue2

brRuJ:	ldi acc, 0xA3 ;Ж
	ret
brRuZ:	ldi acc,  0xA4 
	ret
brRuI:	ldi acc, 0xA5
	ret
brRuJi:ldi acc, 0xA6
	ret
brRuK:	ldi acc, 0x4B
	ret
brRuL:	ldi acc, 0xA7
	ret
brRuM:	ldi acc, 0x4D
	ret
brRuN:	ldi acc, 0x48
	ret
brContinue2:
	cpi acc, 'Н'
	breq brRuN
	cpi acc, 'О'
	breq brRuO
	cpi acc, 'П'
	breq brRuP
	cpi acc, 'Р'
	breq brRuR
	cpi acc, 'С'
	breq brRuS
	cpi acc, 'Т'
	breq brRuT
	cpi acc, 'У'
	breq brRuU
	jmp brContinue3
brRuO:	ldi acc, 0x4F 
	ret
brRuP:	ldi acc, 0xA8
	ret
brRuR:	ldi acc, 0x50
	ret
brRuS:	ldi acc, 0x43
	ret
brRuT:	ldi acc, 0x54
	ret
brRuU:	ldi acc, 0xA9
	ret
brContinue3:
	cpi acc, 'Ф'
	breq brRuF
	cpi acc, 'Х'
	breq brRuX
	cpi acc, 'Ц'
	breq brRuCe
	cpi acc, 'Ч'
	breq brRuCh
	cpi acc, 'Ш'
	breq brRuSh
	cpi acc, 'Щ'
	breq brRuSh
	cpi acc, 'Ъ'
	breq brRubb
	jmp brContinue4
brRuF:	ldi acc, 0xAA
	ret
brRuX:	ldi acc, 0x58
	ret
brRuCe:	ldi acc, 0x75
	ret
brRuCh:	ldi acc, 0xAB
	ret
brRuSh:	ldi acc, 0xAC 
	ret
brRubb:	ldi acc, 0xAD
	ret
brContinue4:
	cpi acc, 'Ы'
	breq brRubi
	cpi acc, 'Ь'
	breq brRubm
	cpi acc, 'Э'
	breq brRuYe
	cpi acc, 'Ю'
	breq brRuYu
	cpi acc, 'Я'
	breq brRuYa
	cpi acc, ' '
	ret

brRubi:	ldi acc, 0xAE
	ret
brRubm:	ldi acc, 0x62
	ret
brRuYe:	ldi acc, 0xAF
	ret
brRuYu:	ldi acc, 0xB0 
	ret
brRuYa:	ldi acc, 0xB1
	ret


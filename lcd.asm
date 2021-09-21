
CMD_WR:		; Запись команды в дисплей. Код команды в R17
			CLI
			RCALL	BusyWait

			CBI		PORTB,6; снятие E
			RJMP	WR_END

DATA_WR:	; Запись данных в дисплей. Код данных в R17
			CLI
			RCALL	BusyWait
			
			SBI		PORTB,6; установка RW;SBI		PORTB,6; установка RW
WR_END:		
			CBI		PORTB,5; снятие Е
			SBI		PORTB,7; установка флага записи в DDRAM 
			
			LDI		R16,0xFF
			OUT		DDRE,R16; установка порта на вывод
			OUT		PORTE,R17; подтяжка

			RCALL	LCD_Delay

			CBI		PORTB,7

			LDI		R16,0		; LCD Data Port
			OUT		DDRE,R16	; Выставить на вход

			LDI		R16,0xFF	; Установить подтяжку
			OUT		PORTE,R16

			SEI
			RET
BusyWait:	
			CBI		PORTB,6
			SBI		PORTB,5

BusyLoop:	SBI		PORTB,7
			
			RCALL	LCD_Delay

			IN		R16,PINE   ; чтение в R16 из порта B

            CBI		PORTB,7    ; снимаем E
                      	
            ANDI	R16,0x80   ; проверка флага BF на 0
			BRNE	BusyLoop
			RET
		
LCD_Delay:	LDI		R16,6
L_loop:		DEC		R16
			BRNE	L_loop
			RET

DATA_WR_from_Z:	;в Z адрес массива с данными
DATA_WR_from_Z_loop:
			lpm
			mov 	acc, r0
			cpi 	acc, 'e'
			breq 	DATA_WR_from_Z_exit
	
			cpi 	acc, 0x0f
			brlo 	DATA_WR_from_Z_coords
	
			RCALL 	symToHex
			mov		r17, acc

			RCALL	DATA_WR
			adiw 	ZL, 1

			jmp 	DATA_WR_from_Z_loop

DATA_WR_from_Z_coords:	
			adiw 	ZL, 1
			lpm

			mov 	R17, r0
			ORI		R17,(1<<7)
	
			cpi 	acc, 1
			breq 	DATA_WR_from_Z_row1

DATA_WR_from_Z_coodsDone: 
			RCALL 	CMD_WR
			adiw 	ZL, 1
			jmp 	DATA_WR_from_Z_loop

DATA_WR_from_Z_exit:
			ret

DATA_WR_from_Z_row1:
			ORI 	R17, 0x40
			jmp 	DATA_WR_from_Z_coodsDone


	

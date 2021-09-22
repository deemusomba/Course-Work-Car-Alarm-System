;-----��������� ������-----;
keyBindings:
	;��� �����-�� ������ ��� ������	
	mov acc, r0
	cpi acc, 10
	brge keyBindingsLetters
	call keyBindingsNumbers

keyBindingsRet:	ret

keyBindingsNumbers:
	mov acc, menuModes
	andi acc, 0xF0
	cpi acc, 0; ���� ����� ����� (�����) == 0, �� ������ ���
	breq keyBindingsEnterMode
	
	mov acc, menuModes
	andi acc, 0x0F
	cpi acc, 0;���� ����� ����� (�������) == 0, �� ������ ���
	breq keyBindingsEnterSubMode

	call keyBindingsEnteringInModes; ����� - ��� ���� ������ �������
	ret

keyBindingsEnterMode: 			;���� ������ ����
	mov acc, r0
	cpi acc, 0x06; ���������� �������, �� +1
	brge keyBindingsRet; ��� ������ ������, ������
	mov acc, r0
	andi menuModes, 0x0F
	lsl acc
	lsl acc
	lsl acc
	lsl acc
	add menuModes, acc	;�������� �����
	jmp keyBindingsRet
keyBindingsEnterSubMode:		;���� ������ �������
	mov acc, r0
	andi menuModes, 0xF0
	add menuModes, acc			;����� ����� �������
	jmp keyBindingsRet
	
keyBindingsLetters:
	mov acc, r0
	cpi acc, 0x0A
	breq keyBindingsLetterACalling
	cpi acc, 0x0B
	breq keyBindingsLetterB
	cpi acc, 0x0C
	breq keyBindingsLetterC
	cpi acc, 0x0D
	breq keyBindingsLetterD	
	jmp keyBindingsRet

keyBindingsLetterACalling: call keyBindingsLetterA
	ret
keyBindingsLetterBCalling: call keyBindingsLetterB
	ret
keyBindingsLetterCCalling: call keyBindingsLetterC
	ret
keyBindingsLetterDCalling: call keyBindingsLetterD
	ret
;keyBindingsLetterECalling: call keyBindingsLetterE
;keyBindingsLetterFCalling: call keyBindingsLetterF

keyBindingsLetterA:
	;���� ������� ���� - ������ �� ������
	mov acc, menuModes
	andi acc, 0xF0
	cpi acc, 0
	breq keyBindingsRet
	;���� ������ �����, �� ������� ������ ��������
	mov acc, menuModes
	andi acc, 0x0F
	cpi acc, 0
	breq keyBindingLetterASubMode
	;���� ������ ��������, �� ���� � �������
	sbr programFlags, 8;	��������� ����� �������� � ��������
	call keyBindingsEnteringInModes
	jmp keyBindingsRet

keyBindingLetterASubMode:	;��� ����� � ����� ����������, ������� ����� ������ �� ���
	mov acc, menuModes
	andi acc, 0xF0
	ori acc, 0x01
	mov menuModes, acc
	jmp keyBindingsRet2

keyBindingsLetterB:
	mov acc, menuModes
	cpi acc, 0				;���� ������� ���� - �� ������ �� ������
	breq keyBindingsRet2

	mov acc, menuModes
	andi acc, 0x0f			
	cpi acc, 0				;���� �������� �� ������, �� ����� � ������� ����
	breq keyBindingsBackFromMode
	;������ ��� �������
	
	sbrc programFlags, 3	;���� ���� "� ������" ����������, �� ����� ���
	jmp keyBindingsLetterBExit	;����� �� ��������� � ������� � ������ ����������
		
	andi menuModes, 0xf0	;����� ������� �� ������ ���������� ������� � ������ ������� ����	
	jmp keyBindingsRet2

keyBindingsLetterBExit:	
	cbr programFlags, 8
	jmp keyBindingsRet2

keyBindingsBackFromMode:
	ldi menuModes, 0x00		;����� � ������� ����
	jmp keyBindingsRet2

keyBindingsEnteringInModes:
	ret
keyBindingsLetterC:
	jmp keyBindingsRet2
keyBindingsLetterD:
	mov acc, menuModes
	andi acc, 0xf0
	cpi acc, 0x60; ���������� �������, �� +1
	brge keyBindingsBackToMainMenu
	ldi acc2, 0x10
	add acc, acc2
	mov menuModes, acc
	jmp keyBindingsRet2
keyBindingsBackToMainMenu:
	ldi acc, 0x00
	mov menuModes, acc
	jmp keyBindingsRet2

keyBindingsRet2: jmp keyBindingsRet

;-----��������� ������-----;
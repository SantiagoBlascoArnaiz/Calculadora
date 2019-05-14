.data
Formula : .space 1000
Convertir: .space 1000
PilaNum: .space 1000
PilaOp: .space 1000
E: .space 1000
F: .space 1000
B: .asciiz "Introduzca la cadena de operaciones: "
C: .asciiz "Se ha introducido un carácter invalido.\n"
D: .asciiz "Ha introducido un número demasiado grande.\n"
G: .asciiz "No se puede dividir entre 0.\n"
H: .asciiz "Se ha producido un desbordamiento en la multiplicación.\n"
I: .asciiz "Se ha producido un desbordamiento en la suma.\n"
J: .asciiz "Se ha producido un desbordamiento en la resta.\n"
K: .asciiz "No se han emparejado todos los préntesis.\n"


.text
main:
	Principio:
		la $a0,B #Imprime mensaje
		li $v0 4
		syscall
		
		la $a0,Formula 
		addi $a1,$zero,190
		li $v0 8
		syscall
		
		lb $s0,0($a0)
		beq $s0,10,Principio
	
		jal corregirCadena
		beq $v1,7,ParentesisMal
		jal leerOperacion
		
		beq $v1,1,DemasiadoLarga
		beq $v1,2,CaracterIncorrecto
		beq $v1,3,DivisionPorCero
		beq $v1,4,MultiplicacionDesborda
		beq $v1,5,SumaDesborda
		beq $v1,6,RestaDesborda
		
		
		move $a0,$v0
		la $a1,E
		
		jal decimalstring
		
		
		la $a0,E
		li $v0 4
		syscall
	fin:
		li $v0 10
		syscall
	DemasiadoLarga:
		la $a0,D #Imprime mensaje
		li $v0 4
		syscall
		
		j fin

	CaracterIncorrecto:
		la $a0,C #Imprime mensaje
		li $v0 4
		syscall
		
		j fin
	DivisionPorCero:
		la $a0,G #Imprime mensaje
		li $v0 4
		syscall
		
		j fin
	MultiplicacionDesborda:
		la $a0,H #Imprime mensaje
		li $v0 4
		syscall
		
		j fin
	SumaDesborda:
		la $a0,I #Imprime mensaje
		li $v0 4
		syscall
		
		j fin
		
	RestaDesborda:
		la $a0,J #Imprime mensaje
		li $v0 4
		syscall
		
		j fin
	ParentesisMal:
		la $a0,K #Imprime mensaje
		li $v0 4
		syscall
		
		j fin
		
conversor:
		add $t1,$zero,$zero 
		add $t3,$zero,$zero #Contador para controlar la longitud de la cadena
		addi $t2,$zero,1 #Si vale 0 el número leido es positivo, si vale -1 es negativo
		
		lb $t0,0($a0) #Cargamos el primer carácter
		beq $t0,10,Salir #Por si es una cadena vacia
		
		#Solo los hacemos la primera vez apra leer (si lo tuviera) el signo
		beq $t0,45, negativo #Si es un guion el número es negativo
		beq $t0,43, positivo #Si es un guion el número es negativo
		
	inicio:
		lb $t0,0($a0) 
		beq $t0,10,Salir 
		
		#Restricciones para que solo acepte números codificados en ascii
		
		ble $t0, 47, invalido 
		bge $t0, 58, invalido
		
		addi $t0,$t0, -48 #Pasamos el número ascii a número decimal
	decimal:
		addi $v1,$zero, 0 #Si estamos ejecutando este código quiere decir que todo ha ido bien, por tanto v1 vale 0
				
		add $t1,$t0,$t1 #Acumulamos el resultado
		
		addi $a0,$a0,1 #Pasamos a la siguiente dirección
		lb $t0,0($a0) #Cargamos el siguiente byte antes de continuar por si este fuese el fin de linea o el salto de línea terminar el bucle
		ble $t0, 47, Salir
		bge $t0, 58, Salir
		
		
		beq $t3,8,larga #Limitamos el tamaño de la cadena al tamaño de los registros
		
		addi $t3,$t3,1
		mul $t1,$t1,10 #Pasamos a la siguiente unidad
		
		j inicio
	
	larga:
		addi $v1,$zero, 1
		j Salir
	
	invalido:
		addi $v1,$zero,2
		j Salir
	vacia:
		addi $v1,$zero,8
		j Salir
	negativo:
		addi $t2,$zero,-1 #$t5 pasa a valer 5,indicandonos que el número es negativo
		addi $a0,$a0,1 #Pasamos a la siguiente dirección
		j inicio
	positivo:
		addi $t2,$zero,1 #$t5 pasa a valer 5,indicandonos que el número es negativo
		addi $a0,$a0,1 #Pasamos a la siguiente dirección
		j inicio
		
	Salir:
		
		mul $t1,$t1,$t2  #Sino lo hacemos negativo multiplicandolo por $t5 que vale -1

		move $v0,$t1
		
		jr $ra

decimalstring:
		addi $t4,$zero, 10
		la $t5,F 
		
		move $t2,$a0 #El número a convertir
		move $t0,$t5 #Posicion de memoria inicial
		
		beqz $t2,ceroH
		
		bge $t2,0,bucleH
		addi $t3,$zero, 45
		sb  $t3, 0($a1) #Almacenamos el carácter para formar la cadena
		addi $a1,$a1, 1 
		
		sub $t2,$a0,$a0	#Hayamos el opuesto restandose a si mismo 2 veces
		sub $t2,$t2,$a0
	bucleH:
		beqz $t2,salirH
		div $t2,$t4
		
		mflo $t2 #Cociente
		mfhi $t3 #Resto
		
		addi $t3, $t3, 48
		
		sb  $t3, 0($t5) #Almacenamos el carácter para formar la cadena
		addi $t5,$t5, 1 
		
		j bucleH
	salirH:
		addi $t5,$t5, -1 
	bucleFinalH:
		lb $t6, 0($t5)
		sb $t6, 0($a1)
		
		beq $t5,$t0,finalH
		
		addi $t5,$t5,-1
		addi $a1,$a1,1
		
		j bucleFinalH
	ceroH:
		addi $t2,$t2,48
		sb  $t2, 0($a1)
	finalH:
		addi $a1,$a1, 1 
		sb  $zero, 0($a1) #Almacenamos el carácter para formar la cadena
		
		jr $ra
	
leerOperacion:
		move $t9,$ra

		move $t8,$zero #Registro de la precedencia
		
		la $t7, PilaOp
		sb $zero,0($t7) #Incluimos un 0 al principio para a la hora de vaciar la pila nos sirva como fin
		addi $7,$7,1
		
		la $t6, PilaNum
	Operacion:
		lb $t5,0($a0)
		addi $a0,$a0,1
		
		beqz $t5,SacaPilaOp
				
		ble $t5,39,InvalidoOp
		
		beq $t5,40,AbreParentesis
		beq $t5,41,SacaPilaOp
		beq $t5,42,Nivel2
		beq $t5,43,Nivel1
		beq $t5,45,Nivel1#-
		beq $t5,47,Nivel2#/
		
		beq $t5,48,ComprobarHexadecimal
	NumeroDecimal:
		ble $t5,47,InvalidoOp
		bge $t5,58,InvalidoOp
		j Numero
	ComprobarHexadecimal:
		lb $t5,0($a0)
		beq $t5,88,NumeroHexadecimal
		beq $t5,120,NumeroHexadecimal
		addi $a0,$a0,-1
		lb $t5,0($a0)
		addi $a0,$a0,+1
		j NumeroDecimal
	Nivel2:
		ble $t8,1,Precedencia2
		beq $t8,2,MismaPrecedencia2
		addi $t8,$zero, 2
		j SacaPilaOp
	Nivel1:
		ble $t8,0,Precedencia1
		beq $t8,1,MismaPrecedencia1
		addi $t8,$zero, 1
		j SacaPilaOp
	MismaPrecedencia1:
		addi $t7,$t7,-1
		lb $t0,0($t7)
		addi $t7,$t7,1
		bne $t0,45,Precedencia1
		sb $t0,0($t7)
		addi $t7,$t7,-1
		addi $t0,$zero,33 #Introducimos este caracter como señal para saber cuando parar de sacar la pila
		sb $t0,0($t7)
		addi $t7,$t7,2
		
		j SacaPilaOp
		
	MismaPrecedencia2:
		addi $t7,$t7,-1
		lb $t0,0($t7)
		addi $t7,$t7,1
		bne $t0,47,Precedencia2
		sb $t0,0($t7)
		addi $t7,$t7,-1
		addi $t0,$zero,33
		sb $t0,0($t7)
		addi $t7,$t7,2
		
		j SacaPilaOp
	AbreParentesis:
		addi $t8,$zero, 1
		addi $a0,$a0, -1
		lb $t5,0($a0)
		addi $a0,$a0, 1
		
		sb $t5,0($t7)
		addi $t7,$t7,1
		
		lb $t5,0($a0)
		
		bne $t5,45,Operacion
		addi $a0,$a0, 1
		
		j Numero
	Precedencia2:
		addi $t8,$zero, 2
		j MetePilaOp
	Precedencia1:
		addi $t8,$zero, 1
		j MetePilaOp
	MetePilaOp:
		sb $t5,0($t7)
		addi $t7,$t7,1
		j Operacion
	SacaPilaOp:
		addi $t7,$t7,-1
		lb $t5,0($t7)
		
		beqz $t5,FinPila
		beq $t5,33,FinPila
		beq $t5,40,FinParentesis
		
		move $t0,$t6
		addi $t0,$t0,-4

		beq $t5,42,Multiplica #*
		beq $t5,43,Suma #+
		beq $t5,45,Resta #-
		beq $t5,47,Divide #/
	FinPila:
		addi $t7,$t7,1
		addi $a0,$a0,-1
		
		lb $t5,0($a0)
		beqz $t5,Terminado
		sb $t5,0($t7)
		
		addi $t7,$t7,1
		addi $a0,$a0,1
		j Operacion
	FinParentesis:
		addi $a0,$a0,-1
		
		lb $t5,0($a0)
		beqz $t5,Terminado
		beq $t5,41,SacaPilaOp
		sb $t5,0($t7)
		
		addi $t7,$t7,1
		addi $a0,$a0,1
		j Operacion
	Multiplica:
		lw $t3,0($t0)
		addi $t0,$t0,-4
		lw $t5,0($t0)
		
		mul $t4,$t3,$t5
		xor $t3,$t3,$t5
		xor $t3,$t3,$t4
		
		slt $t3,$t3,$zero
		bne $t3, $zero,DesbordaMul
			
		mfhi $t1
		
		beqz $t1,NoDesbordaMul
		bne $t1,0xFFFFFFFF,DesbordaMul
		beqz $t4,DesbordaMul
	NoDesbordaMul:
		sw $t4,0($t0)
		
		addi $t0,$t0,8
		
		j MoverPilaNum
	Suma:
		lw $t5,0($t0)
		addi $t0,$t0,-4
		lw $t3,0($t0)

		addu $t4,$t3,$t5
		xor $t2,$t3,$t5
		slt $t2,$t2,$zero
		bne $t2,$zero,NoDesbordaSum
		xor $t2,$t4,$t3
		
		slt $t2,$t2,$zero
		bne $t2,$zero,DesbordaSum
	NoDesbordaSum:
		sw $t4,0($t0)
		
		addi $t0,$t0,8
		
		j MoverPilaNum
	Resta:
		lw $t5,0($t0)
		addi $t0,$t0,-4
		lw $t3,0($t0)
		
		subu $t4,$t3,$t5
		xor $t2,$t3,$t5
		slt $t2,$zero,$t2
		bne $t2,$zero,NoDesbordaRes
		xor $t2,$t4,$t3
		
		slt $t2,$t2,$zero
		bne $t2,$zero,DesbordaRes
	NoDesbordaRes:
		sw $t4,0($t0)
		
		addi $t0,$t0,8
		
		j MoverPilaNum
	Divide:	
		lw $t5,0($t0)
		addi $t0,$t0,-4
		lw $t4,0($t0)
		beqz $t5,DividirPorCeroOp
		
		div $t4,$t4,$t5
		sw $t4,0($t0)
		
		addi $t0,$t0,8
		
		j MoverPilaNum
	MoverPilaNum:
		lw $t4,0($t0)
		beqz $t4,PilaMovida
		
		addi $t0,$t0,-4
		sw $t4,0($t0)
		addi $t0,$t0,8
		
		beq $t0,$t6, PilaMovida
		
		j MoverPilaNum
	PilaMovida:
		addi $t6,$t6,-4
		addi $t0,$t0,-4
		sw $zero,0($t0)
		j SacaPilaOp
	Numero:
		addi $a0,$a0,-1
		jal conversor
		
		beq $v1,1,Terminado
		beq $v1,2,Terminado
		
		sw $v0,0($t6)
		addi $t6,$t6,4
		
		 j Operacion
	NumeroHexadecimal:
		addi $a0,$a0,1
		jal conversorHexadecimal
		
		beq $v1,1,Terminado
		beq $v1,2,Terminado
		
		sw $v0,0($t6)
		addi $t6,$t6,4
		
		 j Operacion
	LargaOp:
		addi $v1,$zero, 1
		j Terminado
	DividirPorCeroOp:
		addi $v1,$zero, 3
		j Terminado
	InvalidoOp:
		addi $v1,$zero,2
		j Terminado
	DesbordaMul:
		addi $v1,$zero, 4
		j Terminado
	DesbordaSum:
		addi $v1,$zero, 5
		j Terminado
	DesbordaRes:
		addi $v1,$zero, 6
		j Terminado
	Terminado:
		la $t0,PilaNum
		lw $v0,0($t0)
		move $ra,$t9
		jr $ra
	
corregirCadena:
		move $t0,$a0
		move $t1,$a0
		addi $t3,$zero,0
		
	InicioCorregir:
		lb $t2,0($t0)
		addi $t0,$t0,1
		
		beq $t2,32,InicioCorregir
		
		beq $t2,40,AbreParen
		
		beq $t2,41,CierraParen
	SigueCambiando:
		ble $t3,-1,ErrorParentesis
		beq $t2,10,CambiarSalto
		
		beq $t2,0,Cambiada
		
		sb $t2,0($t1)
		addi $t1,$t1,1
		j InicioCorregir
		
	CambiarSalto:
		sb $zero,0($t1)
		bne $t3,$zero,ErrorParentesis
		j Cambiada
	AbreParen:
		addi $t3,$t3,1
		j SigueCambiando
	CierraParen:
		addi $t3,$t3,-1
		j SigueCambiando
	ErrorParentesis:
		addi $v1,$zero, 7
	Cambiada:
		jr $ra

conversorHexadecimal:
		add $t1,$zero,$zero 
		add $t3,$zero,$zero #Contador para controlar la longitud de la cadena
	inicioHex:
		lb $t0,0($a0) #Cargamos el primer carácter
		beq $t0,10,SalirHex #Por si es una cadena vacia
		
		#Restricciones para que solo acepte los intervalos de carácteres ascii que queremos
		ble $t0, 47, invalidoHex
		bge $t0, 103, invalidoHex
		
		ble $t0, 57, numeroHex
		ble $t0, 64, invalidoHex
		ble $t0, 70, mayusculaHex
		ble $t0, 96, invalidoHex
		ble $t0, 102, minusculaHex
		
	mayusculaHex:
		addi $t0,$t0, -55
		j binarioHex
		
	minusculaHex:
		addi $t0,$t0, -87
		j binarioHex
		
	numeroHex:
		addi $t0,$t0, -48
	binarioHex:
		addi $v1,$zero, 0 #Si estamos ejecutando este código quiere decir que todo ha ido bien,por tanto v1 vale 0
		or $t1,$t1,$t0 #Añadimos el byte al resultado
		
		addi $a0,$a0,1 #Pasamos a la siguiente dirección
		lb $t0,0($a0) #Cargamos el siguiente byte antes de continuar por si este fuese el fin de linea o el salto de línea terminar el bucle
		beqz $t0,SalirHex
		beq $t0,10,SalirHex
		
		beq $t0,42,SalirHex
		beq $t0,43,SalirHex
		beq $t0,45,SalirHex
		beq $t0,47,SalirHex
		beq $t0,40,SalirHex
		beq $t0,41,SalirHex
		
		sll $t1, $t1, 4 #Desplazamos el resultado 4 bits a la izquierda para poder añadir el siguiente
		
		beq $t3,7,largaHex #Limitamos el tamaño de la cadena al tamaño de los registros
		addi $t3,$t3,1
		
		j inicioHex
	largaHex:
		addi $v1,$zero, 1
		j SalirHexE
	
	invalidoHex:
		addi $v1,$zero,2
		j SalirHexE
		
	SalirHex:
		beq $t1,0x80000000,largaHex
	SalirHexE:
		move $v0,$t1
		jr $ra
		

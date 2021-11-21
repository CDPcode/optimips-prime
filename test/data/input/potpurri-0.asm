.data

.align 2
program: .space 400
file:    .space 24
str:     .space 1004
N:       .space 4

.align 2
coop:   .word haltF, 0, 0, 0, sllvF, bneF, beqF, 0, addiF, 0, 0 ,0, andiF, oriF
	.space 40
	.word multF
	.space 28
	.word addF, 0, subF, lwF, 0, orF, 0, 0, andF, 0, 0, swF
	.space 80

haltM:  .asciiz " R halt"
sllvM:  .asciiz " R sllv " 
bneM:   .asciiz " I bne "
beqM:   .asciiz " I beq "
addiM:  .asciiz " I addi "
andiM:  .asciiz " I andi "
oriM:   .asciiz " I ori " 
multM:  .asciiz " R mult "
addM:   .asciiz " R add "
subM:   .asciiz " R sub "
lwM:    .asciiz " I lw "
orM:    .asciiz " R or "
andM:   .asciiz " R and "
swM:    .asciiz " I sw "
newL:   .asciiz "\n"
bsp:    .asciiz " "
dollar: .asciiz " $"

endline: .byte '\n'

.text

main:
	jal readfile
	la $a0, str
	lw $s0, N
	la $s1, program
mainLoop:
	beqz $s0, outLoop
	jal toint
	sw $v0, ($s1)
	addi $s0, $s0, -1
	addi $a0, $a0, 10
	addi $s1, $s1, 4
	b mainLoop
outLoop:
	la $a2, program
	lw $s0, N
mainLoop2:
	beqz $s0, outLoop2
	jal printInst
	addi $a2, $a2, 4
	addi $s0, $s0, -1
	b mainLoop2
outLoop2:
	li $v0, 10
	syscall


toint:				#recibe en $a0 la direccion del primer char del string a traducir
				#retorna en $v0 el entero deseado
	li $v0, 0
	li $t0, 0
	move $t1, $a0
tointLoop:
	bne $t0, 8, tointNotReturn
	j tointRet
tointNotReturn:
	lb $t2, ($t1)
	andi $t3, $t2, 0xf0
	beq $t3, 0x30, tointDigit
	andi $t3, $t2, 0xf
	addi $t3, $t3, 9
	sll $v0, $v0, 4
	or $v0, $v0, $t3
	b tointInc
tointDigit:
	andi $t3, $t2, 0xf
	sll $v0, $v0, 4
	or $v0, $v0, $t3
tointInc:
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	b tointLoop
tointRet:
	jr $ra
	
readfile:
	li $v0, 8
	la $a0, file
	li $a1, 119
	syscall
	move $t0, $a0
	lb $t2, endline
	li $t3, 0
nloop:
	lb $t1, 0($t0)
	beq $t1, $t2, changen
	beq $t1, $t3, endnloop
	addi $t0, $t0, 1
	b nloop
changen:
	sb $t3, 0($t0)
endnloop:
	li $v0, 13
	li $a1, 0
	li $a2, 0
	syscall
	move $a0, $v0
	li $v0, 14
	la $a1, str
	li $a2, 1000
	syscall
	li $t2, 10
	div $v0, $t2
	mflo $t1
	sw $t1, N
	jr $ra
		
printInst:				#Recibe en $a2 la direccion de la instruccion a traducir
	lw $a1, 0($a2)
	li $v0, 34
	move $a0, $a1
	syscall
	
	andi $t0, $a1, 0xfc000000
	srl $t0, $t0, 24
	lw $t1, coop($t0)
	
	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jalr $t1

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp

	li $v0, 4
	la $a0, newL
	syscall
	jr $ra
	
haltF:  				#Recibe en $a1 la instruccion de halt (en hexadecimal)
	li $v0, 4
	la $a0, haltM
	syscall
	jr $ra
	
sllvF:  				#Recibe en $a1 la instruccion de sllv (en hexadecimal)
	li $v0, 4
	la $a0, sllvM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstR

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp

	jr $ra
bneF:     				#Recibe en $a1 la instruccion de bne (en hexadecimal)
	li $v0, 4
	la $a0, bneM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstI

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
beqF:     				#Recibe en $a1 la instruccion de beq (en hexadecimal)
	li $v0, 4
	la $a0, beqM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstI

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
addiF:    				#Recibe en $a1 la instruccion de addi (en hexadecimal)
	li $v0, 4
	la $a0, addiM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstI

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
andiF:    				#Recibe en $a1 la instruccion de andi (en hexadecimal)
	li $v0, 4
	la $a0, addiM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstI

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
oriF:     				#Recibe en $a1 la instruccion de ori (en hexadecimal)
	li $v0, 4
	la $a0, oriM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstI

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
multF:    				#Recibe en $a1 la instruccion de mult (en hexadecimal)
	li $v0, 4
	la $a0, multM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstR

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
addF:   				#Recibe en $a1 la instruccion de add (en hexadecimal)
	li $v0, 4
	la $a0, addM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstR

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
subF:     				#Recibe en $a1 la instruccion de sub (en hexadecimal)
	li $v0, 4
	la $a0, subM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstR

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
lwF:      				#Recibe en $a1 la instruccion de lw (en hexadecimal)
	li $v0, 4
	la $a0, lwM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstI

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
orF:      				#Recibe en $a1 la instruccion de or (en hexadecimal)
	li $v0, 4
	la $a0, orM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstR

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
andF:     				#Recibe en $a1 la instruccion de and (en hexadecimal)
	li $v0, 4
	la $a0, andM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstR

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
swF:      				#Recibe en $a1 la instruccion de sw (en hexadecimal)
	li $v0, 4
	la $a0, swM
	syscall

	move $fp, $sp
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $fp, 8($sp)
	
	jal printInstI

	lw $ra, 4($sp)
	lw $fp, 8($sp)
	move $sp, $fp
	
	jr $ra
	
printInstR:				#Recibe en $a1 la instruccion tipo R a imprimir
	andi $t0, $a1, 0xf800
	srl $t0, $t0, 11
	li $v0, 4
	la $a0, dollar
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	andi $t0, $a1, 0x3e00000
	srl $t0, $t0, 21
	li $v0, 4
	la $a0, dollar
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	andi $t0, $a1, 0x1f0000
	srl $t0, $t0, 16
	li $v0, 4
	la $a0, dollar
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	jr $ra
	
printInstI:				#Recibe en $a1 la instruccion tipo R a imprimir
	andi $t0, $a1, 0x1f0000
	srl $t0, $t0, 16
	li $v0, 4
	la $a0, dollar
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	andi $t0, $a1, 0x3e00000
	srl $t0, $t0, 21
	li $v0, 4
	la $a0, dollar
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, bsp
	syscall
	
	li $v0, 1
	andi $a0, $a1, 0xffff
	syscall
	
	jr $ra
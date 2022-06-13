.text
	xor $a0,$a0,0
	add $a0, $a0, 8
	la $a1,string
	jal crc32calc			# v0 = crc32
	
	lui $v0,0x0000
	ori $v0,0x0A
	syscall				#exit
	
	
crc32calc:
	addi $sp, $sp, -4		# char cnt
	la $t0, value
	lw $t1,0($t0)			# t1 = value
	la $t0, pattern
	lw $t2,0($t0)			# t2 = pattern

nextchar:
	lui $v0, 0x0000			# v0 = crc = 0
	lb $t4, 0($a1)			# byte = string[index]
	
	sw $a0, 0($sp)			# push char cnt
	xor $t4, $t4, $t1		# byte = byte ^ value
	andi $t4, $t4, 0xFF		# byte = byte & 0xFF
	lui $a0, 0x0000
	ori $a0, 0x0008			# bit cnt = 8
next_bit:
	add $t5,$zero, $t4	
	xor  $t5, $t5,$v0		# t5  byte ^ crc
	andi $t5, $t5, 0x01		# t5  byte & 0x01
	beq $t5, 0, ZeroEqual
	srl $v0, $v0, 1			# crc >> 1
	xor $v0, $v0, $t2		# crc = (crc>>1) ^ pattern
	j Exit
ZeroEqual:
	srl $v0, $v0, 1			# crc >> 1
Exit:	
	srl $t4, $t4,1			# byte >> 1
	sub $a0, $a0,1
	bne $a0, 0, next_bit
	srl $t1, $t1,8
	xor $t1, $t1, $v0		# val = (val>>8) ^ crc
	
	addi $a1, $a1, 1		# inc string[index]
	lw $a0, 0($sp)
	sub $a0, $a0, 1
	bne $a0, 0, nextchar
	lui $v0, 0x0000		# crc = -1 - val
	sub $v0,$v0, 1
	sub $v0, $v0, $t1
	
	addi $sp, $sp, 4
	jr $ra				# return

.data
value: 		.word   0xFFFFFFFF        # value
pattern: 	.word  	0xEDB88320        # pattern
string: 	.asciiz "test1234"
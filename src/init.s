	INCLUDE	"hardware/custom.i"
	INCLUDE "hardware/cia.i"

	XREF	__prg_start
	XREF	__copy_len
	XREF	_bss_start
	XREF	start


	SECTION		"init",code

		dc.w	$1111
		jmp	$F00008
init:
						; $F00008
	;delay
		move.l	#$020000,d0
delay:		subq.l	#1,d0 
		bgt.s	delay

	;first access to cia-a switch off overlay (Gayle based systems)
		move.b	#3,_ciaa+ciaddra
		move.b	#2,_ciaa

		lea	_custom,a5
		move.w	#$7FFF,d0
		move.w	d0,intena(a5)		;disable all interrupts
		move.w	d0,intreq(a5)		;clear all pending interrupts
		move.w	d0,dmacon(a5)		;disable all DMA

		;and.w	#$2700,SR
		;move.w	#$2300,SR

	;copy code and data to RAM
		lea	__prg_start(pc),a0
		lea	start,a1
		move.l	a1,a2
		move.l	#__copy_len,d0
.copy:		move.w	(a0)+,(a1)+
		subq.l	#2,d0
		bne.b	.copy

	;clear bss
		lea	__bss_start,a0
		move.l	#__bss_len,d0
		moveq	#0,d1
.clear:		move.w	d1,(a0)+
		subq.l	#2,d0
		bne.b	.clear

	;lets starts
		jmp	(a2)

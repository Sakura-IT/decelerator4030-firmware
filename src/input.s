	INCLUDE	"hardware/custom.i"
	INCLUDE "hardware/cia.i"

; duration for keyboard SP handshaking
;
;we should wait at least 85us for synchronization
;85/1.3968255 = 60.85 
;
KEYBOARD_WAIT	EQU	61
TIMERB_LO	EQU	KEYBOARD_WAIT&$ff
TIMERB_HI	EQU	KEYBOARD_WAIT>>8

;-----------------------------------------------------------------------------
;a5 - _custom

	XDEF	SetKeyboard
SetKeyboard:
		lea	_ciaa,a2

		moveq	#8,d0
		move.w	d0,intena(a5)		;disable PORTS ints
		move.w	d0,intreq(a5)		;clear pending PORTS ints
		move.b	#$7f,ciaicr(a2)		;disable all CIA-A ints
		move.b	#TIMERB_LO,ciatblo(a2)
		move.b	#TIMERB_HI,ciatbhi(a2)
		move.b	#$18,ciacrb(a2)		;one-shot mode and load
		sub.l	a0,a0
		lea	IntLevel2Ports(pc),a1
		move.l	a1,$68(a0)		;set level 2 Interrupt Vector
		move.w	#$c008,intena(a5)	;enable PORTS int
		move.b	#$88,ciaicr(a2)		;enable CIAA SP interrupt
		rts

;-----------------------------------------------------------------------------

IntLevel2Ports:
		movem.l	d0-d1/a0-a2,-(sp)

		lea	_custom,a0
		moveq	#8,d0

	;check if is it level 2 interrupt
		move.w	intreqr(a0),d1
		and.w	d0,d1
		beq.b	.end

	;check if SP cause interrupt 
		lea	_ciaa,a1 
		move.b	ciaicr(a1),d1
		and.b	d0,d1
		beq.b	.end

		move.b	ciasdr(a1),d1	;get kycode
		or.b	#$40,ciacra(a1) ;start SP handshaking
		or.b	#1,ciacrb(a1)	;start timer

	;store key
		lea	keys(pc),a2
		not.b	d1
		lsr.b	#1,d1
		scs	(a2,d1.w)

	; delay min 85us
.wait
		moveq	#2,d1
		and.b	ciaicr(a1),d1
		beq.b	.wait

		and.b	#$bf,ciacra(a1)	;switch SP back to input

.end
	; clear PORTS interrupt
		move.w	d0,intreq(a0)
		nop
		movem.l	(sp)+,d0-d1/a0-a2
		rte
;=============================================================================

	DATA
	XDEF keys
keys:		ds.b	$80

;-----------------------------------------------------------------------------
;ArrowInit - Initialize arrow variables
;
;in
;	d0 - initial position x
;	d1 - initial position y
;	d2 - up boundary for position y
;	d3 - down boundary for position y
;
	XDEF	ArrowInit
ArrowInit:
		lea	arrowPosX,a0
		movem.w	d0-d3,(a0)
		rts
;-----------------------------------------------------------------------------
;
;
;
	XDEF	ArrowDown
ArrowDown:
		lea	arrowPosY,a0
		move.w	(a0),d0
		move.w	arrowBoundDown,d1
		addq.w  #8,d0

		cmp.w	d1,d0
		ble.b	.exit
   
		move.w	d1,d0 

.exit		move.w  d0,(a0)
		rts

;-----------------------------------------------------------------------------
	XDEF	ArrowUp
ArrowUp:
		lea	arrowPosY,a0
		move.w	(a0),d0
		move.w	arrowBoundUp,d1
		subq.w	#8,d0

		cmp.w	d1,d0
		bge.b	.exit

		move.w	d1,d0

.exit		move.w	d0,(a0)
		rts

;-----------------------------------------------------------------------------

	BSS

arrowPosX:	ds.w	1
	XDEF arrowPosY
arrowPosY:	ds.w	1

arrowBoundUp:	ds.w	1
arrowBoundDown:	ds.w	1

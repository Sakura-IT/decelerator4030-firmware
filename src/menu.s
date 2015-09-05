
	INCLUDE	menu.i


	XREF	PrintMsg
;-----------------------------------------------------------------------------
;MenuInit - Initiate menu items. The First item will be lighted,
; rest will have color MENU_COLOR_NORMAL
;
;in
;	a0 - menu items structure
;
;crash
;	a0,d0,d1
;
;out
;	-
	XDEF	MenuInit
MenuInit:
		move.w	(a0)+,d0		;get amount of menu items
		bmi.b	.exit			;sanity check

		addq.l	#4,a0			;go to color offset
		move.w	#MENU_COLOR_LIGHT,(a0)	;first item to light color
		subq.w	#1,d0
		bmi.b	.exit
	;set other entries to normal color
		moveq	#MENU_COLOR_NORMAL,d1
.loop		addq.l	#8,a0			;go to next color offset
		move.w	d1,(a0)
		dbf	d0,.loop

.exit		rts

;-----------------------------------------------------------------------------
;MenuPrint - Prints menu on screen
;
;in
;	a1 - menu items
;
	XDEF	MenuPrint
MenuPrint:
		move.w	(a1)+,d4		;get amount of menu items
.loop		movem.w	(a1)+,d0-d3		;positions color and offset 
		lea	(a1,d3.w),a0		;get correct message pointer
		movem.l	d4/a1,-(sp)
		bsr	PrintMsg
		movem.l	(sp)+,d4/a1
		dbf	d4,.loop
		rts

;-----------------------------------------------------------------------------
;MenuUpdate - update color text in menu
;
;in
;	a0 - menu items
;	d4 - pos y
;
	XDEF	MenuUpdate
MenuUpdate:

	;copy for later usage
		move.l	a0,a1

		move.w	(a1),d0			;get amount of menu items
		moveq	#MENU_COLOR_LIGHT,d1
		subq.w	#2,a1
.loop
		addq.w	#8,a1
		cmp.w	(a1),d1
		dbeq	d0,.loop

		move.w	#MENU_COLOR_NORMAL,(a1)			;set color
		subq.w	#4,a1

		movem.l	a0/d4,-(sp)
		movem.w	(a1)+,d0-d3
		lea	(a1,d3.w),a0
		bsr	PrintMsg
		movem.l	(sp)+,a0/d4

		move.l	a0,a1
		move.w	(a1),d0
		subq.w	#4,a1
.loop1
		addq.w	#8,a1
		cmp.w	(a1),d4
		dbeq	d0,.loop1

		move.w	#MENU_COLOR_LIGHT,2(a1)
		subq.w	#2,a1
		movem.w	(a1)+,d0-d3
		lea	(a1,d3.w),a0
		bsr	PrintMsg
		rts

;-----------------------------------------------------------------------------

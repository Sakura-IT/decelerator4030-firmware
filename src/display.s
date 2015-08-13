
	INCLUDE	"display.i"

	INCLUDE	"hardware/custom.i"
	INCLUDE	"hardware/dmabits.i"
	
;-----------------------------------------------------------------------------
	XDEF SetDisplay
SetDisplay:
	;set Colors
		lea	color(a5),a0
		move.w	#$675,(a0)+
		move.w	#$90a,(a0)+
		move.w	#$cfa,(a0)+

	;set Display
		move.l	#copperlist,cop1lc(a5)
		move.w	d0,copjmp1(a5)
		move.w	#DMAF_SETCLR|DMAF_MASTER|DMAF_RASTER|DMAF_COPPER,dmacon(a5)
		rts

;-----------------------------------------------------------------------------
;DoCopperList - make copperlist 
;
;this routine should make copperlist for vga and for pal depend from 
;trigger vgaOrPal
;
	XDEF DoCopperList
DoCopperList:
		lea	copperlist,a1
		lea	copperData(pc),a0
		moveq	#COPPERDATA_SIZE-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop

	;sprites
		moveq	#16-1,d0
		moveq	#2,d2
		swap	d2
		move.w	#sprpt,d1
		swap	d1
		move.l	#fakeSprite,d3

.sprites	swap	d3
		move.w	d3,d1
		move.l	d1,(a1)+
		add.l	d2,d1
		dbf	d0,.sprites

	;planes
		moveq	#BPL-1,d0
		move.w	#bplpt,d1
		swap	d1
		move.l	#screen,d3
		moveq	#BROW,d4

.planes		swap	d3
		move.w	d3,d1
		move.l	d1,(a1)+
		add.l	d2,d1
		swap	d3
		move.w	d3,d1
		move.l	d1,(a1)+
		add.l	d2,d1
		add.l	d4,d3
		dbf	d0,.planes

	;add end copper list
		moveq	#-2,d0
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		rts
;-----------------------------------------------------------------------------
;PrintMsg - print message on screen with position x,y and color.
;in
;	d0 - pos x
;	d1 - pos y
;	d2 - color
;	a0 - msg
;
;out
;	-
;
;crash	d0-d7,a0-a4
;
	XDEF	PrintMsg
PrintMsg:
		lea	fonts,a1
		lea	screen,a2

		move.l	#LINE,d5

	;calculate y pos
		mulu	d5,d1
		add.l	d1,a2

		move.l	#BROW,d5
.loop
	;calculate x pos
		move.w	d0,d1
		lsr.w	#3,d1
		and.w	#$fe,d1	;offset x
		move.l	a2,a4
		add.w	d1,a4
		moveq	#15,d1
		and.w	d0,d1
		addq.w	#8,d1

	;get char
		moveq	#0,d3
		move.b	(a0)+,d3
		beq.b	.exit
	;calculate font 
		lsl.w	#3,d3
		lea	(a1,d3.w),a3

		moveq	#8-1,d3	;height of font

.doChar
		moveq	#0,d4
		move.b	(a3)+,d4	;get font line
		ror.l	d1,d4		;adjust it
		move.l	d4,d6
		not.l	d6
		moveq	#0,d7
.color		btst	d7,d2
		beq.b	.and
		or.l	d4,(a4)
		bra	.next
.and		and.l	d6,(a4)
.next		addq.b	#1,d7
		add.l	d5,a4
		cmp.b	#BPL,d7
		bne	.color
		dbf	d3,.doChar
		addq.w	#8,d0		;add width of font
		bra.b	.loop
.exit		rts

;-----------------------------------------------------------------------------
;in
;	d0 - pos x
;	d1 - pos y
;	dx - char
PrintChar:

		lea	fonts,a0
		lea	screen,a1

	;calculate y pos
		mulu	#LINE,d1
		add.l	d1,a1

	;calculate x pos
		move.w	d0,d1
		lsr.w	#3,d0
		and.w	#$fe,d0
		and.w	#$f,d1
		addq.w	#8,d1
		add.w	d0,a1

	;char
		lsl.w	#3,d2
		add.w	d2,a0

		moveq	#8-1,d0
		move.l	#LINE,d3
.loop
		moveq	#0,d2
		move.b	(a0)+,d2
		ror.l	d1,d2
		or.l	d2,(a1)
		add.l	d3,a1
		dbf	d0,.loop
		rts

;-----------------------------------------------------------------------------

;=============================================================================

	DATA

copperData:
		dc.w	diwstrt,$2c81
		dc.w	diwstop,$2cc1
		dc.w	ddfstrt,$003c
		dc.w	ddfstop,$00d4 
		dc.w	bplcon0,BPL*$1000+$8200
		dc.w	bplcon1,$0000
		dc.w	bplcon2,0
		dc.w	bpl1mod,MODULO
		dc.w	bpl2mod,MODULO
copperEnd:

fakeSprite:	dc.l	0,0,0,0

COPPERDATA_SIZE	=	(copperEnd-copperData)/4

fonts:		incbin	"rawfonts.bin"
;=============================================================================

	BSS
;COPPERLIST_COLORS	= 3

COPPERLIST_SIZE	= COPPERDATA_SIZE+16+BPL*2+2	;+COPPERLIST_COLORS

copperlist:	ds.l	COPPERLIST_SIZE

	XDEF	screen
screen:		ds.b	BROW*BPL*HEIGHTBPL

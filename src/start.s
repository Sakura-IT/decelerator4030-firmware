
	INCLUDE	"hardware/custom.i"
	INCLUDE	"menu.i"
	INCLUDE	"display.i"
	INCLUDE "input.i"

	XREF	MenuPrint
	XREF	screen
	XREF	DoCopperList
	XREF	SetDisplay
	XREF	SetKeyboard


	GLOBAL start

SET_MAIN_FNC	MACRO
		lea	\1(pc),a0
		lea	mainFunction(pc),a1
		move.l	a0,(a1)
	ENDM


	CODE

;=============================================================================
;-----------------------------------------------------------------------------
;
;in	a5 - _custom
;
start:
		lea	$40000,sp	;TODO - perhaps better place for stack pointer should be chosen


		bsr	DoCopperList
		bsr	SetDisplay

		move.w	#$2100,SR	;allow int level 2
		bsr	SetKeyboard

		SET_MAIN_FNC	InitMainMenu

MainLoop:
		bsr	WaitVB

	;check exit 
		tst.b	programExit(pc)
		bne.b	.exit

	;call function
		move.l	mainFunction(pc),a0
		move.l	a0,d0			;just check null function
		beq.b	.exit			;and do exit for that
		jsr	(a0)


		lea	keys(pc),a0
		tst.b	$45(a0)
		beq	.mm

		move.w	#$500,color(a5)

.mm		bra.b	MainLoop

.exit
Nothing:	rts

;-----------------------------------------------------------------------------

InitMainMenu:
		SET_MAIN_FNC MainMenuLoop

		bsr	CopyLogo

		lea	menuItems(pc),a0
		bsr	MenuInit
		lea	menuItems(pc),a1
		bsr	MenuPrint

		rts

;-----------------------------------------------------------------------------
MainMenuLoop:

	;check cursor down
		lea	keys(pc),a0
		tst.b	KEY_CURSOR_DOWN(a0)
		bne	.up

.up
		tst.b	KEY_CURSOR_UP(a0)
		bne	.enter

.enter
		tst.b	KEY_ENTER(a0)
		bne	.exit

.exit		rts

;-----------------------------------------------------------------------------
;CopyLogo - Copy logo into top of screen
;
LOGO_WIDTH	= 640
LOGO_HEIGHT	= 64

LOGO_SIZELONGS	= LOGO_WIDTH*LOGO_HEIGHT*BPL/32

CopyLogo:
		lea	logo,a0
		lea	screen,a1

		move.l	#LOGO_SIZELONGS-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop
		rts

;-----------------------------------------------------------------------------
;WaitVB - Wait for vertical blank
;in
;	a5 - _custom
;
;crash
;	a0,d0
WaitVB:
		lea	vposr(a5),a0
.1		moveq	#1,d0
		and.w	(a0),d0
		bne	.1
.2		moveq	#1,d0
		and.w	(a0),d0
		beq	.2
		rts

;=============================================================================

	DATA

menuItems:
		dc.w	(.end-.start)/8-1
.start
		MITEM	280,120,1,.itemTxt1
		MITEM	280,128,0,.itemTxt2
		MITEM	280,136,1,.itemTxt3
		MITEM	280,144,1,.itemTxt4
		MITEM	280,152,1,.itemTxt5

		MITEM	260,180,1,.procInfo
		MITEM	360,180,1,.memInfo
		MITEM	200,188,1,.appInfo
.end

.itemTxt1:	dc.b	"Pozycja 1",0
.itemTxt2:	dc.b	"Pozycja 2",0
.itemTxt3:	dc.b	"Pozycja 3",0
.itemTxt4:	dc.b	"Pozycja 4",0
.itemTxt5:	dc.b	"Pozycja 5",0


.appInfo:	dc.b	"boot room v0.0 - CPLD firmware v0.0",0
.procInfo:	dc.b	"68030 XX MHz",0
.memInfo:	dc.b	"x MB RAM",0

programExit:	dc.b	0

;
;trigger used to switch between screens, pal and vga
; 0 - pal
; 1 - vga 
vgaOrPal:	dc.b	0

mainFunction:	dc.l	0




logo:		incbin	"logo.bin"


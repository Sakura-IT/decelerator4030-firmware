
	INCLUDE	"hardware/custom.i"
	INCLUDE	"menu.i"
	INCLUDE	"display.i"
	INCLUDE "input.i"

;--- from arrow.s ---
	XREF	arrowPosY

	XREF	ArrowDown
	XREF	ArrowInit
	XREF	ArrowUp

;--- from display.s ---
	XREF	screen

	XREF	DoCopperList
	XREF	SetDisplay

;--- from input.s ---
	XREF	SetKeyboard

;--- from menu.s ---
	XREF	MenuPrint
	XREF	MenuUpdate

;-----------------------------------------------------------------------------

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

		bra.b	MainLoop

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
		
		move.w	#MENU_ARROW_X,d0
		move.w	#MENU_START_POS_Y,d1
		move.w	#MENU_START_POS_Y,d2
		move.w	#MENU_ITEM5_POS_Y,d3
		bsr	ArrowInit
		rts

;-----------------------------------------------------------------------------
MainMenuLoop:

	;check cursor down
		lea	keys(pc),a0
		tst.b	KEY_CURSOR_DOWN(a0)
		beq	.up

		move.b	KEY_CURSOR_DOWN(a0),d0

;.l		btst	#6,$bfe001
;		bne	.l

		sf	KEY_CURSOR_DOWN(a0)

		bsr	ArrowDown
		lea	menuItems(pc),a0
		move.w	arrowPosY,d4
		bra	MenuUpdate

.up
		tst.b	KEY_CURSOR_UP(a0)
		beq	.enter

		sf	KEY_CURSOR_UP(a0)

		bsr	ArrowUp
		lea	menuItems(pc),a0
		move.w	arrowPosY,d4
		bra	MenuUpdate

.enter
		tst.b	KEY_ENTER(a0)
		bne	.exit

		sf	KEY_ENTER(a0)

	;put here logic for menu entries

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

MENU_POS_X		EQU 280
MENU_START_POS_Y	EQU 120
MENU_ITEM2_POS_Y	EQU MENU_START_POS_Y+8
MENU_ITEM3_POS_Y	EQU MENU_ITEM2_POS_Y+8
MENU_ITEM4_POS_Y	EQU MENU_ITEM3_POS_Y+8
MENU_ITEM5_POS_Y	EQU MENU_ITEM4_POS_Y+8

MENU_ARROW_X		EQU MENU_POS_X-8

menuItems:
		dc.w	(.end-.start)/8-1
.start
		MITEM	MENU_POS_X,MENU_START_POS_Y,MENU_COLOR_NORMAL,.itemTxt1
		MITEM	MENU_POS_X,MENU_ITEM2_POS_Y,MENU_COLOR_NORMAL,.itemTxt2
		MITEM	MENU_POS_X,MENU_ITEM3_POS_Y,MENU_COLOR_NORMAL,.itemTxt3
		MITEM	MENU_POS_X,MENU_ITEM4_POS_Y,MENU_COLOR_NORMAL,.itemTxt4
		MITEM	MENU_POS_X,MENU_ITEM5_POS_Y,MENU_COLOR_NORMAL,.itemTxt5

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


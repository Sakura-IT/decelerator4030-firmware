
MENU_COLOR_NORMAL	= 1
MENU_COLOR_LIGHT	= 2


MITEM	MACRO
		dc.w	\1	;position x
		dc.w	\2	;position y
		dc.w	\3	;color
		dc.w	\4-*-2	;message
	ENDM

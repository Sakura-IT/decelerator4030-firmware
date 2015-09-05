AS=vasmm68k_mot
CROSS_LD=vlink
CROSS_CC=vc
ASFLAGS=-Fvobj -m68020up
CROSS_LDSCRIPT=bootrom.ld
CROSS_LDFLAGS=-brawbin1 -T $(CROSS_LDSCRIPT)

LOADER_OBJS=init.o start.o menu.o display.o input.o
LOADER_INCS=
LOADER_IMAGE=bootrom.img

all: $(LOADER_IMAGE)

$(LOADER_IMAGE) : $(LOADER_OBJS) $(LOADER_INCS)
	$(CROSS_LD) $(CROSS_LDFLAGS) -o $(LOADER_IMAGE) $(LOADER_OBJS)

%.o : %.s
	$(AS) $(ASFLAGS) -Fvobj -o $@ $<


clean :
	rm -f $(LOADER_IMAGE) $(LOADER_OBJS)


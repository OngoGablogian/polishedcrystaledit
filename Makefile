NAME := polishedcrystal
VERSION := 3.0.0-beta

TITLE := PKPCRYSTAL
MCODE := PKPC
ROMVERSION := 0x30

FILLER = 0xff

ifneq ($(wildcard rgbds/.*),)
RGBDS_DIR = rgbds/
else
RGBDS_DIR =
endif

RGBASM_FLAGS = -E -Weverything
RGBLINK_FLAGS = -n $(ROM_NAME).sym -m $(ROM_NAME).map -l contents/contents.link -p $(FILLER)
RGBFIX_FLAGS = -csjv -t $(TITLE) -i $(MCODE) -n $(ROMVERSION) -p $(FILLER) -k 01 -l 0x33 -m 0x10 -r 3

ifeq ($(filter faithful,$(MAKECMDGOALS)),faithful)
RGBASM_FLAGS += -DFAITHFUL
endif
ifeq ($(filter nortc,$(MAKECMDGOALS)),nortc)
RGBASM_FLAGS += -DNO_RTC
endif
ifeq ($(filter monochrome,$(MAKECMDGOALS)),monochrome)
RGBASM_FLAGS += -DMONOCHROME
endif
ifeq ($(filter noir,$(MAKECMDGOALS)),noir)
RGBASM_FLAGS += -DNOIR
endif
ifeq ($(filter hgss,$(MAKECMDGOALS)),hgss)
RGBASM_FLAGS += -DHGSS
endif
ifeq ($(filter debug,$(MAKECMDGOALS)),debug)
RGBASM_FLAGS += -DDEBUG
endif


.SUFFIXES:
.PHONY: all clean crystal faithful nortc debug monochrome freespace compare tools
.SECONDEXPANSION:
.PRECIOUS: %.2bpp %.1bpp
.SECONDARY:


roms_md5      = roms.md5
bank_ends_txt = contents/bank_ends.txt
copied_sym    = contents/$(NAME).sym
copied_map    = contents/$(NAME).map
copied_gbc    = contents/$(NAME).gbc

PYTHON = python2
CC     = gcc
RM     = rm -f
GFX    = $(PYTHON) gfx.py
MD5    = md5sum -b

LZ                = tools/lzcomp
SCAN_INCLUDES     = tools/scan_includes
SUB_2BPP          = tools/sub_2bpp.sh
COLLISION_ASM2BIN = tools/collision_asm2bin.sh
BANK_ENDS         = tools/bankends


crystal_obj := \
main.o \
home.o \
ram.o \
audio.o \
audio/music_player.o \
data/pokemon/dex_entries.o \
data/pokemon/egg_moves.o \
data/pokemon/evos_attacks.o \
data/maps/map_data.o \
data/text/common.o \
data/tilesets.o \
engine/movie/credits.o \
engine/overworld/events.o \
gfx/pics.o \
gfx/icons.o \
gfx/sprites.o \
gfx/items.o \
gfx/misc.o


all: crystal freespace

crystal: ROM_NAME = $(NAME)-$(VERSION)
crystal: $(NAME)-$(VERSION).gbc

faithful: crystal
nortc: crystal
monochrome: crystal
noir: crystal
hgss: crystal
debug: crystal

freespace: $(bank_ends_txt) $(roms_md5) $(copied_sym) $(copied_map) $(copied_gbc)

tools:
	$(MAKE) -C tools/

clean:
	$(RM) $(crystal_obj) $(wildcard $(NAME)-*.gbc) $(wildcard $(NAME)-*.map) $(wildcard $(NAME)-*.sym)

compare: crystal
	$(MD5) -c $(roms_md5)


$(bank_ends_txt): ROM_NAME = $(NAME)-$(VERSION)
$(bank_ends_txt): crystal $(BANK_ENDS)
	$(BANK_ENDS) $(ROM_NAME).map > $@

$(roms_md5): crystal ; $(MD5) $(NAME)-$(VERSION).gbc > $@
$(copied_sym): crystal ; cp $(NAME)-$(VERSION).sym $@
$(copied_map): crystal ; cp $(NAME)-$(VERSION).map $@
$(copied_gbc): crystal ; cp $(NAME)-$(VERSION).gbc $@


define DEP
$1: $2 $$(shell $(SCAN_INCLUDES) $2)
	$$(RGBDS_DIR)rgbasm $$(RGBASM_FLAGS) -L -o $$@ $$<
endef

ifeq (,$(filter clean tools,$(MAKECMDGOALS)))

$(info $(shell $(MAKE) -C tools))

$(foreach obj, $(crystal_obj), $(eval $(call DEP,$(obj),$(obj:.o=.asm))))

endif


gfx/pack/pack_top_left.2bpp: gfx/pack/pack_top.2bpp gfx/pack/pack_left.2bpp ; cat $^ > $@

.gbc:
%.gbc: $(crystal_obj)
	$(RGBDS_DIR)rgblink $(RGBLINK_FLAGS) -o $@ $^
	$(RGBDS_DIR)rgbfix $(RGBFIX_FLAGS) $@

%.2bpp.vram0: %.2bpp
	$(SUB_2BPP) $< 128 > $@

%.2bpp.vram1: %.2bpp
	$(SUB_2BPP) $< 128 128 > $@

%.2bpp.vram2: %.2bpp
	$(SUB_2BPP) $< 256 128 > $@

%.2bpp: %.png ; $(GFX) 2bpp $<
%.1bpp: %.png ; $(GFX) 1bpp $<

data/tilesets/%_collision.bin: data/tilesets/%_collision.asm
	RGBDS_DIR=$(RGBDS_DIR) $(COLLISION_ASM2BIN) $< $@

%.lz: % ; $(LZ) -- $< $@

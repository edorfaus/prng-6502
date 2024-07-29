LDCFG = linker.cfg

CAFLAGS = -g -t nes $(EXTRA_CAFLAGS)
LDFLAGS = -C $(LDCFG)

.PHONY: all clean distclean

# Find the test source files, to auto-generate some rules.
asmFiles := $(wildcard */*_test.asm)

all: $(patsubst %.asm,build/%.nes,$(notdir $(asmFiles)))

clean:
	$(if $(wildcard build/*),-,@echo )rm build/*

distclean:
	-[ ! -d build ] || rm -r build/

build/%_test.o: jsf/%_test.asm jsf/%.asm | build/
	ca65 $(CAFLAGS) -o $@ $<

build/%_test.o: xorshift/%_test.asm xorshift/%.asm | build/
	ca65 $(CAFLAGS) -o $@ $<

$(addprefix build/%.,nes dbg map)&: build/%.o $(LDCFG) | build/
	ld65 -o $(basename $@).nes.tmp $(LDFLAGS) \
		--dbgfile $(basename $@).dbg -m $(basename $@).map \
		$(filter-out $(LDCFG),$^)
	mv $(basename $@).nes.tmp $(basename $@).nes

# Do not (try to) delete the created dir on error or if intermediate.
.PRECIOUS: %/
%/:
	mkdir -p $@

SUB ?= arm
#arm or aarch64

ARCH = armv7-a
MCPU = cortex-a8

ifeq ($(SUB), aarch64)
  ARCH = armv8-a
  MCPU = cortex-a53
endif

PREFIX = arm-none-eabi-

ifeq ($(SUB), aarch64)
  PREFIX = aarch64-linux-gnu-
endif

CC = $(PREFIX)gcc
AS = $(PREFIX)as
LD = $(PREFIX)ld
OC = $(PREFIX)objcopy

QEMU_PREFIX = qemu-system-
QEMU = $(QEMU_PREFIX)$(SUB)
QEMU_MODEL = realview-pb-a8

ifeq ($(SUB), aarch64)
  QEMU_MODEL = raspi3
endif

LINKER_SCRIPT = ./devos.ld

ASM_SRCS = $(wildcard boot/$(SUB)/*.S)
ASM_OBJS = $(patsubst boot/$(SUB)/%.S, build/%.o, $(ASM_SRCS))

devos = build/devos.axf
devos_bin = build/devos.bin

.PHONY: all clean run debug gdb

all: $(devos)

clean:
	@rm -rf build

run: $(devos)
	$(QEMU) -M $(QEMU_MODEL) -kernel $(devos)

debug: $(devos)
	$(QEMU) -M $(QEMU_MODEL) -kernel $(devos) -S -gdb tcp::1234,ipv4

gdb:
	gdb-multiarch

$(devos): $(ASM_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(devos) $(ASM_OBJS)
	$(OC) -O binary $(devos) $(devos_bin)

build/%.o: boot/$(SUB)/%.S
	mkdir -p $(shell dirname $@)
	$(AS) -march=$(ARCH) -mcpu=$(MCPU) -g -o $@ $<

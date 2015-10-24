all:blinky.elf blink.elf program

#CFLAGS := -Os -w -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10605 -DARDUINO_AVR_PRO -DARDUINO_ARCH_AVR
#BOARD := leonado

# leonado board not working with avr-gcc and avrdude
ifeq ($(BOARD),leonado)
MCU_TARGET := atmega32u4
ISPPORT := ttyUSB0
ISPTOOR := avr109
else
MCU_TARGET := atmega328p
ISPPORT := ttyUSB1
ISPTOOL  := arduino
endif

AVRDUDE_OPTS = -v -v -v -p$(MCU_TARGET) -c$(ISPTOOL) -s -u

ifneq ($(ISPPORT),)
AVRDUDE_OPTS += -P/dev/$(ISPPORT) -b 57600
endif

CC := avr-gcc
CFLAGS = -Os -w -mmcu=$(MCU_TARGET)

LDFLAGS = -Os -Wl,--gc-sections -mmcu=$(MCU_TARGET)

%.elf: MCU_TARGET=atmega328p
%.o: MCU_TARGET=atmega328p

blinky.hex: m32def.inc

%.hex: %.asm
	avra -fI $< -o $@

%.elf: %.o
	$(CC) -w -Os $(LDFLAGS) -o $@ $^

%.hex: %.elf
	avr-objcopy -O ihex $< $@ 

program: blink.hex
	avrdude $(AVRDUDE_OPTS) -D -Uflash:w:$<:i 

atmega328_isp: TARGET=blink.hex
atmega328_isp: MCU_TARGET = atmega328p
atmega328_isp: ISPTOOL = usbasp
atmega328_isp: HFUSE = DA
atmega328_isp: LFUSE = FF
atmega328_isp: EFUSE = 05

atmega328_isp: blink.hex
	avrdude $(AVRDUDE_OPTS) -e -u -U lock:w:0x3f:m -Uefuse:w:0x$(EFUSE):m -U hfuse:w:0x$(HFUSE):m -U lfuse:w:0x$(LFUSE):m
	avrdude $(AVRDUDE_OPTS) -U flash:w:$(TARGET):i -U lock:w:0x0f:m

blinky_isp: TARGET=blink.hex
blinky_isp: MCU_TARGET = atmega328p
blinky_isp: ISPTOOL = arduino
blinky_isp: HFUSE = DA
blinky_isp: LFUSE = FF
blinky_isp: EFUSE = 05

blinky_isp: blinky.hex
	avrdude $(AVRDUDE_OPTS) -e -u -U lock:w:0x3f:m -Uefuse:w:0x$(EFUSE):m -U hfuse:w:0x$(HFUSE):m -U lfuse:w:0x$(LFUSE):m
	avrdude $(AVRDUDE_OPTS) -e -U flash:w:$<:i -U lock:w:0x0f:m


.PHONY: clean
clean:
	$(RM) $(wildcard *.o) *.hex *.elf

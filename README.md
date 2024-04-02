# Pace-X INS8900 Computer

(Still under development)

The INS8900 is a NMOS version of National Semiconductor's PACE microprocessor.
This was (probably) the first 16-bit microprocessor to hit the market in the
mid 1970s.

This is a very simple computer built around this chip. Features include

* 2MHz operation
* 128K words of RAM
* Up to 128K words of ROM
* 8250 (or compatible) UART
* Software controlled status LEDs
* 12VDC input

Note that the memory split between RROM and RAM is controlled by a PAL that
sets up the memory map. Banking is supported using up to three flag outputs
(F11, F12, F13) on the CPU. The current memory map is:

* 0000 to 001FF - ROM (can be swapped out with RAM using F11)
* 0200 to FDFF - RAM
* FE00 to FFFF - UART (mirrored a bunch of times)

UART access is easiest at FF00 (absolute). But it can also be done from the
zero page when BPS is brought high. This can be activated using F12.

The PAL code is assembled using `galette`. [site](https://github.com/simon-frankau/galette)

The assembly code for the INS8900 is assembled using `asl` [site]([http://john.ccac.rwth-aachen.de:8000/as/)

## Assembling the code

CPU source code is assembled as follows

```
asl test.asm -L
p2bin test.p test.bin
python3 split.py
```

The result are two files, `high.bin` and `low.bin` which need to be programmed
into two EPROMS or EEPROMS. You can do this with a TL866 using `minipro`. For example, using two MX28F1000P EEPROM chips:

```
minipro -p MX28F1000P -w low.bin -s
```
(swap the chips)
```
minipro -p MX28F1000P -w high.bin -s
```

To assemble and program the GAL, run
```
galette addr_decoder.pld
minipro -p ATF16V8B -w addr_decoder.jed
```

That's all for now!

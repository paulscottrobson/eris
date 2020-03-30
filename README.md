# eris
Eris is an open source 16 bit retrocomputer design which can be built cheaply and easily and has
low implementation requirements. It can be built for about £10 or so + cost of preferred keyboard.

Currently it runs on SDL , on Linux, Windows and Raspbian. It runs stand alone on a ESP32 chip with FABGL hardware (a few discrete components) or the TTGO VGA32 board or compatible.

Future platforms : PiZero, definitely. EmScripten if fast enough. Possibly others.

This is stuff that actually *works now*. Not planned, theorised, possibilities. It is still Alpha
but is going to be bullied. 

Hardware

- 16 bit 100% orthogonal RISC-style CPU running at slightly under 1 MIPS on ESP32.
  (it has bits of IMP-16, bits of ARM RISC and bits of CDP1600)
- 24k RAM and 16k ROM 16 bit words, max 47.75k RAM words
- 320x240 4 bit colour display driven by blitter, does not use Program RAM.
- 2 tone and 1 noise channels.
- Running on ESP32 , Raspian and Windows/Linux emulator (only uses SDL)
- Uses system storage - Local HD, SPIFFS and SDCard dependent on platform.

System Software

- Python Cross Assembler, Sprite Generator, Basic tokeniser for cross development.

Kernel

- 53 x 30 text display
- Commodore style screen editor
- Line, Rectangle, Ellipse Graphics functions.
- 16 single colour sprite system
- Standard joystick interface
- Background sound generation
- Redefinable function keys
- Keyboard internationalisation

Integer Basic

- Integer and String, one and two dimension array types 
- Approx 12-13 times quicker than C64 Basic
- For, While, If/Else, Repeat structures
- Long variable names
- Named procedures and value parameters
- Local variables
- Commands for sound, sprites, joystick, keypress, graphics etc.
  (mostly they just call Kernel routines to do things)
- Indirection operator (like BBC Basic or BCPL)
- Inline Assembler (like BBC Basic)
- Has GOTO, GOSUB and RETURN but you don't need line numbers except editing.
- Listing Indents structures and does syntax colouring.
- Message internationalisation (could internationalise keywords ...)
- Hidden lines for support code ; you can't edit or list any line no > 32767

Documentation

- Hardware Description
- Basic Reference


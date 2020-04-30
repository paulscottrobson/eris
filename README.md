# eris

There is a blog for this project at http://blog.erisdev.com and 
an emscripten version which is identical to the hardware version 
at http://js.erisdev.com

Eris is an open source 16 bit retrocomputer design which can be built cheaply and easily and has
low implementation requirements. It can be built for about £10 or so + cost of preferred keyboard. 

It's a virtual machine system, so the code that runs on it is written in its own assembler, so porting is much more reliable.

Currently it runs on SDL , on Linux, Windows, Javascript via emScripten and Raspbian. 

It runs stand alone on a ESP32 chip with FABGL compatible hardware (a few discrete components) 
or the TTGO VGA32 board or compatible - this is the reference design.

Future platforms : PiZero, definitely. Possibly others.

This is stuff that actually *works now*. Not planned, theorised, possibilities. 

It is Beta at the time of writing, but bugs have been minor. I'm writing a pile of games
for Retrochallenge April 2020 and the real purpose is to dogfood test it. Though this is cross
development , but I'm pretty sure the editor works pretty well. I soak tested SPIFFS (the ESP32
storage system).

Hardware

- 16 bit 100% orthogonal RISC-style CPU running at slightly under 1 MIPS on ESP32.
  (it has bits of IMP-16, bits of ARM RISC and bits of CDP1600)
- 24k RAM and 16k ROM 16 bit words, max 47.75k RAM words
- 320x240 4 bit colour display driven by a baby blitter, does not use Program RAM.
- 2 tone and 1 noise channels.
- Running on ESP32, Javascript , Raspian and Windows/Linux emulator (only uses SDL)
- Uses system storage - Local HD, SPIFFS and SDCard dependent on platform.
- Files can be downloaded from the internet into the platform
- Files can be uploaded from the platfom for backup

System Software

- python3 Cross Assembler, Sprite Generator, Basic tokeniser for cross development.

Kernel

- 53 x 30 text display
- Commodore style screen editor which works like a text editor
- Line, Rectangle, Ellipse Graphics Text functions.
- Single colour sprite system supporting 24 at once.
- Standard joystick interface (it maps onto arrow, shift and ctrl)
- Background sound generation
- Redefinable function keys
- Keyboard internationalisation

Integer Basic

- Integer and String, one and two dimension array types 
- Approx 12-13 times quicker than C64 Basic (to be fair, this uses floats)
- For, While, If/Else/Endif or If/Then, Repeat structures
- Long variable names
- Named procedures and value parameters
- Local variables
- Commands for sound, sprites, joystick, keypress, graphics etc.
- Indirection operator (like BBC Basic or BCPL)
- Inline Assembler (like BBC Basic)
- Built in quasi-Forth programming language (which is much easier than assembler but less efficient)
- Has GOTO, GOSUB and RETURN but you don't need line numbers except editing.
- Listing Indents structures and does syntax colouring.
- Message internationalisation (could internationalise keywords ...)
- Hidden lines for support code ; you can't edit or list any line no > 32767 or 0
  (the point of this is that learning materials can hide support routines)

Documentation

- Hardware Description
- Basic Reference

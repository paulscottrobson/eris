# *****************************************************************************
# *****************************************************************************
#
#		Name:		font.py
#		Purpose:	Generate font file.
#		Created:	22nd February 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

import os,sys

fontData = [
    [  0,   0,   0,   0,   0,   0,   0, ], # [ 0] ' '
    [  4,   4,   4,   4,   0,   0,   4, ], # [ 1] '!'
    [ 10,  10,  10,   0,   0,   0,   0, ], # [ 2] '"'
    [ 10,  10,  31,  10,  31,  10,  10, ], # [ 3] '#'
    [  4,  15,  20,  14,   5,  30,   4, ], # [ 4] '$'
    [ 24,  25,   2,   4,   8,  19,   3, ], # [ 5] '%'
    [ 12,  18,  20,   8,  21,  18,  13, ], # [ 6] '&'
    [ 12,   4,   8,   0,   0,   0,   0, ], # [ 7] '''
    [  2,   4,   8,   8,   8,   4,   2, ], # [ 8] '('
    [  8,   4,   2,   2,   2,   4,   8, ], # [ 9] ')'
    [  0,   4,  21,  14,  21,   4,   0, ], # [10] '*'
    [  0,   4,   4,  31,   4,   4,   0, ], # [11] '+'
    [  0,   0,   0,   0,  12,   4,   8, ], # [12] ','
    [  0,   0,   0,  31,   0,   0,   0, ], # [13] '-'
    [  0,   0,   0,   0,   0,  12,  12, ], # [14] '.'
    [  0,   1,   2,   4,   8,  16,   0, ], # [15] '/'
    [ 14,  17,  19,  21,  25,  17,  14, ], # [16] '0'
    [  4,  12,   4,   4,   4,   4,  14, ], # [17] '1'
    [ 14,  17,   1,   2,   4,   8,  31, ], # [18] '2'
    [ 31,   2,   4,   2,   1,  17,  14, ], # [19] '3'
    [  2,   6,  10,  18,  31,   2,   2, ], # [20] '4'
    [ 31,  16,  30,   1,   1,  17,  14, ], # [21] '5'
    [  6,   8,  16,  30,  17,  17,  14, ], # [22] '6'
    [ 31,  17,   1,   2,   4,   4,   4, ], # [23] '7'
    [ 14,  17,  17,  14,  17,  17,  14, ], # [24] '8'
    [ 14,  17,  17,  15,   1,   2,  12, ], # [25] '9'
    [  0,  12,  12,   0,  12,  12,   0, ], # [26] ':'
    [  0,  12,  12,   0,  12,   4,   8, ], # [27] ';'
    [  2,   4,   8,  16,   8,   4,   2, ], # [28] '<'
    [  0,   0,  31,   0,  31,   0,   0, ], # [29] '='
    [  8,   4,   2,   1,   2,   4,   8, ], # [30] '>'
    [ 14,  17,   1,   2,   4,   0,   4, ], # [31] '?'
    [ 14,  17,   1,  13,  21,  21,  14, ], # [32] '@'
    [ 14,  17,  17,  17,  31,  17,  17, ], # [33] 'A'
    [ 30,  17,  17,  30,  17,  17,  30, ], # [34] 'B'
    [ 14,  17,  16,  16,  16,  17,  14, ], # [35] 'C'
    [ 28,  18,  17,  17,  17,  18,  28, ], # [36] 'D'
    [ 31,  16,  16,  30,  16,  16,  31, ], # [37] 'E'
    [ 31,  16,  16,  30,  16,  16,  16, ], # [38] 'F'
    [ 14,  17,  16,  23,  17,  17,  15, ], # [39] 'G'
    [ 17,  17,  17,  31,  17,  17,  17, ], # [40] 'H'
    [ 14,   4,   4,   4,   4,   4,  14, ], # [41] 'I'
    [  7,   2,   2,   2,   2,  18,  12, ], # [42] 'J'
    [ 17,  18,  20,  24,  20,  18,  17, ], # [43] 'K'
    [ 16,  16,  16,  16,  16,  16,  31, ], # [44] 'L'
    [ 17,  27,  21,  21,  17,  17,  17, ], # [45] 'M'
    [ 17,  17,  25,  21,  19,  17,  17, ], # [46] 'N'
    [ 14,  17,  17,  17,  17,  17,  14, ], # [47] 'O'
    [ 30,  17,  17,  30,  16,  16,  16, ], # [48] 'P'
    [ 14,  17,  17,  17,  21,  18,  13, ], # [49] 'Q'
    [ 30,  17,  17,  30,  20,  18,  17, ], # [50] 'R'
    [ 15,  16,  16,  14,   1,   1,  30, ], # [51] 'S'
    [ 31,   4,   4,   4,   4,   4,   4, ], # [52] 'T'
    [ 17,  17,  17,  17,  17,  17,  14, ], # [53] 'U'
    [ 17,  17,  17,  17,  17,  10,   4, ], # [54] 'V'
    [ 17,  17,  17,  21,  21,  21,  10, ], # [55] 'W'
    [ 17,  17,  10,   4,  10,  17,  17, ], # [56] 'X'
    [ 17,  17,  17,  10,   4,   4,   4, ], # [57] 'Y'
    [ 31,   1,   2,   4,   8,  16,  31, ], # [58] 'Z'
    [ 28,  16,  16,  16,  16,  16,  28, ], # [59] '['
    [  0,  16,   8,   4,   2,   1,   0, ], # [60] '\'
    [ 14,   2,   2,   2,   2,   2,  14, ], # [61] ']'
    [  4,  10,  17,   0,   0,   0,   0, ], # [62] '^'
    [  0,   0,   0,   0,   0,   0,  31, ], # [63] '_'
    [  8,   4,   2,   0,   0,   0,   0, ], # [64] '`'
    [  0,   0,  14,   1,  15,  17,  15, ], # [65] 'a'
    [ 16,  16,  22,  25,  17,  17,  30, ], # [66] 'b'
    [  0,   0,  14,  16,  16,  17,  14, ], # [67] 'c'
    [  1,   1,  13,  19,  17,  17,  15, ], # [68] 'd'
    [  0,   0,  14,  17,  31,  16,  14, ], # [69] 'e'
    [  6,   9,   8,  28,   8,   8,   8, ], # [70] 'f'
    [  0,  15,  17,  17,  15,   1,  14, ], # [71] 'g'
    [ 16,  16,  22,  25,  17,  17,  17, ], # [72] 'h'
    [  4,   0,  12,   4,   4,   4,  14, ], # [73] 'i'
    [  2,   0,   6,   2,   2,  18,  12, ], # [74] 'j'
    [ 16,  16,  18,  20,  24,  20,  18, ], # [75] 'k'
    [ 12,   4,   4,   4,   4,   4,  14, ], # [76] 'l'
    [  0,   0,  26,  21,  21,  17,  17, ], # [77] 'm'
    [  0,   0,  22,  25,  17,  17,  17, ], # [78] 'n'
    [  0,   0,  14,  17,  17,  17,  14, ], # [79] 'o'
    [  0,   0,  30,  17,  30,  16,  16, ], # [80] 'p'
    [  0,   0,  13,  19,  15,   1,   1, ], # [81] 'q'
    [  0,   0,  22,  25,  16,  16,  16, ], # [82] 'r'
    [  0,   0,  14,  16,  14,   1,  30, ], # [83] 's'
    [  8,   8,  28,   8,   8,   9,   6, ], # [84] 't'
    [  0,   0,  17,  17,  17,  19,  13, ], # [85] 'u'
    [  0,   0,  17,  17,  17,  10,   4, ], # [86] 'v'
    [  0,   0,  17,  21,  21,  21,  10, ], # [87] 'w'
    [  0,   0,  17,  10,   4,  10,  17, ], # [88] 'x'
    [  0,   0,  17,  17,  15,   1,  14, ], # [89] 'y'
    [  0,   0,  31,   2,   4,   8,  31, ], # [90] 'z'
    [  2,   4,   4,   8,   4,   4,   2, ], # [91] '{'
    [  4,   4,   4,   4,   4,   4,   4, ], # [92] '|'
    [  8,   4,   4,   2,   4,   4,   8, ], # [93] '}'
    [  0,   4,   2,  31,   2,   4,   0, ], # [94] '~'
    [  0,   0,   0,  21,   0,   0,   0, ] # [95] null marker
  ]

for x in fontData:
    while len(x) < 8:
        x.append(0)

h = open("font.inc","w")
h.write("\torg KernelEnd-$300\n")
h.write(".FontData\n")
for i in range(0,len(fontData)):
    cd = ",".join(["${0:04x}".format(c << 11) for c in fontData[i]])
    h.write("\tword\t{0} ; ${1:02x} {2}\n".format(cd,i+32,chr(i+32)))
h.close()    
# *****************************************************************************
# *****************************************************************************
#
#		Name:		prompt.py
#		Purpose:	Prompt Generator (Kernel)
#		Created:	8th March 2020
#		Author:		Paul Robson (paul@robsons.org.uk)
#
# *****************************************************************************
# *****************************************************************************

from datetime import datetime
#
#		Current version
#
kernelVersion = "0.00"
basicVersion = "0.01"
#
#		Timestamp
#
now = datetime.now()
s = now.strftime("%a,%d %b %Y")
#
#		Create include file.
#
h = open("prompt.inc","w")
h.write(".bootPrompt\n")
h.write('\tstring\t"[10,0F,16,0C]** Eris RetroComputer **[0D,1A]Kernel[3A]{1} Basic[3A]{2}[0D]"\n'.format(s,kernelVersion,basicVersion))
h.close()

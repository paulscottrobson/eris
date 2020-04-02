'
'			Simple Squash Game
'
screen 2,2
'
'			Manually create sprites by poking image memory. Not good practice normally :)
'
batSprite = sysvar(3):ballSprite = sysvar(3)+16
for i = 0 to 15:batSprite!i = &0300:ballSprite!i = 0:next i
for i = 6 to 11:ballSprite!i = &07E0:next i

sprite 0 to 100,100 draw 0 ink 1 dim 2
sprite 1 to 200,100 draw 1 ink 3

ink 2:rect 0,0 to 319,3:rect 0,236 to 319,239:Rect 316,0 to 319,239

a$ = get$()
sound 1,10,200
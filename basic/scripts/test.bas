10 t1 = !&FF30
20 LET k=0 
30 LET k=k+1
50 IF k<10000 THEN GOTO 30
70 print !&FF30,t1
80 t1 = !&FF30-t1
90 print t1
100 print t1/100;".";right$("000"+str$(t1 mod 100),2)

parser: lex.yy.c symbols.h y.tab.c
	gcc y.tab.c lex.yy.c -o parser

scanner:lex.yy.c symbols.h
	gcc -o $@ $<

lex.yy.c: scanner.l
	flex $

y.tab.c: parser.y
	bison -vdty $<

clean:
	rm lex.yy.c lex.yy.exe scanner out.txt y.tab.c y.output y.tab.h parser
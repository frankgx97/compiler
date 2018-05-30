parser: lex.yy.c y.tab.c
	gcc y.tab.c lex.yy.c -o parser

scanner:lex.yy.c 
	gcc -o lex.yy.c

lex.yy.c: scanner.l
	flex scanner.l

y.tab.c: parser.y
	bison -vdty parser.y

clean:
	rm lex.yy.c lex.yy.exe scanner out.txt y.tab.c y.output y.tab.h parser

run:
	make && ./parser in.cm
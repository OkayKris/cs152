lexer:
	flex 862025678-862013504.lex
	gcc -o lexer lex.yy.c -lfl

parser:
	bison -v -d --file-prefix=y 862025678-862013504.y
	flex 862025678-862013504.lex
	gcc -o parser y.tab.c lex.yy.c -lfl
	rm -f lex.yy.c

clean:
	rm -f parser y.tab.* y.output *~ lex.yy.c
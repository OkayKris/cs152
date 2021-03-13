lexer:
	flex 862025678-862013504.lex
	gcc -o lexer lex.yy.c -lfl

mycompiler:
	bison -v -d --file-prefix=y 862025678-862013504.y
	flex 862025678-862013504.lex
	gcc -std=c++11 -g -o mycompiler lex.yy.c y.tab.c -lfl

clean:
	rm -f mycompiler y.tab.* y.output mycompiler *~ lex.yy.c input.txt
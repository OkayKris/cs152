lexer:
	flex 862025678-862013504.lex
	gcc -o lexer lex.yy.c -lfl

mycompiler:
	bison -v -d --file-prefix=y 862025678-862013504.y
	flex 862025678-862013504.lex
	g++ -std=c++11 -o mycompiler y.tab.c lex.yy.c -lfl
	rm -f lex.yy.c

clean:
	rm -f mycompiler y.tab.* y.output *~ lex.yy.c input.txt
all:
	lex	language_token.l
	yacc -d	language_parser.y
	gcc lex.yy.c y.tab.c -o executabil.exe
	./executabil.exe program.txt

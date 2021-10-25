%{
#include <stdio.h>
#include <stdlib.h>

typedef struct infos
{
 int typeval;
 char * strval;
}info;
#include "y.tab.h"

%}
%option noyywrap
%%

(Eval) {  return EVAL; }
(int) { yylval.typeval = 0; return TYP_INT; }
(float) { yylval.typeval = 1; return TYP_FLOAT; }
(bool) { yylval.typeval = 2; return TYP_BOOL; }
(char) {  yylval.typeval = 3; return TYP_CHAR; }
(string) { yylval.typeval = 4; return TYP_STRING; }
(const_int) { yylval.typeval = 5; return TYP_CONST_INT; } 
(const_float) { yylval.typeval = 6; return TYP_CONST_FLOAT; }
(const_bool) { yylval.typeval = 7; return TYP_CONST_BOOL; }
(const_char) { yylval.typeval = 8; return TYP_CONST_CHAR; }
(const_string) { yylval.typeval = 9; return TYP_CONST_STRING; }
(array) { return ARRAY;}
(camp) {  return STRUCT;}
(tasker) {return FUNCTION;}
(call_tasker) {return CALL_FUNCTION;}

(obiect) {return STRUCT_OBJECT;}



(for) {return FOR;}
(while) {return WHILE;}
(break) {return BREAK;}
(continue) {return CONTINUE;}
(if) {return IF;}
(else) {return ELSE;}
(then) {return THAN;}
(:=) {return ASSIGN;}
(return) {return RETURN;}


(\.) {return DOT;}
(,) {return COMMA;}
(;) {return SEMICOLON;}
(\+\+) {return PLUS_PLUS;}
(\*\*) {return MULTIPLY_MULTIPLY;}
(\+) {return PLUS;}
(\*) {return MULTIPLY;}
(\-) {return MINUS;}
(\/) {return DIVIDE;}
(!) {return NOT;}
(==) {return EQUAL;}
(\&\&) {return AND;}
(\|\|) {return OR;}
(<) {return LESS;}
(>) {return BIGGER;}
(\{) {return LEFT_BRACE;}
(\}) {return RIGHT_BRACE;}
(\() {return LEFT_ROUND_BRACKETS;}
(\)) {return RIGHT_ROUND_BRACKETS;}
(\[) {return LEFT_SQUARE_BRACKETS;}
(\]) {return RIGHT_SQUARE_BRACKETS;}

(begin_program) {return BEGN;}
(end_program) {return END;}

(([\+|\-]?[1-9][0-9]*)|0) { yylval.val =(info *)malloc(sizeof(info));  yylval.val->strval = strdup(yytext); yylval.val->typeval = 0; return INT_VALUE;}
([\+|\-]?([1-9][0-9]*\.[0-9]+)|(0\.[0-9]+)) {yylval.val =(info *)malloc(sizeof(info));  yylval.val->strval = strdup(yytext); yylval.val->typeval = 1; return FLOAT_VALUE;}
(true)|(false) {yylval.val =(info *)malloc(sizeof(info)); yylval.val->strval = strdup(yytext); yylval.val->typeval = 2; return BOOL_VALUE;}
('.') {yylval.val =(info *)malloc(sizeof(info));  yylval.val->strval = strdup(yytext); yylval.val->typeval = 3; return STRING_VALUE;} 
\"(\\.|[^"\\])*\" {yylval.val =(info *)malloc(sizeof(info));  yylval.val->strval = strdup(yytext); yylval.val->typeval = 4; return STRING_VALUE;}


[a-zA-Z][_a-zA-Z0-9]* { yylval.strval = strdup(yytext); return IDENTIFIER;}
[ \t] ;
(\n) {yylineno++;}
. {}

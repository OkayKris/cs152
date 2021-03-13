%{   
   #include <stdio.h>
   #include "y.tab.h"
   using namespace std;
   extern int yyerror(char *s);
   int currLine = 1, currPos = 1;
   char * file;
%}

VAR	 	[a-zA-Z]+[a-zA-Z_0-9]*
DIGITCHECK	[0-9]
DIGIT		{DIGITCHECK}
COMMENT  	##.*

BADDIG	[0-9]+[a-zA-Z_]+[a-zA-Z_0-9]*
BADUNDER	[a-zA-Z]+[a-zA-Z_0-9]*_+

%%

"function"		{currPos += yyleng; return FUNCTION;}
"beginparams"	{currPos += yyleng; return BEGIN_PARAMS;}
"endparams"		{currPos += yyleng; return END_PARAMS;}
"beginlocals"	{currPos += yyleng; return BEGIN_LOCALS;}
"endlocals"		{currPos += yyleng; return END_LOCALS;}
"beginbody"		{currPos += yyleng; return BEGIN_BODY;}
"endbody"		{currPos += yyleng; return END_BODY;}
"integer"		{currPos += yyleng; return INTEGER;}
"array"			{currPos += yyleng; return ARRAY;}
"of"			   {currPos += yyleng; return OF;}
"if"			   {currPos += yyleng; return IF;}
"then"			{currPos += yyleng; return THEN;}
"endif"			{currPos += yyleng; return ENDIF;}
"else"			{currPos += yyleng; return ELSE;}
"while"			{currPos += yyleng; return WHILE;}
"do"			   {currPos += yyleng; return DO;}
"beginloop"		{currPos += yyleng; return BEGINLOOP;}
"endloop"		{currPos += yyleng; return ENDLOOP;}
"break"		   {currPos += yyleng; return BREAK;}
"read"			{currPos += yyleng; return READ;}
"write"			{currPos += yyleng; return WRITE;}
"and"			   {currPos += yyleng; return AND;}
"or"			   {currPos += yyleng; return OR;}
"not"			   {currPos += yyleng; return NOT;}
"true"		   {currPos += yyleng;return TRUE; }
"false"		   {currPos += yyleng; return FALSE;}
"return"	      {currPos += yyleng; return RETURN;}

";"			   {currPos += yyleng; return SEMICOLON;}
":"			   {currPos += yyleng; return COLON;}
","			   {currPos += yyleng; return COMMA;}
"("			   {currPos += yyleng; return L_PAREN;}
")"			   {currPos += yyleng; return R_PAREN;}
"["			   {currPos += yyleng; return L_SQUARE_BRACKET;}
"]"			   {currPos += yyleng; return R_SQUARE_BRACKET;}
":="		      {currPos += yyleng; return ASSIGN;}
"-"			   {currPos += yyleng; return SUB;}
"+"			   {currPos += yyleng; return ADD;}
"*"			   {currPos += yyleng; return MULT;}
"/"			   {currPos += yyleng; return DIV;}
"%"			   {currPos += yyleng; return MOD;}
"=="		      {currPos += yyleng; return EQ;}
"<>"		      {currPos += yyleng; return NEQ;}
"<"			   {currPos += yyleng; return LT;}
">"			   {currPos += yyleng; return GT;}
"<="		      {currPos += yyleng; return LTE;}
">="		      {currPos += yyleng; return GTE;}
"."            {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext);}
"?"            {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext);}


{VAR}+			{yylval.identName=strdup(yytext); currPos += yyleng; return IDENT;}
{DIGIT}+		   {yylval.numValue=atoi(yytext); currPos += yyleng; return NUMBER;}
{COMMENT}		{currLine++; currPos = 1;}
[ \t]+         {/* ignore spaces */ currPos += yyleng;}
"\n"           {currLine++; currPos = 1;}


%%

int main(int argc, char ** argv) {
   if (argc > 1){
      yyin = fopen(argv[1], "r");
      if (yying == NULL) {
         yyin = stdin;
      }
   }
   else {
      yyin = stdin;
   }
   
   yyparse();
   return 0;
}
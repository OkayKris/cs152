//C Declarations here
%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char * msg);
void toNewline(void);
%}

// Bison Declarations below

%union{
    char* identName;
    int numValue;
}

%define parse.error verbose
%define parse.lac full

%start Program

%token <identName> IDENT
%token <numValue> NUMBER

%token FUNCTION
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_BODY
%token END_BODY
%token INTEGER
%token ARRAY
%token OF
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DO
%token BEGINLOOP
%token ENDLOOP
%token BREAK
%token READ
%token WRITE
%left AND
%left OR
%right NOT
%token TRUE
%token FALSE
%token RETURN

%left SUB
%left ADD
%left MULT
%left DIV
%left MOD

%left EQ
%left NEQ
%left LT
%left GT
%left LTE
%left GTE

%token SEMICOLON
%token COLON
%token COMMA
%token L_PAREN
%token R_PAREN
%token R_SQUARE_BRACKET
%token L_SQUARE_BRACKET
%left ASSIGN

// Grammar rules below

%%

Ident:      IDENT
            {printf("Ident -> IDENT %s \n", yylval.identName);}
                | error
                {toNewline(); yyerrok; yyclearin; }
;

Identifiers:    Ident
                {printf("Identifiers -> Ident\n");}
                | Ident COMMA Identifiers
                {printf("Identifiers -> Ident COMMA Identifiers\n");}
;

Program:    %empty
            {printf("Program -> epsilon\n");}
            | Function Program
            {printf("Program -> Function Program\n");}
;

Function:   FUNCTION Ident SEMICOLON BEGIN_PARAMS Declarations END_PARAMS BEGIN_LOCALS Declarations END_LOCALS BEGIN_BODY Statements END_BODY
            {printf("Function -> FUNCTION Ident SEMICOLON BEGIN_PARAMS Declarations SEMICOLON END_PARAMS BEGIN_LOCALS Declarations SEMICOLON END_LOCALS BEGIN_BODY Statements SEMICOLON END_BODY\n");}
;

Declarations:   %empty
                {printf("Declarations -> epsilon\n");}
                | Declaration SEMICOLON Declarations
                {printf("Declarations -> Declaration SEMICOLON Declarations\n");}
;
            
Declaration:    Identifiers COLON INTEGER
                {printf("Declaration -> Identifiers COLON INTEGER\n");}
                | Identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
                {printf("Declaration -> Identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER\n");}
;

Statements:     Statement SEMICOLON Statements
                {printf("Statements -> Statement SEMICOLON Statements\n");}
                | Statement SEMICOLON
                {printf("Statements -> Statement SEMICOLON\n");}
;

Statement:      Var ASSIGN Expression
                {printf("Statement -> Var ASSIGN Expression\n");}
                | IF bool_exp THEN Statements ENDIF
                {printf("Statement -> IF bool_exp THEN Statements ENDIF\n");}
                | IF bool_exp THEN Statements ELSE Statements ENDIF
                {printf("Statement -> IF bool_exp THEN Statements ELSE Statements ENDIF\n");}
                | WHILE bool_exp BEGINLOOP Statements ENDLOOP
                {printf("Statement -> WHILE bool_exp BEGINLOOP Statements ENDLOOP\n");}
                | DO BEGINLOOP Statements ENDLOOP WHILE bool_exp
                {printf("Statement -> DO BEGINLOOP Statements ENDLOOP WHILE bool_exp\n");}
                | READ Vars
                {printf("Statement -> READ Vars\n");}
                | WRITE Vars
                {printf("Statement -> WRITE Vars\n");}
                | BREAK
                {printf("Statement -> BREAK\n");}
                | RETURN Expression
                {printf("Statement -> RETURN Expression\n");}
                | error
                {toNewline(); yyerrok; yyclearin; }
;
                
Vars:           Var
                {printf("Vars -> Var\n");}
                | Var COMMA Vars
                {printf("Vars -> Var COMMA Vars\n");}
;

Var:            Ident
                {printf("Var -> Ident \n");}
                | Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
                {printf("Ident L_SQUARE BRACKET Expression R_SQUARE BRACKET\n");}
;

bool_exp:       rAndExp
                {printf("bool_exp -> rAndExp\n");}
                | rAndExp OR bool_exp
                {printf("bool_exp -> rAndExp OR bool_exp\n");}
;

rAndExp:        rExpN
                {printf("rAndExp -> rExp\n");}
                | rExpN AND rAndExp
                {printf("rAndExp -> rExp AND rAndExp\n");}
;

rExpN:          NOT rExp
                {printf("rExpN -> NOT rExp\n");}
                | rExp
                {printf("rExpN -> rExp\n");}
;

rExp:           Expression Comp Expression
                {printf("rExp -> Expression Comp Expression\n");}
                | TRUE
                {printf("rExp -> TRUE\n");}
                | FALSE
                {printf("rExp -> FALSE\n");}
                | L_PAREN bool_exp R_PAREN
                {printf("rExp -> L_PAREN bool_exp R_PAREN\n");}
                | error
                {toNewline(); yyerrok; yyclearin; }
;

Comp:           EQ
                {printf("Comp -> EQ\n");}
                | NEQ
                {printf("Comp -> NEQ\n");}
                | GT
                {printf("Comp -> GT\n");}
                | LT
                {printf("Comp -> LT\n");}
                | GTE
                {printf("Comp -> GTE\n");}
                | LTE
                {printf("Comp -> LTE\n");}
;

Expression:     multExp
                {printf("Expression -> multExp\n");}
                | multExp ADD Expression
                {printf("Expression -> multExp ADD Expression\n");}
                | multExp SUB Expression
                {printf("Expression -> multExp SUB Expression\n");}
;

multExp:        Term
                {printf("multExp -> Term\n");}
                | Term MULT multExp
                {printf("multExp -> Term MULT multExp\n");}
                | Term DIV multExp
                {printf("multExp -> Term DIV multExp\n");}
                | Term MOD multExp
                {printf("multExp -> Term MOD multExp\n");}
;

Term:           Var
                {printf("Term -> Var\n");}
                | SUB Var
                {printf("Term -> SUB Var\n");}
                | NUMBER
                {printf("Term -> NUMBER %d\n", $1);}
                | SUB NUMBER
                {printf("Term -> SUB NUMBER %d\n", $2);}
                | L_PAREN Expression R_PAREN
                {printf("Term -> L_PAREN Expression R_PAREN\n");}
                | SUB L_PAREN Expression R_PAREN
                {printf("Term -> SUB L_PAREN Expression R_PAREN\n");}
                | Ident L_PAREN Expressions R_PAREN
                {printf("Term -> Ident L_PARENT Expression R_PAREN\n");}
                | error
                {toNewline(); yyerrok; yyclearin; }
;

Expressions:    %empty
                {printf("Expressions -> epsilon\n");}
                | Expression
                {printf("Expressions -> Expression\n");}
                | Expression COMMA Expressions
                {printf("Expressions -> Expression COMMA Expressions\n");}
                | error
                {toNewline(); yyerrok; yyclearin; }
;

%%
// Need to add more error cases here
void yyerror(const char * msg) {
    extern int currLine;
    extern char* yytext;

    printf("Syntax error at line %d: %s at symbol \"%s\"\n", currLine, msg, yytext);
    // yyparse();
}

void toNewline(void) {
    int n;
    while ((n = getchar()) != EOF && n != '\n')
        ;
}
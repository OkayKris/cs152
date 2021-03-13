//C Declarations here
%code requires{
  #include <string>
  using namespace std;
  
  struct nonTerminal {
    string code;
    string index;
    string ret_name;
    string var;
    bool isArray;
  };
}

%{
#define YY_NO_UNPUT
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include <string.h>
#include <vector>
#include <iostream>
#include <sstream>
using namespace std; 

extern int currPos;
extern int currLine;
int yyerror(string s);
// void toNewline(void);
int yylex(void);
string newTemp();
string newLabel();
string newVar(char*);
string findIndex(const string&);
bool breakCheck(const string &ref);
void replaceString(string&, const string&, const string&);
bool isValDeclared(const vector<string>&, const string);
void newLocalVar(const string&);
void checkDeclared(const string&);
void newFunction(const string&);
void checkDeclaredFunc(const string &);
bool mCheck = false;
extern FILE* yyin;

vector<string> variableNames;
vector<string> functionNames;

%}

// Bison Declarations below

%union{
    char* identName;
    int numValue;
    nonTerminal* nonTerm;
}

%define parse.error verbose
%define parse.lac full

%start Program
%token <identName> IDENT
%token <numValue> NUMBER

%type <nonTerm> Ident Identifiers Declarations Declaration Var Vars bool_exp Program Function FunctionBody FunctionLocals FunctionParameters
%type <nonTerm> rAndExp rExpN rExp Statements Statement Expression multExp Term InnerTerm Expressions
%type <identName> Comp

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
%token AND
%token OR
%token NOT
%token TRUE
%token FALSE
%token RETURN

%token SUB
%token ADD
%token MULT
%token DIV
%token MOD

%token EQ
%token NEQ
%token LT
%token GT
%token LTE
%token GTE

%token SEMICOLON
%token COLON
%token COMMA
%token L_PAREN
%token R_PAREN
%token R_SQUARE_BRACKET
%token L_SQUARE_BRACKET
%token ASSIGN

// Grammar rules below

%%

Ident:      IDENT
            {
              $$ = new nonTerminal();
              $$->code = $1;
            }
;

Identifiers:    Ident
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  s << "_" << $1->code;
                  $$->code = s.str();
                }
                | Ident COMMA Identifiers
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  s << "_" << $1->code << "," << $3->code;
                  $$->code = s.str();
                }
;

Program:    %empty
            {
              $$ = new nonTerminal();
              cout << $$->code << endl;
            }
            | Function Program
            {
              $$ = new nonTerminal();
              if (!mCheck) {
                yyerror("\"main\" function not defined in program.");
              }
              stringstream s;
              s << $1->code << endl << endl << $2->code;
              $$->code = s.str();
            }
;

Function:   FUNCTION Ident SEMICOLON FunctionParameters FunctionLocals FunctionBody
            {
              $$ = new nonTerminal();
              stringstream s;

              if ($2->code == "main") {
                mCheck = true;
              }

              newFunction($2->code);
              variableNames.clear();

              s << "func " << $2->code << endl;

              s << $4->code;
              if ($4->code.length() > 0) {s << endl;}

              s << $5->code;
              if ($5->code.length() > 0) {s << endl;}

              s << $6->code;
              if ($6->code.length() > 0) {s << endl;}

              s << "endfunc";
              $$->code = s.str();
            }
;

FunctionParameters: BEGIN_PARAMS Declarations END_PARAMS
                {
                  $$ = new nonTerminal();
                  stringstream s;

                  s << $2->code << endl;

                  string ident;
                  int paramNum = 0;
                  for (unsigned i = 0; i < $2->ret_name.length(); ++i) {
                    if ($2->ret_name[i] == ',') {
                      s << "= " << ident << ", $" << to_string(paramNum) << endl;
                      ident = "";
                      paramNum++;
                      continue;
                    }
                    ident.push_back($2->ret_name[i]);
                  }

                  if (ident.length() > 0) {
                    s << "= " << ident << ", $" << to_string(paramNum);
                  }


                  $$->code = s.str();
                }
                | BEGIN_PARAMS END_PARAMS
                {
                  $$ = new nonTerminal();
                }
;

FunctionLocals: BEGIN_LOCALS Declarations END_LOCALS
                {
                  $$ = new nonTerminal();
                  $$->code = $2->code;
                }
                | BEGIN_LOCALS END_LOCALS
                {
                  $$ = new nonTerminal();
                }
;

FunctionBody:   BEGIN_BODY Statements END_BODY
                {
                  if (breakCheck($2->code)) {
                    cout << "Error: breaak statement not within a loop." << endl;
                    exit(1);
                  }

                  $$ = new nonTerminal();
                  $$->code = $2->code;
                }
                | BEGIN_BODY END_BODY
                {
                  $$ = new nonTerminal();
                }
; 

Declarations:   %empty
                {
                  $$ = new nonTerminal();
                  cout << $$->code << endl;
                }
                | Declaration SEMICOLON Declarations
                {
                  $$ = new nonTerminal();
                  stringstream s, slist;

                  s << $1->code << endl << $3->code;

                  slist << $1->ret_name << "," << $3->ret_name;

                  $$->code = s.str();
                  $$->ret_name = slist.str();
                }
;
            
Declaration:    Identifiers COLON INTEGER
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  string currVar = "";

                  // s << ". ";
                  for (unsigned i = 0; i < $1->code.length(); ++i) {
                    if ($1->code.at(i) == ',') {
                      s << ". " << currVar << endl;
                      newLocalVar(currVar);
                      currVar = "";
                    }
                    else {
                      // s << $1->code.at(i);
                      currVar.push_back($1->code[i]);
                    }
                  }

                  if (currVar.length() > 0) {
                    s << ". " << currVar;
                    newLocalVar(currVar);
                  }
                  
                  $$->code = s.str();
                  $$->ret_name = $1->code; // pass identlist up
                }
                | Identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
                {
                  string buffer;
                  if ($5 <= 0) {
                    yyerror("array size < 1");
                  }

                  // FIX
                  $$ = new nonTerminal();
                  stringstream s;
                  string currVar = "";

                  for (unsigned i = 0; i < $1->code.length(); ++i) {
                    if ($1->code.at(i) == ',') {
                      s << ".[] " << currVar << ", " << to_string($5) << endl;
                      newLocalVar(currVar);
                      currVar = "";
                    }
                    else {
                      currVar.push_back($1->code[i]);
                    }
                  }

                  if (currVar.length() > 0 ) {
                    s << ".[] " << currVar << ", " << to_string($5);
                    newLocalVar(currVar);
                  }
                  
                  $$->code = s.str();
                  $$->ret_name = $1->code;
                }
                // | error
                // {toNewline(); yyerrok; yyclearin;}
;

Statements:     Statement SEMICOLON Statements
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  s << $1->code << endl << $3->code;
                  $$->code = s.str();
                }
                | Statement SEMICOLON
                {
                  $$ = new nonTerminal();
                  $$->code = $1->code;
                }
;

Statement:      Var ASSIGN Expression
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  string assign;

                  if ($3->ret_name != "") {
                    s << $3->code << endl;
                    assign = $3->ret_name;
                  }
                  else {
                    assign = $3->code;
                  }

                  if ($1->isArray) {
                    if ($1->code.length() > 0) {
                      s << $1->code << endl;
                    }
                    s << "[]= " << $1->var << ", " << $1->index << ", " << assign;
                  }
                  else {
                    s << "= " << $1->code << ", " << assign;
                  }

                  $$->code = s.str();
                  $$->ret_name = $1->code;
                }
                | IF bool_exp THEN Statements ENDIF
                {
                  $$ = new nonTerminal();
                  string isTrue = newLabel();
                  string isFalse = newLabel();
                  stringstream s;
                  s << $2->code << endl;
                  s << "?:= " << isTrue << ", " << $2->ret_name << endl;
                  s << ":= " << isFalse << endl;
                  s << ": " << isTrue << endl;
                  s << $4->code << endl;
                  s << ": " << isFalse;

                  $$->code = s.str();
                  // $$->ret_name = ???
                }
                | IF bool_exp THEN Statements ELSE Statements ENDIF
                {
                  $$ = new nonTerminal();
                  string label0 = newLabel();
                  string label1 = newLabel();
                  stringstream s;
                  s << $2->code << endl;
                  s << "?:= " << label0 << ", " << $2->ret_name << endl;
                  s << ":=" << label1 << endl;
                  s << ": " << label0 << endl;
                  s << $4->code << endl;
                  s << ": " << label1 ;
                  s << $6->code;

                  $$->code = s.str();
                }
                | WHILE bool_exp BEGINLOOP Statements ENDLOOP
                {
                  $$ = new nonTerminal();
                  string conditionLabel = newLabel();
                  string startLabel = newLabel();
                  string endLabel = newLabel();
                  stringstream s;

                  string replaceBreak = ":= " + conditionLabel;
                  replaceString($4->code, "break", replaceBreak);

                  s << ": " << conditionLabel << endl;
                  s << $2->code << endl;
                  s << "?:= " << startLabel << ", " << $2->ret_name << endl;
                  s << ":= " << endLabel << endl;
                  s << ": " << startLabel << endl;
                  s << $4->code << endl; 
                  s << ":= " << conditionLabel << endl; 
                  s << ": " << endLabel;

                  $$->code = s.str();
                }
                | DO BEGINLOOP Statements ENDLOOP WHILE bool_exp
                {
                  $$ = new nonTerminal();
                  string startLabel = newLabel();
                  string conditionLabel = newLabel();
                  stringstream s;

                  string replaceBreak = ":= " + conditionLabel;
                  replaceString($3->code, "break", replaceBreak);

                  s << ": " << startLabel << endl;
                  s << $3->code << endl;
                  s << ": " << conditionLabel << endl;
                  s << $6->code << endl;
                  s << "?:= " << startLabel << ", " << $6->ret_name;

                  $$->code = s.str();
                }
                | READ Vars
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  string tmp = "";
                  for (unsigned i = 0; i < $2->code.length(); ++i) {
                    if ($2->code[i] == ',') {
                      s << ".< " << tmp << endl;
                      tmp = "";
                    }
                    else {
                      tmp.push_back($2->code[i]);
                    }
                  }

                  s << ".< " << tmp;

                  $$->code = s.str();
                }
                | WRITE Vars
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  string tmp = "";
                  for (unsigned i = 0; i < $2->code.length(); ++i) {
                    if ($2->code[i] == ',') {
                      s << ".< " << tmp << endl;
                      tmp = "";
                    }
                    else {
                      tmp.push_back($2->code[i]);
                    }
                  }

                  s << ".> " << tmp;

                  $$->code = s.str();
                }
                | BREAK // need to add break cases
                {
                  $$ = new nonTerminal();
                  $$->code = "break";
                }
                | RETURN Expression
                {
                  $$ = new nonTerminal();
                  stringstream s;

                  string op1;

                  if ($2->ret_name != "") {
                    // $1 is var or expression
                    s << $2->code << endl;
                    op1 = $2->ret_name;

                  }
                  else {
                    // $2 is num : need to make new temp
                    op1 = newTemp();
                    s << ". " << op1 << endl;
                    s << "= " << op1 << ", " << $2->code << endl;
                  }

                  s << "ret " << op1;
                  
                  $$->code = s.str();
                  $$->ret_name = op1;
                }
                // | error
                // {toNewline(); yyerrok; yyclearin; }
;
                
Vars:           Var
                {
                  $$ = new nonTerminal();
                  $$->code = $1->var;
                  $$->isArray = $1->isArray;
                }
                | Var COMMA Vars
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  s << $1->var << "," << $3->code;
                  $$->code = s.str();

                  if ($1->isArray != $3->isArray) {
                    stringstream er;
                    er << "variable \"" << $1->code << "\" is of type ";
                    if ($1->isArray) {
                      er << "array.";
                    }
                    else {
                      er << "integer.";
                    }

                    yyerror(er.str());
                  }
                  $$->isArray = $1->isArray;
                }
;

Var:            Ident
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  s << "_" << $1->code;

                  checkDeclared(s.str());

                  $$->code = s.str();
                  $$->var = s.str();
                  $$->isArray = false;
                }
                | Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  string index, code = "";

                  if ($3->ret_name != "") {
                    // $3 is var or expression
                    code = $3->code;
                    index = $3->ret_name;
                  }
                  else {
                    // $1 is num
                    index = $3->code; // set op to number
                  }

                  s << "_" << $1->code;

                  // Error 1 of 9: Using a variable without having first declared it.
                  checkDeclared(s.str());

                  $$->code = code;
                  $$->isArray = true;
                  $$->var = s.str();
                  $$->index = index;
                }
;

bool_exp:       rAndExp
                {
                  $$ = new nonTerminal();
                  $$->code = $1->code;
                  $$->ret_name = $1->ret_name;
                }
                | rAndExp OR bool_exp
                {
                  $$ = new nonTerminal();
                  string returnName = newTemp(); // OR statement result location
                  stringstream s;

                  s << $1->code << endl << $3->code << endl; // Add nested expression code to the stream
                  s << ". " << returnName << endl; // Add new return name to the output
                  s << "|| " << returnName << ", " << $1->ret_name << ", " << $3->ret_name; // Add the logical OR statement
                  
                  $$->code = s.str();
                  $$->ret_name = returnName;
                }
;

rAndExp:        rExpN
                {
                  $$ = new nonTerminal();
                  $$->code = $1->code;
                  $$->ret_name = $1->ret_name;
                }
                | rExpN AND rAndExp
                {
                  $$ = new nonTerminal();
                  string retName = newTemp();

                  stringstream s;
                  s << $1->code << endl << $3->code << endl;
                  s << ". " << retName << endl;
                  s << "&& " << retName << ", " << $1->ret_name << ", " << $3->ret_name;

                  $$->code = s.str();
                  $$->ret_name = retName;
                }
;

rExpN:          NOT rExp
                {
                  $$ = new nonTerminal();
                  string notVar = newTemp();

                  stringstream s;

                  s << $2->code << endl;
                  s << "! " << notVar << ", " << $2->ret_name;
                  $$->code = s.str();
                  $$->ret_name = notVar;
                }
                | rExp
                {
                  $$ = new nonTerminal();
                  $$->code = $1->code;
                  $$->ret_name = $1->ret_name;
                }
;

rExp:           Expression Comp Expression
                {
                  $$ = new nonTerminal();
                  string compRet = newTemp();
                  stringstream s;
                  string op1;

                  if ($1->ret_name != "") {
                    s << $1->code << endl;
                    op1 = $1->ret_name;
                  }

                  else {
                    op1 = $1->code;
                  }

                  if ($3->ret_name != "") {
                    s << $3->code << endl;
                    s << ". " << compRet << endl;
                    s << $2 << " " << compRet << ", " << op1 << ", " << $3->ret_name;
                  }
                  else {
                    s << ". " << compRet << endl;
                    s << $2 << " " << compRet << ", " << op1 << ", " << $3->code;
                  }

                  $$->code = s.str();
                  $$->ret_name = compRet;
                }
                | TRUE
                {
                  $$ = new nonTerminal();
                  string trTemp = newTemp();
                  stringstream s;

                  s << ". " << trTemp << endl;
                  s << "= " << trTemp << ", 1";
                  $$->code = s.str();
                  $$->ret_name = trTemp;
                }
                | FALSE
                {
                  $$ = new nonTerminal();
                  string fTemp = newTemp();
                  stringstream s;

                  s << ". " << fTemp << endl;
                  s << "= " << fTemp << ", 0";
                  $$->code = s.str();
                  $$->ret_name = fTemp;
                }
                | L_PAREN bool_exp R_PAREN
                {
                  $$ = new nonTerminal();
                  $$->code = $2->code;
                  $$->ret_name = $2->ret_name;
                }
;

Comp:           EQ
                {}
                | NEQ
                {}
                | GT
                {}
                | LT
                {}
                | GTE
                {}
                | LTE
                {}
;

Expression:     multExp
                {
                  $$ = new nonTerminal();
                  $$->code = $1->code;
                  $$->ret_name = $1->ret_name;
                }
                | multExp ADD Expression
                {
                  $$ = new nonTerminal();
                  string addRet = newTemp();
                  stringstream s;
                  string op1;

                  if ($1->ret_name != "") {
                    s << $1->code << endl;
                    op1 = $1->ret_name;
                  }
                  else {
                    op1 = $1->code;
                  }

                  if ($3->ret_name != "") {
                    s << $3->code << endl;
                    s << ". " << addRet << endl;
                    s << "+ " << addRet << ", " << op1 << ", " << $3->ret_name;
                  }
                  else {
                    s << ". " << addRet << endl;
                    s << "+ " << addRet << ", " << op1 << ", " << $3->code;
                  }

                  $$->code = s.str();
                  $$->ret_name = addRet;
                }
                | multExp SUB Expression
                {
                  $$ = new nonTerminal();
                  string subRet = newTemp();
                  stringstream s;
                  string op1;

                  if ($1->ret_name != "") {
                    s << $1->code << endl;
                    op1 = $1->ret_name;
                  }
                  else {
                    op1 = $1->code;
                  }

                  if ($3->ret_name != "") {
                    s << $3->code << endl;
                    s << ". " << subRet << endl;
                    s << "- " << subRet << ", " << op1 << ", " << $3->ret_name;
                  }
                  else {
                    s << ". " << subRet << endl;
                    s << "- " << subRet << ", " << op1 << ", " << $3->code;
                  }

                  $$->code = s.str();
                  $$->ret_name = subRet;
                }
;

multExp:        Term
                {
                  $$ = new nonTerminal();
                  $$->code = $1->code;
                  $$->ret_name = $1->ret_name;
                }
                | Term MULT multExp
                {
                  $$ = new nonTerminal();
                  string multResult = newTemp();
                  stringstream s;
                  string op1;

                  if ($1->ret_name != "") {
                    // $1 is var or expression
                    s << $1->code << endl;
                    op1 = $1->ret_name;

                  }
                  else {
                    // $1 is num
                    op1 = $1->code; // set op to number
                  }


                  if ($3->ret_name != "") {
                    s << $3->code << endl;
                    s << ". " << multResult << endl;
                    s << "* " << multResult << ", " << op1 << ", " << $3->ret_name;  
                  }
                  else {
                    s << ". " << multResult << endl;
                    s << "* " << multResult << ", " << op1 << ", " << $3->code;
                  }

                  $$->code = s.str();
                  $$->ret_name = multResult;
                }
                | Term DIV multExp
                {
                  $$ = new nonTerminal();
                  string divResult = newTemp();
                  stringstream s;
                  string op1;

                  if ($1->ret_name != "") {
                    // $1 is var or expression
                    s << $1->code << endl;
                    op1 = $1->ret_name;

                  }
                  else {
                    // $1 is num
                    op1 = $1->code; // set op to number
                  }


                  if ($3->ret_name != "") {
                    s << $3->code << endl;
                    s << ". " << divResult << endl;
                    s << "/ " << divResult << ", " << op1 << ", " << $3->ret_name;  
                  }
                  else {
                    s << ". " << divResult << endl;
                    s << "/ " << divResult << ", " << op1 << ", " << $3->code;
                  }

                  $$->code = s.str();
                  $$->ret_name = divResult;
                }
                | Term MOD multExp
                {
                  $$ = new nonTerminal();
                  string multResult = newTemp();
                  stringstream s;
                  string op1;

                  if ($1->ret_name != "") {
                    // $1 is var or expression
                    s << $1->code << endl;
                    op1 = $1->ret_name;

                  }
                  else {
                    // $1 is num
                    op1 = $1->code; // set op to number
                  }


                  if ($3->ret_name != "") {
                    s << $3->code << endl;
                    s << ". " << multResult << endl;
                    s << "* " << multResult << ", " << op1 << ", " << $3->ret_name;  
                  }
                  else {
                    s << ". " << multResult << endl;
                    s << "* " << multResult << ", " << op1 << ", " << $3->code;
                  }

                  $$->code = s.str();
                  $$->ret_name = multResult;
                }
;

Term:           InnerTerm
                {
                  $$ = new nonTerminal();

                  if ($1->ret_name == "var") {
                    // is var
                    string temp = newTemp();
                    stringstream s;
                    
                    if ($1->isArray) {
                      // FIX
                      if ($1->code.length() > 0) {
                        s << $1->code << endl;
                      }
                      s << "=[] " << temp << ", " << $1->var << ", " << $1->index;
                      $$->var = $1->var;
                      $$->index = $1->index;
                    }
                    else {
                      s << ". " << temp << endl; // create new temp
                      s << "= " << temp << ", " << $1->code;
                    }

                    $$->code = s.str();
                    $$->ret_name = temp;
                  }
                  else if ($1->ret_name == "num") {
                    $$->code = $1->code;
                    $$->ret_name = "";
                  }
                  else {
                    $$->code = $1->code;
                    $$->ret_name = $1->ret_name;
                  }
                }
                | SUB InnerTerm
                {
                  $$ = new nonTerminal();
                  stringstream s;
                  string subTemp = newTemp();

                  if ($2->ret_name == "var") {
                    // is var
                    string temp = newTemp();
                    
                    if ($2->isArray) {
                      if ($2->code.length() > 0) {
                        s << $2->code << endl;
                      }
                      s << "=[] " << temp << ", " << $2->var << ", " << $2->index << endl;

                      $$->var = $2->var;
                      $$->index = $2->index;
                    }
                    else {
                      s << ". " << temp << endl; // create new temp
                      s << "= " << temp << ", " << $2->code << endl;
                    }

                    s << ". " << subTemp << endl;
                    s << "- " << subTemp << ", 0, " << temp;

                    $$->code = s.str();
                    $$->ret_name = subTemp;
                  }
                  else {
                    s << ". " << subTemp << endl;
                    s << "- " << subTemp << ", 0, " << $2->code;

                    $$->code = s.str();
                    $$->ret_name = subTemp;
                  }
                }
                | Ident L_PAREN Expressions R_PAREN
                {
                  $$ = new nonTerminal();
                  string nTemp = newTemp();
                  stringstream s, srt;

                  s << $3->code << endl; // add all expressions code to output
                  // iterate through $3->ret_name to find all params : ret_name1,ret_name2
                  string temp;
                  for (unsigned i = 0; i < $3->ret_name.length(); ++i) {
                    if ($3->ret_name[i] == ',') {
                      srt << "param " << temp << endl;
                      temp = "";
                      continue;
                    }
                    temp.push_back($3->ret_name[i]);
                  }

                  if (temp.length() > 0) { // only add to code stream if at least 1 ret_name exists
                    srt << "param " << temp << endl; // add last ret_name to output
                    s << srt.str(); // add ret_name stream to code stream
                  }

                  s << ". " << nTemp << endl;
                  s << "call " << $1->code << ", " << nTemp;

                  $$->code = s.str();
                  $$->ret_name = nTemp;
                }
;

InnerTerm:      Var
                {
                  $$ = new nonTerminal();
                  $$->code = $1->code;
                  $$->ret_name = "var";
                  $$->isArray = $1->isArray;
                  $$->var = $1->var;
                  $$->index = $1->index;
                }
                | NUMBER
                {
                  $$ = new nonTerminal();
                  $$->code = to_string($1);
                  $$->ret_name = "num";
                }
                | L_PAREN Expression R_PAREN
                {
                  $$ = new nonTerminal();
                  stringstream s;

                  s << $2->code;
                  $$->code = s.str();
                  $$->ret_name = $2->ret_name;
                }
;

Expressions:    %empty
                {
                  $$ = new nonTerminal();
                }
                | Expression
                {
                  $$ = new nonTerminal();
                  $$->code = $1->code;
                  $$->ret_name = $1->ret_name;
                }
                | Expression COMMA Expressions
                {
                  $$ = new nonTerminal();
                  stringstream scde, srt;

                  scde << $1->code << endl << $3->code;

                  srt << $3->ret_name << "," << $3->ret_name;

                  $$->code = scde.str();
                  $$->ret_name = srt.str();
                }
;

%%
// Need to add more error cases here
// void yyerror(const char * msg) {
//     extern int currLine;
//     extern char* yytext;

//     printf("Syntax error at line %d: %s at symbol \"%s\"\n", currLine, msg, yytext);
//     // yyparse();
// }

int yyerror(string s) {
  extern int currLine, currPos;
  extern char* yytext;

  cout << "Error line: " << currLine << ": " << s << endl;
  exit(1);
}

int yyerror(char* s) {
  return yyerror(string(s));
}

// void toNewline(void) {
//     int n;
//     while ((n = getchar()) != EOF && n != '\n')
//         ;
// }

string newTemp() {
  static int num = 0;
  string temp ="__temp__" + to_string(num++);
  return temp;
}

string newLabel(){
  static int num = 0;
  string temp = "__label__" + to_string(num++);
  return temp;
}

string newVar(char* ident) {
  string nvar = string(ident);
  return nvar;
}

string findIndex(const string &ref) {
  unsigned brLeft = ref.find('[');
  if (brLeft != string::npos) {
    // [ exists at brLeft, ] exists at ref.length() - 1
    int indexLength = ((ref.length() - 1) - brLeft) - 1;
    return ref.substr(brLeft + 1, indexLength);
  }
  else {
    // return yyerror("Tried to find index in a non-array variable.");
    exit(1);
  }
}

bool breakCheck(const string &ref) {
  if (ref.find("break") == string::npos) {
    return false;
  }
  return true;
}

void replaceString(string& str, const string& oldStr, const string& newStr) {
  string::size_type pos = 0u;
  while((pos = str.find(oldStr, pos)) != string::npos) {
    str.replace(pos, oldStr.length(), newStr);
    pos += newStr.length();
  }
}

bool isValDeclared(const vector<string>& symTable, const string& var) {
  for (unsigned i = 0; i < symTable.size(); ++i) {
    if (symTable.at(i) == var) {
      return true;
    }
  }
  return false;
}

void newLocalVar(const string& var){
  for (unsigned i = 0; i < variableNames.size(); ++i) {
    if (variableNames.at(i) == var) {
      string errString = "symbol \"" + var + "\" is multiply-defined.";
      yyerror(errString);
    }
  }
  variableNames.push_back(var);
}

void checkDeclared(const string& var){
  for (unsigned i = 0; i < variableNames.size(); ++i) {
    if (variableNames.at(i) == var) {
      return;
    }
  }

  string err = "used variable \"" + var + "\" was not previously declared.";
  yyerror(err);
}

void newFunction(const string& func){
  for (unsigned i = 0; i < functionNames.size(); ++i) {
    if (functionNames.at(i) == func) {
      string errString = "function \"" + func + "\" is multiply-defined";
      yyerror(errString);
    }
  }
  functionNames.push_back(func);
}

void checkDeclaredFunc(const string & func) {
  for (unsigned i = 0; i < functionNames.size(); ++i) {
    if (functionNames.at(i) == func) {
      return;
    }
  }
  string errString = "called function \"" + func + "\" was not previously declared.";
  yyerror(errString);
}

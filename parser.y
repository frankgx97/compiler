%{
#include <stdio.h>
#include <stdlib.h>
//#include "symbols.h"
#define YYSTYPE char *

extern FILE * yyin;
extern FILE * yyout;

void yyerror(const char*); 
int yylex();
%}

%token NO_ID NUM K_INT K_ELSE K_IF K_RETURN K_VOID K_WHILE ID K_PRINTF
%token ID O_ASSIGN O_COMMA O_SEMI O_LSBRACKER O_RSBRACKER O_LMBRACKER 
%token O_RMBRACKER O_LLBRACKER O_RLBRACKER O_ADD O_SUB O_MUL O_DIV O_LESS O_L_EQUAL O_GREATER O_G_EQUAL O_EQUAL O_U_EQUAL
%token COMMENT SPACES U_LEGAL

%left '+' '-'
%left '*' '/'
%right U_neg

%define parse.error verbose 
%locations

%start S

%%

S:   
    Stmt                        { /* empty */ }
|   S Stmt                      { /* empty */ }
;

Stmt:
    Declare O_SEMI                 { printf("\n\n"); }
|   Assign                      { /* empty */ }
|   Printf                       { /* empty */ }
;

Declare:
    K_INT ID                { printf("var %s", $2); }
|   Declare O_COMMA ID    { printf(", %s", $3); }
;

Assign:
    ID O_ASSIGN E O_SEMI      { printf("pop %s\n\n", $1); }
;

Printf:
    K_PRINTF '(' NO_ID')' ';' { printf("print %s\n\n", $3); }
;

E:
    E O_ADD E                     { printf("add\n"); }
|   E O_SUB E                     { printf("sub\n"); }
|   E O_MUL E                     { printf("mul\n"); }
|   E O_DIV E                     { printf("div\n"); }
|   O_SUB E %prec U_neg           { printf("neg\n"); }
|   NUM                         { printf("push %s\n", $1); }
|   ID                          { printf("push %s\n", $1); }
|   '(' E ')'                   { /* empty */ }
;

%%

int main(int argc,char* argv[]) {
	//yyin  = fopen( "in.txt",  "r" );
	//yyout = fopen( "out.txt", "w" );
    yyin = fopen(argv[1],"r");
	//while(yylex());
    return yyparse();
}
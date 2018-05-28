%{
#include <stdio.h>
#include <stdlib.h>
#define YYSTYPE char *

extern FILE * yyin;
extern FILE * yyout;

void yyerror(const char*); 
int yylex();
%}

%token NO_ID NUM K_INT K_ELSE K_IF K_RETURN K_VOID K_WHILE ID K_PRINTF

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
    Declare ';'                 { printf("\n\n"); }
|   Assign                      { /* empty */ }
|   Printf                       { /* empty */ }
;

Declare:
    K_INT ID          { printf("var %s", $2); }
|   Declare ',' ID    { printf(", %s", $3); }
;

Assign:
    ID '=' E ';'      { printf("pop %s\n\n", $1); }
;

Printf:
    K_PRINTF '(' NO_ID')' ';' { printf("print %s\n\n", $3); }
;

E:
    E '+' E                     { printf("add\n"); }
|   E '-' E                     { printf("sub\n"); }
|   E '*' E                     { printf("mul\n"); }
|   E '/' E                     { printf("div\n"); }
|   '-' E %prec U_neg           { printf("neg\n"); }
|   NUM                         { printf("push %s\n", $1); }
|   ID                          { printf("push %s\n", $1); }
|   '(' E ')'                   { /* empty */ }
;

%%
/*
void yyerror(const char* msg) {
    //sprintf(stderr, "%s\n", msg);
    printf("%s", msg);
}*/

int main(int argc,char* argv[]) {
	//yyin  = fopen( "in.txt",  "r" );
	//yyout = fopen( "out.txt", "w" );
    yyin = fopen(argv[1],"r");
	while(yylex());
    yyparse();
}
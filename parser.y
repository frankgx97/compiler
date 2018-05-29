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

%token K_INT K_ELSE K_IF K_RETURN K_VOID K_WHILE K_PRINTF
%token ID NO_ID NUM 
%token O_ASSIGN O_COMMA O_SEMI O_LSBRACKER O_RSBRACKER O_LMBRACKER O_RMBRACKER O_LLBRACKER O_RLBRACKER
%token O_ADD O_SUB O_MUL O_DIV O_LESS O_L_EQUAL O_GREATER O_G_EQUAL O_EQUAL O_U_EQUAL
%token COMMENT SPACES U_LEGAL

%left '+' '-'
%left '*' '/'
%right U_neg

%define parse.error verbose 
%locations


%%

Program:
        /**/                                {/**/}
|       Program FunctionDeclare             {/**/}
;

FunctionDeclare:
    ReturnType FunctionName O_LSBRACKER Args O_RSBRACKER O_LLBRACKER FunctionContent O_RLBRACKER {/**/}
;

ReturnType:
    K_INT                       {/**/}
|    K_VOID                      {/**/}
;

FunctionName:
    ID                          {/**/}
;

Args:
    ArgType ID                      {/**/}
;

ArgType:
    K_INT                   {/**/}
;


FunctionContent:
    Stmts                        {/**/}
;

Stmts:
    /* empty */             { /* empty */ }
|   Stmts Stmt              { /* empty */ }
;

Stmt:
    DeclareStmt                 { printf("\n\n"); }
|   AssignStmt                      { /* empty */ }
|   PrintfStmt                       { /* empty */ }
|   CallStmt                { /* empty */ }
|   ReturnStmt              { /* empty */ }
;

DeclareStmt:
    K_INT ID O_SEMI         { printf("var %s", $2); }
;

AssignStmt:
    ID O_ASSIGN E O_SEMI      { printf("pop %s\n\n", $1); }
;

PrintfStmt:
    K_PRINTF O_LSBRACKER ID O_RSBRACKER O_SEMI { printf("print %s\n\n", $3); }
;

CallStmt:
    ID O_LSBRACKER O_RSBRACKER O_SEMI   {/**/}
;

ReturnStmt:
    K_RETURN ID O_SEMI                  {/**/}
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
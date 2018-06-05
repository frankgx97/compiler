%{
#include <stdio.h>
#include "stdlib.h"
#include <string>
#include <iostream>
using namespace std;
//#include "symbols.h"
#define YYSTYPE std::string
#define log if (debug == 1) printf

typedef struct node{
    char addr[255];
    char lexeme[255];
    char code[255];
}node;

extern FILE * yyin;
extern FILE * yyout;

void yyerror(const char*); 
int yylex();
string gen_expr(string,string,int);
string gen_temp_id(int);
string gen_line_id(int);
int temp = 0;
int lines = -1;
int debug = 1;
%}

%token K_INT K_ELSE K_IF K_RETURN K_VOID K_WHILE K_PRINTF K_READ
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
    /* empty */             { /* empty */ }
|    Arg                      {/**/}
;

Arg:
    ArgType Id                 {}
|   Arg O_COMMA ArgType Id     {}
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
    DeclareStmt                 { }
|   AssignStmt                      { /* empty */ }
|   PrintfStmt                       { /* empty */ }
|   ReadStmt                {}
|   CallStmt                { /* empty */ }
|   ReturnStmt              { /* empty */ }
|   IfStmt                  {}
|   WhileStmt               {}
;

IfStmt:
    K_IF O_LSBRACKER E O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER    {}
|   IfStmt K_ELSE O_LLBRACKER Stmts O_RLBRACKER                     {}
;

WhileStmt:
    K_WHILE O_LSBRACKER E O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER {}
;

DeclareStmt:
    K_INT Id O_SEMI             { cout << gen_line_id(++lines) <<": VAR " << $2 << endl; }
;

AssignStmt:
    Id O_ASSIGN E O_SEMI        { cout << gen_line_id(++lines) << ": "<< $1 << " = " << $3 << endl; }
|   Id O_ASSIGN CallStmt O_SEMI {}
;

PrintfStmt:
    K_PRINTF O_LSBRACKER Id O_RSBRACKER O_SEMI { cout << gen_line_id(++lines) << ": " << "PRINT " << $3 << endl; }
;

ReadStmt:
    K_READ O_LSBRACKER Id O_RSBRACKER O_SEMI    {}
;

CallStmt:
   ID O_LSBRACKER Args O_RSBRACKER    {/**/}
|  CallStmt O_SEMI                     {}
;

ReturnStmt:
    K_RETURN Id O_SEMI                  {/**/}
|   K_RETURN E O_SEMI                 {}
|   K_RETURN O_SEMI                 {}
;

E:
    E O_ADD E                     { $$ = gen_expr($1,$3,1); }
|   E O_SUB E                     { $$ = gen_expr($1,$3,2); }
|   E O_MUL E                     { $$ = gen_expr($1,$3,3); }
|   E O_DIV E                     { $$ = gen_expr($1,$3,4); }
|   O_SUB E %prec U_neg           {  }
|   NUM                         {  }
|   Id                          {  }
|   O_LSBRACKER E O_RSBRACKER       { cout << "(" << $2 << ")" << endl; }
;

Id:
    ID                          {}
|   ID O_LMBRACKER E O_RMBRACKER    {}
;

%%


string gen_expr(string s1,string s2, int op){
    char op_char;
    if (op == 1){
        op_char = '+';
    }else if (op == 2){
        op_char = '-';
    }else if (op == 3){
        op_char = '*';
    }else if (op == 4){
        op_char = '/';
    }
    cout << gen_line_id(++lines) << ": t" << ++temp << " = " << s1 << " " << op_char << " " << s2 <<endl;//temp代表临时变量id，此处需要自加 
    return gen_temp_id(temp);
}

string gen_temp_id(int no){
    string ret = "t";
    ret += to_string(no);
    return ret;
}

string gen_line_id(int no){
    string ret = "L";
    ret += to_string(no);
    return ret;
}

int main(int argc,char* argv[]) {
	//yyout = fopen( "out.txt", "w" );
    yyin = fopen(argv[1],"r");
	//while(yylex());
    return yyparse();
}
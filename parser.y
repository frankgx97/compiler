%{
#include <stdio.h>
#include "stdlib.h"
#include <string>
#include <iostream>
#include <vector>
#include "Node.h"

using namespace std;

#define log if (debug == 1) printf

#define ASSIGNSTMT 900
#define IFSTMT 901
#define EXPR 902

extern FILE * yyin;
extern FILE * yyout;

void yyerror(const char*); 
int yylex();
int temp = 0;
int lines = -1;
int debug = 1;

Node* head = NULL;

/*Function Declares*/

Node *  gen_expr(int type, string value , int n, ...);

void reveal(Node * node);

template<typename T>
string to_string(T a);

string gen_temp_id(int no);

string gen_line_id(int no);

/* Class defination */

/*Statement*/

%}

%token <node> K_ELSE K_IF K_RETURN K_WHILE K_PRINTF K_READ K_INT K_VOID
%token <node> ID NUM 
%token <node> O_ASSIGN O_COMMA O_SEMI
%token <node> O_LSBRACKER O_RSBRACKER O_LMBRACKER O_RMBRACKER O_LLBRACKER O_RLBRACKER
%token <node> O_ADD O_SUB O_MUL O_DIV 
%token <node> O_LESS O_L_EQUAL O_GREATER O_G_EQUAL O_EQUAL O_U_EQUAL
%token <node> COMMENT SPACES U_LEGAL

%type <node> E VAR Program
%type <node> AssignStmt IfStmt Stmts WhileStmt CallStmt ReturnStmt
%type <node> Stmt Declaration_list Declaration var_declaration fun_declaration
%type <node> type_specifier param_list param params local_declaration 
%type <node> compound_stmt

%left '+' '-'
%left '*' '/'
%right U_neg

%locations

%union{
    int type;
    char * code;
    int addr;
    Node * node;
}


%%

Program:
        Declaration_list                                { $$ = gen_expr(0,"Program", 1, $1 ); head = $$; }
;

Declaration_list:
        Declaration Declaration_list    { $$ = gen_expr( 0, "Program", 2, $1, $2 ); }
|       Declaration                     { $$ = gen_expr( 1, "Program", 1, $1 ); }
;

Declaration:
	var_declaration			{ $$ = gen_expr( 2, "Declaration", 1, $1 ); }
|	fun_declaration			{ $$ = gen_expr( 2, "Declaration", 1, $1 ); }
;

var_declaration:
	K_INT ID O_SEMI				{ $$ = gen_expr( 0, "VarDeclare", 3, $1, $2, $3 ); }
|	K_INT ID O_LMBRACKER NUM O_RMBRACKER O_SEMI	{ $$ = gen_expr( 0, "VarDeclare", 6, $1, $2, $3, $4, $5, $6 ); }
;

fun_declaration:
	type_specifier ID O_LSBRACKER params O_RSBRACKER compound_stmt 		{ $$ = gen_expr( 0, "FuncDeclare", 6, $1, $2, $3, $4, $5, $6 ); }
;

compound_stmt:
	O_LLBRACKER local_declaration Stmts O_RLBRACKER		{ $$ = gen_expr( 0, "Compounds", 4, $1, $2, $3, $4 ); }
;

type_specifier:
	K_INT		{ $$ = gen_expr( 0, "Type", 1, $1 ); }
|	K_VOID		{ $$ = gen_expr( 0, "Type", 1, $1 ); }
;

params:
	param_list	{ $$ = gen_expr( 0, "Params", 1, $1 ); }
|	/**/		{ $$ = NULL; }
;

param_list:
	param O_COMMA param_list	{ $$ = gen_expr( 0, "ParamList", 3, $1, $2, $3 ); }
|	param				{ $$ = gen_expr( 0, "ParamList", 1, $1 ); }
;

param:
	type_specifier ID				              { $$ = gen_expr( 0, "Param", 2, $1, $2 ); }
|	type_specifier ID O_LMBRACKER O_RMBRACKER 	   { $$ = gen_expr( 0, "Param", 4, $1, $2, $3, $4 ); }
;

local_declaration:
	var_declaration local_declaration	 { $$ = gen_expr( 0, "localDeclare", 2, $1, $2 ); }
|	/**/					             { $$ = NULL; }
;

Stmts:
    /* empty */             { $$ = NULL; }
|   Stmt Stmts              { $$ = gen_expr( 6, "Stmts", 2, $1, $2 ); }
;

Stmt:
    AssignStmt                  { $$ = gen_expr( 9, "Stmt", 1, $1 ); }
|   CallStmt                    { $$ = gen_expr( 12, "Stmt", 1, $1 ); }
|   compound_stmt               { $$ = gen_expr( 12, "Stmt", 1, $1 ); }
|   ReturnStmt                  { $$ = gen_expr( 13, "Stmt", 1, $1 ); }
|   IfStmt                      { $$ = gen_expr( 14, "Stmt", 1, $1 ); }
|   WhileStmt                   { $$ = gen_expr( 15, "Stmt", 1, $1 ); }
;

IfStmt:
    K_IF O_LSBRACKER E O_RSBRACKER Stmt   			    { $$ = gen_expr( 16, "If", 5, $1, $2, $3, $4, $5 ); }
|   K_IF O_LSBRACKER E O_RSBRACKER Stmt K_ELSE Stmt		{ $$ = gen_expr( 18, "If", 7, $1, $2, $3, $4, $5, $6, $7 ); }
;

WhileStmt:
    K_WHILE O_LSBRACKER E O_RSBRACKER Stmts     { $$ = gen_expr( 18, "While", 5, $1, $2, $3, $4, $5 ); }
;

AssignStmt:
    VAR O_ASSIGN E O_SEMI        { $$ = gen_expr( 20, "Assign", 4, $1, $2, $3, $4 ); }
|   VAR O_ASSIGN CallStmt O_SEMI { $$ = gen_expr( 21, "Assign", 4, $1, $2, $3, $4 );}
;

CallStmt:
   ID O_LSBRACKER params O_RSBRACKER O_SEMI CallStmt      { $$ = gen_expr( 24, "Call", 6, $1, $2, $3, $4, $5, $6 ); }
|  /**/                      { $$ = NULL; }
;

ReturnStmt:
        K_RETURN E O_SEMI		{ $$ = gen_expr( 0, "Return", 3, $1, $2, $3 ); }
|       K_RETURN O_SEMI         { $$ = gen_expr( 28, "Return", 2, $1, $2 ); }
;

E:
    E O_ADD E                     { $$ = gen_expr( 29, "E", 3, $1, $2, $3 ); }
|   E O_SUB E                     { $$ = gen_expr( 30, "E", 3, $1, $2, $3 ); }
|   E O_MUL E                     { $$ = gen_expr( 31, "E", 3, $1, $2, $3 ); }
|   E O_DIV E                     { $$ = gen_expr( 32, "E", 3, $1, $2, $3 ); }
|   O_SUB E %prec U_neg           {  }
|   NUM                           { $$ = gen_expr( 2, "E", 1, $1 ); }
|   VAR                            { $$ = gen_expr( 2, "E", 1, $1 ); }
|   O_LSBRACKER E O_RSBRACKER     { $$ = gen_expr( 33, "E", 3, $1, $2, $3 ); }
;

VAR:
    ID                              { $$ = gen_expr( 2, "Id", 1, $1 );}
|   ID O_LMBRACKER E O_RMBRACKER    { $$ = gen_expr( 29, "Id", 4, $1, $2, $3, $4 );}
;

%%

Node *  gen_expr(int type, string value , int n, ...){
    va_list pvar;   
    va_start (pvar, n);
    Node * new_node = new Var(value);
    Node * temp = new_node;
    for (int i=0;i<n;i++){
        Node * f = va_arg (pvar, Node *);
        if (f != NULL){
            if(temp == new_node)
                temp->lchild = f;
            else 
                temp->rchild = f;
            
            temp = f;
        }
    }
    va_end (pvar);  
    return new_node;
}

void reveal(Node * node){
    static int depth = 0;
    if(!node)return;
    depth++;
    
    for(int i = 0; i < depth-1;i++)cout << '\t';
    cout << node->toString()<< endl;

    reveal(node->lchild);
    depth--;
    reveal(node->rchild);
    
}

template<typename T>
string to_string(T a){
    return "";
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
    yyparse();
    reveal(head);
}

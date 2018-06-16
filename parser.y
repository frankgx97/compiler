%{
#include <stdio.h>
#include "stdlib.h"
#include <string>
#include <iostream>
#include <vector>
#include "Node.h"
//#include "utils.h"
using namespace std;
//#include "symbols.h"
//#define YYSTYPE Node* //std::string
#define log if (debug == 1) printf

//cd Desktop/编译原理/CMinus && make


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

//template<typename T>
//string to_string(T a);

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

%type <node> E Id FunctionName ReturnType FunctionDeclare Program Args ArgType Arg
%type <node> AssignStmt IfStmt Stmts WhileStmt DeclareStmt PrintfStmt ReadStmt CallStmt ReturnStmt
%type <node> Stmt

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
        /**/                                {/**/}
|       Program FunctionDeclare             { $$ = gen_expr( 0, "Program", 2, $1, $2 ); head = $$; }
|       FunctionDeclare                     { $$ = gen_expr( 1, "Program", 1, $1 ); head = $$; }
;

FunctionDeclare:
    ReturnType FunctionName O_LSBRACKER Args O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER { 
            $$ = gen_expr( 2, "funcDeclare", 8, $1, $2, $3, $4, $5, $6, $7, $8 ); 
    }
;

ReturnType:
    K_INT                       { $$ = gen_expr( 2, "Return", 1, $1 ); }
|   K_VOID                      { $$ = gen_expr( 2, "Return", 1, $1 ); }
;

FunctionName:
    ID                          { $$ = gen_expr( 2, "FuncName", 1, $1 ); }
;

Args:
    /* empty */               { $$ = NULL;}
|    Arg                      { $$ = gen_expr( 3, "Args", 1, $1 ); }
;

Arg:
    ArgType Id                 { $$ = gen_expr( 4, "Arg", 2, $1, $2 ); }
|   Arg O_COMMA ArgType Id     { $$ = gen_expr( 5, "Arg", 4, $1, $2, $3, $4 ); }
;

ArgType:
    K_INT                   { $$ = gen_expr( 2, "ArgType", 1, $1 ); }
;


Stmts:
    /* empty */             { /* empty */ }
|   Stmts Stmt              { $$ = gen_expr( 6, "Stmts", 2, $1, $2 ); }
|   Stmt                    { $$ = gen_expr( 7, "Stmts", 1, $1 ); }
;

Stmt:
    DeclareStmt             { $$ = gen_expr( 8, "Stmt", 1, $1 ); }
|   AssignStmt              { $$ = gen_expr( 9, "Stmt", 1, $1 ); }
|   PrintfStmt              { $$ = gen_expr( 10, "Stmt", 1, $1 ); }
|   ReadStmt                { $$ = gen_expr( 11, "Stmt", 1, $1 ); }
|   CallStmt                { $$ = gen_expr( 12, "Stmt", 1, $1 ); }
|   ReturnStmt              { $$ = gen_expr( 13, "Stmt", 1, $1 ); }
|   IfStmt                  { $$ = gen_expr( 14, "Stmt", 1, $1 ); }
|   WhileStmt               { $$ = gen_expr( 15, "Stmt", 1, $1 ); }
;

IfStmt:
    K_IF O_LSBRACKER E O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER    {   
        $$ = gen_expr( 16, "If", 7, $1, $2, $3, $4, $5, $6, $7 );
    }
|   IfStmt K_ELSE O_LLBRACKER Stmts O_RLBRACKER                     {
        $$ = gen_expr( 17, "If", 5, $1, $2, $3, $4, $5 );
    }
;

WhileStmt:
    K_WHILE O_LSBRACKER E O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER {
        $$ = gen_expr( 18, "While", 7, $1, $2, $3, $4, $5, $6, $7 );
    }
;

DeclareStmt:
    K_INT Id O_SEMI             { $$ = gen_expr( 19, "Declare", 3, $1, $2, $3 ); }
;

AssignStmt:
    Id O_ASSIGN E O_SEMI        { $$ = gen_expr( 20, "Assign", 4, $1, $2, $3, $4 ); }
|   Id O_ASSIGN CallStmt O_SEMI { $$ = gen_expr( 21, "Assign", 4, $1, $2, $3, $4 );}
;

PrintfStmt:
    K_PRINTF O_LSBRACKER Id O_RSBRACKER O_SEMI  { $$ = gen_expr( 22, "Printf", 5, $1, $2, $3, $4, $5 ); }
;

ReadStmt:
    K_READ O_LSBRACKER Id O_RSBRACKER O_SEMI    { $4 = gen_expr( 23, "Read", 5, $1, $2, $3, $4, $5 ); }
;

CallStmt:
   ID O_LSBRACKER Args O_RSBRACKER      { $$ = gen_expr( 24, "Call", 4, $1, $2, $3, $4 ); }
|  CallStmt O_SEMI                      { $$ = gen_expr( 25, "Call", 2, $1, $2 ); }
;

ReturnStmt:
    K_RETURN Id O_SEMI                  { $$ = gen_expr( 26, "Return", 3, $1, $2, $3 ); }
|   K_RETURN E O_SEMI                   { $$ = gen_expr( 27, "Return", 3, $1, $2, $3 ); }
|   K_RETURN O_SEMI                     { $$ = gen_expr( 28, "Return", 2, $1, $2 ); }
;

E:
    E O_ADD E                     { $$ = gen_expr( 29, "E", 3, $1, $2, $3 ); }
|   E O_SUB E                     { $$ = gen_expr( 30, "E", 3, $1, $2, $3 ); }
|   E O_MUL E                     { $$ = gen_expr( 31, "E", 3, $1, $2, $3 ); }
|   E O_DIV E                     { $$ = gen_expr( 32, "E", 3, $1, $2, $3 ); }
|   O_SUB E %prec U_neg           {  }
|   NUM                           { $$ = gen_expr( 2, "E", 1, $1 ); }
|   Id                            { $$ = gen_expr( 2, "E", 1, $1 ); }
|   O_LSBRACKER E O_RSBRACKER     { $$ = gen_expr( 33, "E", 3, $1, $2, $3 ); }
;

Id:
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

//template<typename T>
//string to_string(T a){
//    return "";
//}

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
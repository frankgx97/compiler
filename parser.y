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

string newTemp();

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

%type <node> program declaration_list declaration var_declaration type_specifier fun_declaration 
%type <node> params param_list param compound_stmt local_declaration statement_list statement 
%type <node> expression_stmt selection_stmt iteration_stmt return_stmt expression var simple_expression 
%type <node> relop additive_expression addop term mulop factor call args arg_list matched_if unmatched_if

%left '+' '-'
%left '*' '/'
%right U_neg

%locations

%define parse.error verbose

%union{
    int type;
    char * code;
    int addr;
    Node * node;
}


%%

program:
        declaration_list    { 
            $$ = gen_expr(0,"Program", 1, $1 ); 
            head = $$;
        }
;

declaration_list:
        declaration declaration_list    { $$ = gen_expr( 0, "declaration_list", 2, $1, $2 ); }
|       declaration                     { $$ = gen_expr( 1, "declaretion_list", 1, $1 ); }
;

declaration:
	var_declaration			{ $$ = gen_expr( 2, "declaration", 1, $1 ); }
|	fun_declaration			{ $$ = gen_expr( 2, "declaration", 1, $1 ); }
;

var_declaration:
	type_specifier ID O_SEMI				               { $$ = gen_expr( 0, "var_declaration", 3, $1, $2, $3 ); }
|	type_specifier ID O_LMBRACKER NUM O_RMBRACKER O_SEMI	{ $$ = gen_expr( 0, "var_declaration", 6, $1, $2, $3, $4, $5, $6 ); }
;

fun_declaration:
	type_specifier ID O_LSBRACKER params O_RSBRACKER compound_stmt 		
        { $$ = gen_expr( 0, "fun_declare", 6, $1, $2, $3, $4, $5, $6 ); }
;

compound_stmt:
	O_LLBRACKER local_declaration statement_list O_RLBRACKER		
        { $$ = gen_expr( 0, "compound_stmt", 4, $1, $2, $3, $4 ); }
;

type_specifier:
	K_INT		{ $$ = gen_expr( 2, "type", 1, $1 ); }
|	K_VOID		{ $$ = gen_expr( 2, "type", 1, $1 ); }
;

params:
	param_list	{ $$ = gen_expr( 0, "params", 1, $1 ); }
|	/**/		{ $$ = NULL; }
;

param_list:
	param O_COMMA param_list       { $$ = gen_expr( 0, "param_list", 3, $1, $2, $3 ); }
|	param	                        { $$ = gen_expr( 0, "param_list", 1, $1 ); }
;

param:
	type_specifier ID                              { $$ = gen_expr( 0, "param", 2, $1, $2 ); }
|	type_specifier ID O_LMBRACKER O_RMBRACKER     { $$ = gen_expr( 0, "param", 4, $1, $2, $3, $4 ); }
;

local_declaration:
	var_declaration local_declaration	 { $$ = gen_expr( 0, "local_declaration", 2, $1, $2 ); }
|	/**/					             { $$ = NULL; }
;

statement_list:
    /* empty */                 { $$ = NULL; }
|   statement statement_list    { $$ = gen_expr( 6, "statement_list", 2, $1, $2 ); }
;

statement:
    expression_stmt                 { $$ = gen_expr( 9, "statement", 1, $1 ); }
|   compound_stmt                   { $$ = gen_expr( 12, "statement", 1, $1 ); }
|   selection_stmt                  { $$ = gen_expr( 12, "statement", 1, $1 ); }
|   iteration_stmt                  { $$ = gen_expr( 13, "statement", 1, $1 ); }
|   return_stmt                     { $$ = gen_expr( 14, "statement", 1, $1 ); }
;

expression_stmt:
    expression O_SEMI       { $$ = gen_expr( 0, "expression_stmt", 2, $1, $2 ); }
|   O_SEMI                  { $$ = gen_expr( 0, "expression_stmt", 1, $1 ); }

selection_stmt:
    matched_if      { $$ = gen_expr( 0, "expression_stmt", 1, $1 ); }
|   unmatched_if    { $$ = gen_expr( 0, "expression_stmt", 1, $1 ); }

matched_if:
    K_IF O_LSBRACKER expression O_RSBRACKER statement K_ELSE statement { 
        $$ = gen_expr( 18, "matched_if", 7, $1, $2, $3, $4, $5, $6, $7 ); 
 //       $$->addCode( $3  );
//        $$->addCode( Code( "", iftrue, $3->place, "", $5->lable ) );
//        $$->addCode( Code( "", jump,   "",        "", $7->lable ) )
//        $1->false = $7
    }

unmatched_if:
    K_IF O_LSBRACKER expression O_RSBRACKER statement   			    
        { $$ = gen_expr( 16, "unmatched_if", 5, $1, $2, $3, $4, $5 ); }
|   K_IF O_LSBRACKER expression O_RSBRACKER matched_if K_ELSE unmatched_if		
        { $$ = gen_expr( 18, "unmatched_if", 7, $1, $2, $3, $4, $5, $6, $7 ); }
;

iteration_stmt:
    K_WHILE O_LSBRACKER expression O_RSBRACKER statement     
        { $$ = gen_expr( 18, "While", 5, $1, $2, $3, $4, $5 ); }
;
expression:
    var O_ASSIGN expression         { $$ = gen_expr( 0, "expression", 3, $1, $2, $3 ); }
|   simple_expression               { $$ = gen_expr( 0, "expression", 1, $1 ); }
;
return_stmt:
        K_RETURN expression O_SEMI		{ $$ = gen_expr( 0, "Return", 3, $1, $2, $3 ); }
|       K_RETURN O_SEMI                 { $$ = gen_expr( 28, "Return", 2, $1, $2 ); }
;
var:
    ID                                       { $$ = gen_expr( 2, "Id", 1, $1 );}
|   ID O_LMBRACKER expression O_RMBRACKER    { $$ = gen_expr( 29, "Id", 4, $1, $2, $3, $4 );}
;
simple_expression:
    additive_expression relop additive_expression { $$ = gen_expr( 0, "Return", 3, $1, $2, $3 ); }
|   additive_expression                             { $$ = gen_expr( 2, "Id", 1, $1 ); }
;
relop:
    O_L_EQUAL   { $$ = gen_expr( 2, "relop", 1, $1 ); }
|   O_LESS      { $$ = gen_expr( 2, "relop", 1, $1 ); }
|   O_GREATER   { $$ = gen_expr( 2, "relop", 1, $1 ); }
|   O_G_EQUAL   { $$ = gen_expr( 2, "relop", 1, $1 ); }
|   O_EQUAL     { $$ = gen_expr( 2, "relop", 1, $1 ); }
|   O_U_EQUAL   { $$ = gen_expr( 2, "relop", 1, $1 ); }
;
additive_expression:
    term addop additive_expression  { $$ = gen_expr( 28, "additive_expression", 2, $1, $2 ); }
|   term                            { $$ = gen_expr( 2, "additive_expression", 1, $1 );}
;
addop:
    O_ADD   { $$ = gen_expr( 2, "addop", 1, $1 ); }
|   O_SUB   { $$ = gen_expr( 2, "addop", 1, $1 ); }
;
term:
    factor mulop term   { 
        $$ = gen_expr( 0, "term", 3, $1, $2, $3 );
//        $$->place = newTemp();
//        $$->addCode( $1 );
//        $$->addCode( $3 );
//        $$->addCode( Lable("",""), )
    }
|   factor              { $$ = gen_expr( 2, "term", 1, $1 );}
;
mulop:  
    O_MUL   { $$ = gen_expr( 2, "mulop", 1, $1 ); }
|   O_DIV   { $$ = gen_expr( 2, "mulop", 1, $1 ); }
;
factor:
    O_LSBRACKER expression O_RSBRACKER  { $$ = gen_expr( 0, "factor", 3, $1, $2, $3 ); }
|   var                                 { $$ = gen_expr( 2, "factor", 1, $1 ); }
|   call                                { $$ = gen_expr( 2, "factor", 1, $1 ); }
|   NUM                                 { $$ = gen_expr( 2, "factor", 1, $1 ); }
;
call:
    ID O_LSBRACKER args O_RSBRACKER     { $$ = gen_expr( 29, "call", 4, $1, $2, $3, $4 );}
;
args:
    arg_list    { $$ = gen_expr( 2, "args", 1, $1 ); }
|   /**/        { $$ = NULL; }
;
arg_list:
    expression O_COMMA arg_list { $$ = gen_expr( 0, "arg_list", 3, $1, $2, $3 ); }
|   expression                  { $$ = gen_expr( 2, "arg_list", 1, $1 ); }
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

            for( int i = 0; i < f->codes.size(); i++ )
                new_node->codes.push_back(f->codes[i]);
            
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
    
    for(int i = 0; i < depth-1;i++)cout << "|  ";
    cout << node->toString()<< endl;

    reveal(node->lchild);
    depth--;
    reveal(node->rchild);
    
}

/*string to_string(int a){
    string ret = "";
//    while(a){
//        int t = a%10;
//        a/=10;
//        ret = string( '0' + t ) + ret; 
//    }
    return ret;
}*/

string genTemp(){
    static int no = 0; 
    string ret = "t";
    ret += to_string(no++);
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

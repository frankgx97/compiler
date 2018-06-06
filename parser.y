%{
#include <stdio.h>
#include "stdlib.h"
#include <string>
#include <iostream>
#include <vector>
//#include "utils.h"
using namespace std;
//#include "symbols.h"
//#define YYSTYPE Node* //std::string
#define log if (debug == 1) printf


#define ASSIGNSTMT 900
#define IFSTMT 901

extern FILE * yyin;
extern FILE * yyout;

void yyerror(const char*); 
int yylex();
int temp = 0;
int lines = -1;
int debug = 1;

/*Function Declares*/
string gen_expr(string,string,int);
string gen_temp_id(int);
string gen_line_id(int);


char * gen_expr(char * , char * ,int);

/* Class defination */

class Node{
    public:
    //vector<Node*> childs;
};

/*Statement*/

class CStmt:public Node{
public:
    int type;
    string id;
    string expr;
};

/*AssignStatement*/

class CAssignStmt:public CStmt{
public:
    string id;
    string expr;
    CAssignStmt(string,string);
};
CAssignStmt::CAssignStmt(string id,string expr){
    this->type = ASSIGNSTMT;
    this->id = id;
    this->expr =  expr;
};

/*Statements*/

class CStmts:public Node{
public:
    vector<CStmt*> childs;
    int add(CStmt*);
    CStmts();

};
int CStmts::add(CStmt * stmt){
    this->childs.push_back(stmt);
    return 0;
}
CStmts::CStmts(){

}

/*IfStmt*/

class CIfStmt:public CStmt{
public:
    string expr;
    CStmts * true_stmts;
    CStmts * false_stmts;
    CIfStmt();
};
CIfStmt::CIfStmt(){
    this->type = IFSTMT;
}

class CFunctionDecl:public Node{
public:
    string ret_type;
    string name;
    CStmts * stmts;
    CFunctionDecl(char*,char*,CStmts *);
};
CFunctionDecl::CFunctionDecl(char * ret_type,char * name, CStmts * stmts){
    this->ret_type = ret_type;
    this->name = name;
    this->stmts = stmts;
}

class CProgram:public Node{
public:
    vector<CFunctionDecl*> childs;
    int add(CFunctionDecl *);
    CProgram();
};
CProgram::CProgram(){

}
int CProgram::add(CFunctionDecl * cFunctionDecl){
    this->childs.push_back(cFunctionDecl);
    return 0;
}


void reveal(CProgram*);

%}

%token K_ELSE K_IF K_RETURN K_WHILE K_PRINTF K_READ
%token <code> ID NUM K_INT K_VOID
%token O_ASSIGN O_COMMA O_SEMI O_LSBRACKER O_RSBRACKER O_LMBRACKER O_RMBRACKER O_LLBRACKER O_RLBRACKER
%token O_ADD O_SUB O_MUL O_DIV O_LESS O_L_EQUAL O_GREATER O_G_EQUAL O_EQUAL O_U_EQUAL
%token COMMENT SPACES U_LEGAL

%type <code> E Id FunctionName ReturnType
%type <c_assign> AssignStmt
%type <c_if> IfStmt
%type <c_stmt> Stmt
%type <c_stmts> Stmts
%type <c_function> FunctionDeclare
%type <c_program> Program

%left '+' '-'
%left '*' '/'
%right U_neg

%define parse.error verbose 
%locations

%union{
    int type;
    //string *code;
    char * code;
    int addr;
    //Node * node;
    CAssignStmt * c_assign;
    CIfStmt * c_if;
    CStmt * c_stmt;
    CStmts * c_stmts;
    CFunctionDecl * c_function;
    CProgram * c_program;
}


%%

Program:
        /**/                                {/**/}
|       Program FunctionDeclare             {/**/}
|       FunctionDeclare                     {   CProgram * cProgram = new CProgram();
                                                cProgram->add($1);
                                                reveal(cProgram);
                                                $$ = cProgram;
                                            }
;

FunctionDeclare:
    ReturnType FunctionName O_LSBRACKER Args O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER { char * ty = "int";$$ = new CFunctionDecl(ty,$2,$7); }
;

ReturnType:
    K_INT                       { /*cout << $1<<endl;$$ = $1;*/ }
|   K_VOID                      { /*$$ = $1;*/ }
;

FunctionName:
    ID                          { $$ = $1; }
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


Stmts:
    /* empty */             { /* empty */ }
|   Stmts Stmt              { $1->add($2);$$ = $1;}
|   Stmt                    {   CStmts * cStmts = new CStmts();
                                cStmts->add($1);
                                $$ = cStmts;
                            }
;

Stmt:
    DeclareStmt                 { }
|   AssignStmt                      { $$ = $1; }
|   PrintfStmt                       { /* empty */ }
|   ReadStmt                {}
|   CallStmt                { /* empty */ }
|   ReturnStmt              { /* empty */ }
|   IfStmt                  {cout << "@@@if"+$1->expr<<endl;$$ = $1;}
|   WhileStmt               {}
;

IfStmt:
    K_IF O_LSBRACKER E O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER    {   CIfStmt * cIfStmt = new CIfStmt();
                                                                        cIfStmt->expr = $3;
                                                                        cIfStmt->true_stmts = $6;
                                                                        cout << "!!if "+cIfStmt->expr<<endl; 
                                                                        $$ = cIfStmt;
                                                                    }
|   IfStmt K_ELSE O_LLBRACKER Stmts O_RLBRACKER                     {}
;

WhileStmt:
    K_WHILE O_LSBRACKER E O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER {}
;

DeclareStmt:
    K_INT Id O_SEMI             { /*cout << gen_line_id(++lines) <<": VAR " << $2 << endl; */}
;

AssignStmt:
    Id O_ASSIGN E O_SEMI        {   string s1=$1;string s2=$3;
                                    $$ = new CAssignStmt(s1,s2);
                                    cout << gen_line_id(++lines) << ": "<< $1 << " = " << $3 << endl;
                                }
|   Id O_ASSIGN CallStmt O_SEMI {}
;

PrintfStmt:
    K_PRINTF O_LSBRACKER Id O_RSBRACKER O_SEMI { /*cout << gen_line_id(++lines) << ": " << "PRINT " << $3 << endl; */}
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
|   K_RETURN E O_SEMI                   {}
|   K_RETURN O_SEMI                     {}
;

E:
    E O_ADD E                     { printf("%s\n",$1);$$ = gen_expr($1,$3,1); }
|   E O_SUB E                     { printf("%s\n",$1);$$ = gen_expr($1,$3,2); }
|   E O_MUL E                     { printf("%s\n",$1);$$ = gen_expr($1,$3,3); }
|   E O_DIV E                     { printf("%s\n",$1);$$ = gen_expr($1,$3,4); }
|   O_SUB E %prec U_neg           {  }
|   NUM                           { $$ = $1; }
|   Id                            { }
|   O_LSBRACKER E O_RSBRACKER       { /*cout << "(" << $2 << ")" << endl;*/ }
;

Id:
    ID                              {$$ = $1;}
|   ID O_LMBRACKER E O_RMBRACKER    {}
;

%%

char * gen_expr(char * s1,char * s2,int op){
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
    string ss1 = s1;
    string ss2 = s2;
    string ret = ss1 + op_char + ss2;
    char *cret = new char[ret.length() + 1];
    strcpy(cret, ret.c_str());
    return cret;
}

/*
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
    string code = gen_line_id(++lines) + ": t" + to_string(++temp) + " = " + s1 + " " + op_char + " " + s2 + "\n";//temp代表临时变量id，此处需要自加 

    return gen_temp_id(temp);
}
*/

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

void reveal(CProgram * prog){
    /*试图打印出语法树*/
    cout << "------start-------" <<endl;
    CFunctionDecl* func = prog->childs[0];
    cout << func->ret_type << func->name <<endl;
    for(int i=0;i<func->stmts->childs.size();i++){
        if(func->stmts->childs[i]->type == ASSIGNSTMT){
            //cout << func->stmts->childs[i]->id << endl; 
            cout << "assign" << endl;
        }else if(func->stmts->childs[i]->type == IFSTMT){
            cout << "##if" + func->stmts->childs[i]->expr  << endl; 
            cout << "ifstmt" << endl;
        }
    }
}

int main(int argc,char* argv[]) {
	//yyout = fopen( "out.txt", "w" );
    yyin = fopen(argv[1],"r");
	//while(yylex());
    return yyparse();
}
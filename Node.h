#ifndef Node_h
#define Node_h
//something
#include <iostream>
#include <string>
#include "stdarg.h"

#include <stdio.h>
#include <stdlib.h>
#include <vector>

using namespace std;

enum action{
    Add,
    Sub,
    Mul,
    Div,
    Greater,
    Less,
    Equal,
    Unequal,
    Iftrue,
    Jump
};

struct Lable{
    string curr;
    string equalTo;
    Lable( string c, string eq ):curr(c), equalTo(eq){}
};

struct Code{
    Lable lable;
    action act;
    string addr1, addr2;
    Code( Lable l, action a, string a1, string a2 ):lable(l.curr,l.equalTo), act(a), addr1(a1), addr2(a2) {}
};



class Node{
public:
    int type;
    string value;
    Node *lchild, *rchild;

    vector<Code> codes;
    string place;
    
    Node* next;
    Node* T;
    Node* F;

    int addrAdditive;
    int result;

    Node():lchild(NULL),rchild(NULL){}

    virtual bool isTerminal(){return false;};
    virtual string toString(){return "";};
    void addCode( Node* node ){
        for(int i = 0; i < node->codes.size(); i++ )
            codes.push_back(node->codes[i]);
    }
    void addCode( Code code  ){
        codes.push_back( code );
    }
};

class Terminal: public Node{
public:
    Terminal(int t,string val){
        value = val;
        type = t;
    }
    string toString(){ return value; }
    bool isTerminal(){ return true; }
};

class Var:public Node{
public:
    
    string expr;
    Var(string e){
        expr = e;
    }
    string toString(){ return expr; }
    bool isTerminal(){ return false; }
};

//%define parse.error verbose 

#endif

/*


*/

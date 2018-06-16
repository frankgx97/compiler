#ifndef Node_h
#define Node_h

#include <iostream>
#include <string>
#include "stdarg.h"

#include <stdio.h>
#include <stdlib.h>
#include <vector>

using namespace std;

class Node{
public:
    int type;
    string value;
    Node *lchild, *rchild;

    Node():lchild(NULL),rchild(NULL){}

    virtual bool isTerminal(){return false;};
    virtual string toString(){return "";};
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

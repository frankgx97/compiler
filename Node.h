#include <iostream>
#include <string>
using namespace std;

class Node{
    public:
    int get_type();//虚函数，返回id属性
    string get_value();//虚函数，返回expr属性
    Node * lchild;
    Node * rchild;
    int type;
    string value;
    Node(int type, string value, Node * lchild, Node * rchild);
    Node(int type, string value){
        this->type = type;
        this->value = value;
        lchild = NULL;
        rchild = NULL;
    }
};

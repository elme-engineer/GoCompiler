#ifndef _AST_H
#define _AST_H

// WORK DONE BY:
// Pedro Bento 2021219351
// Ines Mendes 2017263654

// the order of the enum and the #define must precisely match
enum category {  Program,   VarDecl,   FuncDecl,   FuncHeader,   FuncParams, ParamDecl, ParseArgs, FuncBody, Integer,   Identifier,
                Natural,   Decimal,   StrLit, Call,   Var,  Int,  Float32, Bool, String, If,  Else, For, Plus, Minus, Add,   Sub,   Mul,   Div , Mod , Or, And, Lt, Gt, Eq, Ne, Le, Ge, Not, Blankid, Package, Print, Parseint, Func, Cmdargs, Return, Lbrace, Lsq, Lpar, Rbrace, Rpar, Rsq, Assign, Comma, Semicolon, Reserved, AuxNode, Block};
#define names { "Program", "VarDecl", "FuncDecl", "FuncHeader", "FuncParams", "ParamDecl","ParseArgs", "FuncBody","Integer", "Identifier", "Natural", "Decimal", "StrLit","Call", "Var", "Int", "Float32", "Bool", "String", "If", "Else", "For", "Plus", "Minus", "Add", "Sub", "Mul", "Div", "Mod", "Or", "And", "Lt", "Gt", "Eq", "Ne", "Le", "Ge", "Not", "Blankid", "Package", "Print", "Parseint", "Func", "Cmdargs", "Return", "Lbrace", "Lsq", "Lpar", "Rbrace", "Rpar", "Rsq", "Assign", "Comma", "Semicolon", "Reserved", "AuxNode", "Block"}

enum type {integer_type, double_type, no_type};
#define type_name(type) (type == integer_type ? "integer" : (type == double_type ? "double" : "none"))
#define category_type(category) (category == Integer ? integer_type : (category == Double ? double_type : no_type))

struct node {
    enum category category;
    char *token;
    int token_line, token_column;
    enum type type;
    struct node_list *children;
};

struct node_list {
    struct node *node;
    struct node_list *next;
};

struct node *newnode(enum category category, char *token);
void addchild(struct node *parent, struct node *child);
void adoptChildren(struct node *newFather, struct node *sourceNode);
struct node *getchild(struct node *parent, int position);
int countchildren(struct node *node);
void show(struct node *root, int depth);
void deallocate(struct node *root);

#endif
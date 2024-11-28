#ifndef _AST_H
#define _AST_H

// the order of the enum and the #define must precisely match
enum category {  Program,   Function,   Parameters,   Parameter,   Arguments,   Integer,   Identifier,
                Natural,   Decimal,   Strlit, Call,   Var,  Int,  Float32, Bool, String, If,  Else, For, Plus,   Minus,   Star,   Div , Mod , Or, And, Lt, Gt, Eq, Ne, Le, Ge, Not, Blankid, Package, Print, Parseint, Func, Cmdargs, Return, Lbrace, Lsq, Lpar, Rbrace, Rpar, Rsq, Assign, Comma, Semicolon, Reserved};
#define names { "Program", "Function", "Parameters", "Parameter", "Arguments", "Integer", "Identifier", "Natural", "Decimal", "Strlit","Call", "Var", "Int", "Float32", "Bool", "String", "If", "Else", "For", "Plus", "Minus", "Star", "Div", "Mod", "Not", "Or", "And", "Lt", "Gt", "Eq", "Ne", "Le", "Ge", "Not", "Blankid", "Package", "Print", "Parseint", "Func", "Cmdargs", "Return", "Lbrace", "Lsq", "Lpar", "Rbrace", "Rpar", "Rsq", "Assign", "Comma", "Semicolon", "Reserved"}

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
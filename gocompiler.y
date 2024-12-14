%{

// WORK DONE BY:
// Pedro Bento 2021219351
// Ines Mendes 2017263654

#include <stdio.h>
#include "y.tab.h"
#include "goast.h"

int yylex(void);
void yyerror(char *);
int yyparse(void);

struct node *program;
struct node *fHeader;
struct node *fParam;
struct node *blockNode;
struct node *blockNodeElse;
struct node *varDecl;
struct node_list *idList;
struct node *parDec;

%}

%union{
    char *lexeme;
    struct node *node;
}


%token PLUS MINUS STAR DIV MOD EQ GE GT LE LT NE NOT AND OR RETURN PRINT PARSEINT INT FLOAT32 BOOL STRING ASSIGN
%token PACKAGE IF ELSE FOR LPAR RPAR LBRACE RBRACE LSQ RSQ SEMICOLON COMMA BLANKID VAR CMDARGS FUNC RESERVED 
%token <lexeme> STRLIT IDENTIFIER NATURAL DECIMAL
%type<node> Program Declarations FuncDeclaration VarSpec Type FuncBody Parameters VarsAndStatements StateSemi
%type<node> VarDeclaration Statement Expr FuncInvocation ParseArgs FuncInvocationOpts VarSpecOpts ParamOpts

%right ASSIGN
%left OR
%left AND
%left EQ NE GE GT LE LT
%left PLUS MINUS
%left STAR DIV MOD
%right NOT UNARY
%nonassoc LPAR RPAR

%%

Program:    PACKAGE IDENTIFIER SEMICOLON Declarations               { $$ = program = newnode(Program, NULL);
                                                                        if($4 != NULL)
                                                                            adoptChildren($$, $4);}
;

Declarations: Declarations VarDeclaration SEMICOLON     {   if($1 == NULL){
                                                                $$ = newnode(AuxNode, NULL);
                                                                adoptChildren($$, $2);                                                                
                                                                }else{
                                                                    $$ = $1;
                                                                    adoptChildren($$, $2);
                                                                    };}           
    |   Declarations FuncDeclaration SEMICOLON          {if($1 == NULL){
                                                                $$ = newnode(AuxNode, NULL);
                                                                addchild($$, $2);                                                                
                                                                }else{
                                                                    $$ = $1;
                                                                    addchild($$, $2);
                                                                    };}
    |                                                      {$$ = NULL;}     
;

VarDeclaration:    VAR VarSpec                           {$$ = $2;}   
    |   VAR LPAR VarSpec SEMICOLON RPAR                  {$$ = $3;}
;

VarSpec:    IDENTIFIER VarSpecOpts Type        {    $$ = newnode(AuxNode, NULL);
                                                    varDecl = newnode(VarDecl, NULL);
                                                    addchild(varDecl, $3);
                                                    addchild(varDecl, newnode(Identifier, $1));
                                                    
                                                    addchild($$, varDecl);
                                                    idList = $2->children; 
                                                    while(idList->next != NULL){

                                                        varDecl = newnode(VarDecl, NULL);
                                                        addchild(varDecl, $3);
                                                        addchild(varDecl, idList->next->node);
                                                        addchild($$, varDecl);
                                                        
                                                        idList = idList->next;
                                                    }
                                                    }
;

VarSpecOpts:    VarSpecOpts COMMA IDENTIFIER            {  $$ = $1;
                                                            addchild($$, newnode(Identifier, $3));
                                                            }
                |                               {$$ = newnode(AuxNode, NULL);}
;

Type: INT                                 {$$ = newnode(Int, NULL);}            
    |   FLOAT32                           {$$ = newnode(Float32, NULL);}            
    |   BOOL                              {$$ = newnode(Bool, NULL);}             
    |   STRING                            {$$ = newnode(String, NULL);}              
;

FuncDeclaration:    FUNC IDENTIFIER LPAR RPAR FuncBody                      {$$ = newnode(FuncDecl, NULL);
                                                                                fHeader = newnode(FuncHeader, NULL);
                                                                                addchild($$, fHeader);
                                                                                addchild(fHeader, newnode(Identifier,$2));                                                                            
                                                                                fParam = newnode(FuncParams, NULL);
                                                                                addchild(fHeader, fParam);
                                                                                
                                                                                addchild($$, $5);
                                                                                }
                    | FUNC IDENTIFIER LPAR Parameters RPAR FuncBody         {$$ = newnode(FuncDecl, NULL);
                                                                                fHeader = newnode(FuncHeader, NULL);                                                                                
                                                                                addchild(fHeader, newnode(Identifier,$2));
                                                                                
                                                                                fParam = newnode(FuncParams, NULL);
                                                                                adoptChildren(fParam, $4);
                                                                                addchild(fHeader, fParam);
                                                                                addchild($$, fHeader);
                                                                                addchild($$, $6);}                    
                    | FUNC IDENTIFIER LPAR RPAR Type FuncBody               {$$ = newnode(FuncDecl, NULL);
                                                                                fHeader = newnode(FuncHeader, NULL);                                                                                
                                                                                addchild(fHeader, newnode(Identifier,$2));
                                                                                addchild(fHeader, $5);
                                                                                

                                                                                fParam = newnode(FuncParams, NULL);
                                                                                addchild(fHeader, fParam);
                                                                                addchild($$, fHeader);
                                                                                addchild($$, $6);}
                    | FUNC IDENTIFIER LPAR Parameters RPAR Type FuncBody    {$$ = newnode(FuncDecl, NULL);
                                                                                fHeader = newnode(FuncHeader, NULL);
                                                                                
                                                                                addchild(fHeader, newnode(Identifier,$2));
                                                                                addchild(fHeader, $6);
                                                                                
                                                                                fParam = newnode(FuncParams, NULL);
                                                                                adoptChildren(fParam, $4);
                                                                                addchild(fHeader, fParam);

                                                                                addchild($$, fHeader);
                                                                                addchild($$, $7);}
                    
                    
;


Parameters: IDENTIFIER Type ParamOpts           {   if($3 != NULL){
                                                        
                                                        $$ = newnode(AuxNode, NULL);
                                                        parDec = newnode(ParamDecl, NULL);
                                                        addchild(parDec, $2);    
                                                        addchild(parDec, newnode(Identifier, $1));
                                                        addchild($$, parDec);                           
                                                        adoptChildren($$, $3);
                                                    }else{                                                        
                                                        $$ = newnode(ParamDecl, NULL);
                                                        addchild($$, $2);
                                                        addchild($$, newnode(Identifier, $1));
                                                        
                                                    }
                                                    }
;

ParamOpts:  ParamOpts COMMA IDENTIFIER Type         {$$ = $1;
                                                            parDec = newnode(ParamDecl, NULL);
                                                            addchild(parDec, $4);                                                            
                                                            addchild(parDec, newnode(Identifier, $3));
                                                            addchild($$, parDec);
                                                        }
    |                                                {$$ = newnode(AuxNode, NULL);}          
;

FuncBody:   LBRACE VarsAndStatements RBRACE                {    $$ = newnode(FuncBody, NULL);
                                                                if($2 != NULL)
                                                                    adoptChildren($$, $2);}
;

VarsAndStatements:  VarsAndStatements SEMICOLON                        {if($1 != NULL){
                                                                            
                                                                            $$ = $1;

                                                                        }else{
                                                                            $$ = newnode(AuxNode, NULL);                                                                            

                                                                        }
                                                                        ;}
                    | VarsAndStatements VarDeclaration SEMICOLON        {if($1 != NULL){
                                                                            
                                                                            $$ = $1;
                                                                            adoptChildren($$, $2);
                                                                        }else{
                                                                            $$ = newnode(AuxNode, NULL);                                                                            
                                                                            adoptChildren($$, $2);
                                                                        };}
                    | VarsAndStatements Statement SEMICOLON             {   if($1 != NULL){
                                                                                $$ = $1;
                                                                                if($2->category == Block && countchildren($2) < 2){                                                                                                                                                              
                                                                                    adoptChildren($$, $2);
                                                                                }else{                                                                                                                                                                
                                                                                    addchild($$, $2);
                                                                                }                                                                              
                                                                            
                                                                            }else{
                                                                                $$ = newnode(AuxNode, NULL);                                                                              
                                                                                if($2->category == Block && countchildren($2) < 2){                                                                                                                                                        
                                                                                    adoptChildren($$, $2);
                                                                                }else{                                                                                                                                                                    
                                                                                    addchild($$, $2);
                                                                                } 
                                                                            }
                                                                        }
                    |                                                   {$$ = NULL;}
;



Statement:  IDENTIFIER ASSIGN Expr                                  {$$ = newnode(Assign, NULL);
                                                                        addchild($$, newnode(Identifier, $1));
                                                                        addchild($$, $3);
                                                                        
                                                                    }                                                                      
    | LBRACE StateSemi RBRACE                                       {$$ = newnode(Block, NULL);
                                                                        if($2 != NULL){
                                                                            adoptChildren($$, $2);
                                                                            }
                                                                        }
    | IF Expr LBRACE StateSemi RBRACE ELSE LBRACE StateSemi RBRACE {  $$ = newnode(If, NULL);
                                                                        addchild($$, $2);

                                                                        blockNode = newnode(Block, NULL);  
                                                                        addchild($$, blockNode);

                                                                        if($4 != NULL){
                                                                            adoptChildren(blockNode, $4);                                                                                                                                                                            
                                                                        }

                                                                        blockNodeElse = newnode(Block, NULL);
                                                                        addchild($$, blockNodeElse);
                                                                        if($8 != NULL){
                                                                            adoptChildren(blockNodeElse, $8);                                                                                   
                                                                        }                                                                                   
                                                                    }
    | IF Expr LBRACE StateSemi RBRACE                               { $$ = newnode(If, NULL);
                                                                        addchild($$, $2); 

                                                                        blockNode = newnode(Block, NULL);
                                                                        addchild($$, blockNode);

                                                                        if($4 != NULL){
                                                                            adoptChildren(blockNode, $4); 
                                                                        }
                                                                                  
                                                                        addchild($$, newnode(Block, NULL));                                                                                 
                                                                        }
    | FOR Expr LBRACE StateSemi RBRACE                              { $$ = newnode(For, NULL);
                                                                        addchild($$, $2);
                                                                        blockNode = newnode(Block, NULL);
                                                                        addchild($$, blockNode);

                                                                        if($4 != NULL){
                                                                            adoptChildren(blockNode, $4);
                                                                        }                                                     
                                                                     }
    | FOR LBRACE StateSemi RBRACE                                   { $$ = newnode(For, NULL); 
                                                                            
                                                                            blockNode = newnode(Block, NULL);
                                                                            addchild($$, blockNode);

                                                                            if($3 != NULL){
                                                                                adoptChildren(blockNode, $3);                                                       
                                                                            }
                                                                                                                                                                                        
                                                                    }
    |   RETURN Expr                                                 {$$ = newnode(Return, NULL);
                                                                        addchild($$, $2);}
    |   RETURN                                                      {$$ = newnode(Return, NULL);}
    |   FuncInvocation                                              {$$ = $1;}
    |   ParseArgs                                                   {$$ = $1;}
    |   PRINT LPAR STRLIT RPAR                                      {$$ = newnode(Print, NULL);
                                                                        addchild($$, newnode(StrLit, $3));}
    |   PRINT LPAR Expr RPAR                                        {$$ = newnode(Print, NULL);
                                                                        addchild($$, $3);}   
    |   error                                                       {;}                          
;


StateSemi: StateSemi Statement SEMICOLON                            { if($1 != NULL){
                                                                            $$ = $1;
                                                                            if($2->category == Block && countchildren($2) < 2){                                                                                                                                                              
                                                                                adoptChildren($$, $2);
                                                                            }else{                                                                                                                                                                 
                                                                                addchild($$, $2);
                                                                            }
                                                                        }else{
                                                                            $$ = newnode(AuxNode, NULL);
                                                                            if($2->category == Block && countchildren($2) < 2){                                                                                                                                                              
                                                                                adoptChildren($$, $2);
                                                                            }else{                                                                                                                                                                
                                                                                addchild($$, $2);
                                                                            }
                                                                        }
                                                                        }
    |                                                               {$$ = NULL;}
;

ParseArgs:  IDENTIFIER COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR     {$$ = newnode(ParseArgs, NULL);
                                                                                            addchild($$, newnode(Identifier, $1));
                                                                                            addchild($$, $9);}
    |  IDENTIFIER COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ error RSQ RPAR    {;}
;

FuncInvocation: IDENTIFIER LPAR Expr FuncInvocationOpts RPAR                { $$ = newnode(Call, NULL);
                                                                                addchild($$, newnode(Identifier, $1));
                                                                                addchild($$, $3);
                                                                                if($4 != NULL){
                                                                                    adoptChildren($$, $4);
                                                                                }
                                                                            }

    |  IDENTIFIER LPAR FuncInvocationOpts RPAR                 { $$ = newnode(Call, NULL);
                                                                    addchild($$, newnode(Identifier, $1));                                                                    
                                                                    if($3 != NULL)
                                                                        adoptChildren($$, $3); }    
    |  IDENTIFIER LPAR error RPAR                              {;}
;

FuncInvocationOpts: FuncInvocationOpts COMMA Expr                  {    if($1 == NULL){
                                                                            $$ = newnode(AuxNode, NULL);
                                                                            addchild($$, $3);
                                                                        }else{
                                                                            $$ = $1;
                                                                            addchild($$, $3);
                                                                        }  
                                                                    }
    |                                                   {$$ = NULL;}
;
 
Expr:   Expr OR Expr                                    {$$ = newnode(Or, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);}
    |   Expr AND Expr                                   {$$ = newnode(And, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);
                                                            }
    |   Expr EQ Expr                                    {$$ = newnode(Eq, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);
                                                            }
    |   Expr NE Expr                                    {$$ = newnode(Ne, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);}
    |   Expr LT Expr                                    {$$ = newnode(Lt, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);
                                                            }
    |   Expr GT Expr                                    {$$ = newnode(Gt, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);
                                                            }
    |   Expr GE Expr                                    {$$ = newnode(Ge, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);}
    |   Expr LE Expr                                    {$$ = newnode(Le, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);}
    |   Expr PLUS Expr                                  {$$ = newnode(Add, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);}
    |   Expr MINUS Expr                                 {$$ = newnode(Sub, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);}
    |   Expr STAR Expr                                  {$$ = newnode(Mul, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);}
    |   Expr DIV Expr                                   {$$ = newnode(Div, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);}
    |   Expr MOD Expr                                   {$$ = newnode(Mod, NULL);
                                                            addchild($$, $1);
                                                            addchild($$, $3);}
    |   NOT Expr                                        {$$ = newnode(Not, NULL);                                                    
                                                            addchild($$, $2);}
    |   MINUS Expr          %prec UNARY               {$$ = newnode(Minus, NULL);
                                                            addchild($$, $2);}
    |   PLUS Expr           %prec UNARY                 {$$ = newnode(Plus, NULL);
                                                            addchild($$, $2);}
    |   NATURAL                                         {$$ = newnode(Natural, $1);}
    |   DECIMAL                                         {$$ = newnode(Decimal, $1);}
    |   IDENTIFIER                                      {$$ = newnode(Identifier, $1);}      
    |   FuncInvocation                                  {$$ = $1;}
    |   LPAR Expr RPAR                                  {$$ = $2;}
    |   LPAR error RPAR                                 {;}
    
;
%%
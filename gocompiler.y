%{

#include <stdio.h>
#include "goast.h"

int yylex(void);
void yyerror(char *);

struct node *program;

%}

%token <lexeme> STRLIT IDENTIFIER NATURAL DECIMAL
%token <lexeme> PLUS MINUS STAR DIV MOD EQ GE GT LE LT NE NOT AND OR RETURN PRINT PARSEINT INT FLOAT32 BOOL STRING ASSIGN
%token PACKAGE IF ELSE FOR LPAR RPAR LBRACE RBRACE LSQ RSQ SEMICOLON COMMA BLANKID VAR CMDARGS FUNC
%token RESERVED
%type<node> Program Declarations FuncDeclaration VarSpec Type Func FuncBody Parameters VarsAndStatements
%type<node> VarDeclaration Statement Expr FuncInvocation ParseArgs

%right  ASSIGN
%left   OR
%left   AND
%left   EQ NE
%left   LE LT GE GT
%left   PLUS MINUS
%left   MUL DIV MOD
%right  NOT
%left   LPAR
%left   RPAR

%nonassoc LOWER
%nonassoc ELSE
%nonassoc HIGHER

%union{
    char *lexeme;
    struct node *node;
}

Program:
        PACKAGE IDENTIFIER SEMICOLON Declarations               
;

Declarations:
        Declarations VarDeclaration SEMICOLON           
    |   Declarations FuncDeclaration SEMICOLON          
    |   /* empty */                                 {$$ = NULL;}     
;

VarDeclaration:
        VAR VarSpec                                 {$$ = $2;}   
    |   VAR LPAR VarSpec SEMICOLON RPAR                 
;

VarSpec:
        IDENTIFIER ... Type              //devolve lista com varspecs                    
;

Type:
        INT                                             
    |   FLOAT32                                         
    |   BOOL                                            
    |   STRING                                          
;

FuncDeclaration:
        FUNC IDENTIFIER LPAR FuncParams RPAR FuncType FuncBody  
;

FuncParams:
        Parameters                                      
    |                                        
;

FuncType:
        Type                                            
    |                                     
;

Parameters:
       IDENTIFIER Type ParamOpts                               
;

ParamOpts:
        COMMA IDENTIFIER Type ParamOpts                         
    |   /* empty */                                     
;

FuncBody:
        LBRACE VarsAndStatements RBRACE                 
;

VarsAndStatements:
        VarsAndStatements VASOpts SEMICOLON             
    |   /* empty */                                     
;

Statement:
        IDENTIFIER ASSIGN Expr                                  
    |   LBRACE StateSemi RBRACE                              
    |   IF Expr LBRACE StateSemi RBRACE StateSemi   
    |   FOR Expr LBRACE StateSemi RBRACE         
    |   FOR LBRACE StateSemi RBRACE         
    |   RETURN Expr
    |   RETURN                                  
    |   FuncInvocation                                  
    |   ParseArgs                                       
    |   PRINT LPAR STRLIT RPAR                          
    |   PRINT LPAR Expr RPAR                                                                     
;

StateSemi:
        Statement SEMICOLON                                                                
    |                                   
;

ParseArgs:
       IDENTIFIER COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR     
    |  IDENTIFIER COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ error RSQ RPAR    
;

FuncInvocation:
       IDENTIFIER LPAR FuncInvocationOpts RPAR                 
    |  IDENTIFIER LPAR error RPAR                              
;


 
Expr:
        Expr OR Expr                                    
    |   Expr AND Expr                                   
    |   Expr EQ Expr                                    
    |   Expr NE Expr                                    
    |   Expr LT Expr                                    
    |   Expr GT Expr                                    
    |   Expr GE Expr                                    
    |   Expr LE Expr                                    
    |   Expr PLUS Expr                                  
    |   Expr MINUS Expr                                 
    |   Expr STAR Expr                                  
    |   Expr DIV Expr                                   
    |   Expr MOD Expr                                   
    |   NOT Expr                                        
    |   MINUS Expr                         
    |   PLUS Expr                        
    |   INTLIT                                          
    |   REALLIT                                         
    |   IDENTIFIER                                              
    |   FuncInvocation                                  
    |   LPAR Expr RPAR                                  
    
;
%%
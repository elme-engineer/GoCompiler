%{

#include <stdio.h>
#include "y.tab.h"
#include "goast.h"

int yylex(void);
void yyerror(char *);
int yyparse(void);

struct node *program;

%}

%union{
    char *lexeme;
    struct node *node;
}


%token PLUS MINUS STAR DIV MOD EQ GE GT LE LT NE NOT AND OR RETURN PRINT PARSEINT INT FLOAT32 BOOL STRING ASSIGN
%token PACKAGE IF ELSE FOR LPAR RPAR LBRACE RBRACE LSQ RSQ SEMICOLON COMMA BLANKID VAR CMDARGS FUNC RESERVED 
%token <lexeme> STRLIT IDENTIFIER NATURAL DECIMAL
%type<node> Program Declarations FuncDeclaration VarSpec Type FuncBody Parameters VarsAndStatements StateSemi
%type<node> VarDeclaration Statement Expr FuncInvocation ParseArgs FuncInvocationOpts ElseSemi VarSpecOpts

%right ASSIGN
%left IFCASE
%left OR
%left AND
%left EQ NE
%left LE LT GE GT
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%right UMINUS

%nonassoc LPAR RPAR

%%

Program:    PACKAGE IDENTIFIER SEMICOLON Declarations               {;}
;

Declarations: Declarations VarDeclaration SEMICOLON     {;}           
    |   Declarations FuncDeclaration SEMICOLON          {;}
    |                                                      {;}     
;

VarDeclaration:    VAR VarSpec                           {;}   
    |   VAR LPAR VarSpec SEMICOLON RPAR                  {;}
;

VarSpec:    IDENTIFIER VarSpecOpts Type        {  ;  }
;

VarSpecOpts:    COMMA IDENTIFIER VarSpecOpts             {;}
                |                               {;}


Type: INT                                 {;}            
    |   FLOAT32                           {;}            
    |   BOOL                              {;}             
    |   STRING                            {;}              
;

FuncDeclaration:    FUNC IDENTIFIER LPAR RPAR FuncBody                  {;}
                    | FUNC IDENTIFIER LPAR Parameters RPAR FuncBody       {;}                    
                    | FUNC IDENTIFIER LPAR RPAR Type FuncBody             {;}
                    | FUNC IDENTIFIER LPAR Parameters RPAR Type FuncBody  {;}
                    
                    
;


Parameters: IDENTIFIER Type ParamOpts           {;}
;

ParamOpts:  COMMA IDENTIFIER Type ParamOpts        {;}
    |                                                {;}          
;

FuncBody:   LBRACE VarsAndStatements RBRACE                {;}
;

VarsAndStatements:  VarsAndStatements SEMICOLON                        {;}
                    | VarsAndStatements VarDeclaration SEMICOLON             {;}
                    | VarsAndStatements Statement SEMICOLON             {;}
                    |                                                   {;}
;



Statement:  IDENTIFIER ASSIGN Expr                                  {;}
    |   LBRACE StateSemi RBRACE                                     {;}
    |   IF Expr LBRACE StateSemi RBRACE ElseSemi   %prec IFCASE     {;}
    |   FOR Expr LBRACE StateSemi RBRACE                            {;}
    |   FOR LBRACE StateSemi RBRACE                                 {;}
    |   RETURN Expr                                                 {;}
    |   RETURN                                                      {;}
    |   FuncInvocation                                              {;}
    |   ParseArgs                                                   {;}
    |   PRINT LPAR STRLIT RPAR                                      {;}
    |   PRINT LPAR Expr RPAR                                        {;}   
    |   error                                                       {;}                          
;

ElseSemi:   ELSE LBRACE StateSemi RBRACE                            {;}
    |                                                               {;}
;

StateSemi:  StateSemi Statement SEMICOLON                                 {;}
    |                                                               {;}
;

ParseArgs:  IDENTIFIER COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR     {;}
    |  IDENTIFIER COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ error RSQ RPAR    {;}
;

FuncInvocation: IDENTIFIER LPAR Expr FuncInvocationOpts RPAR                 {;}
    |   IDENTIFIER LPAR FuncInvocationOpts RPAR                 {;}    
    |  IDENTIFIER LPAR error RPAR                              {;}
;

FuncInvocationOpts: FuncInvocationOpts COMMA Expr                  {;}
    |                                                   {;}
;
 
Expr:   Expr OR Expr                                    {;}
    |   Expr AND Expr                                   {;}
    |   Expr EQ Expr                                    {;}
    |   Expr NE Expr                                    {;}
    |   Expr LT Expr                                    {;}
    |   Expr GT Expr                                    {;}
    |   Expr GE Expr                                    {;}
    |   Expr LE Expr                                    {;}
    |   Expr PLUS Expr                                  {;}
    |   Expr MINUS Expr                                 {;}
    |   Expr STAR Expr                                  {;}
    |   Expr DIV Expr                                   {;}
    |   Expr MOD Expr                                   {;}
    |   NOT Expr                                        {;}
    |   MINUS Expr          %prec UMINUS                {;}
    |   PLUS Expr           %prec UMINUS                {;}
    |   NATURAL                                         {;}
    |   DECIMAL                                         {;}
    |   IDENTIFIER                                      {;}      
    |   FuncInvocation                                  {;}
    |   LPAR Expr RPAR                                  {;}
    |   LPAR error RPAR                                 {;}
    
;
%%
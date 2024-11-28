%{

#include "y.tab.h"
#include "goast.h"

int syn_line = -1, syn_column = -1;

#define PASS_TOKEN() yylval.lexeme = strdup(yytext);
#define YY_USER_ACTION { syn_line = line_counter; syn_column = column_counter;}

int yyparse(void);
void yyerror( const char *s);


int column_counter = 1;
int line_counter = 1;
int errorLine = 0;
int errorColumn = 0;
int errors = 0;
int semicolon = 0;
int lex = 0;
int yacc = 0;
int errorNoSemi = 0;

extern struct node *program;

%}
%option noyywrap
%option yylineno

INTEGER			    [1-9][0-9]*
OCTAL			    0[0-7]*
HEX		            0[xX][0-9a-fA-F]+
IDENTIFIER          [a-zA-Z_]+([a-zA-Z_]+|[0-9])*
DECIMAL             ((([0-9]+"."{0,1})|([0-9]*"."[0-9]+))([eE]{1}[+-]{0,1}[0-9]+)?)
STRLIT			    \"([^\n\r\"\\]|\\[fnrt\\\"])*\"

INT			        int
ELSE			    else
IF			        if
FOR                 for
PACKAGE             package
VAR                 var
FLOAT32             float32
BOOL                bool
STRING              string
PRINT               fmt.Println
PARSEINT            strconv.Atoi
FUNC                func
CMDARGS             os.Args
RETURN		  	    return

BLANKID             "_"
STAR			    "*"
EQ			        "=="
GE			        ">="
GT			        ">"
LBRACE		  	    "{"
LSQ                 "["
LE			        "<="
LPAR			    "("
LT			        "<"
AND			        "&&"
MOD			        "%"
NE			        "!="
NOT			        "!"
OR			        "||"
RBRACE		  	    "}"
RPAR			    ")"
RSQ                 "]"
DIV			        "/"
MINUS		    	"-"
PLUS			    "+"
ASSIGN		  	    "="
COMMA		   	    ","
SEMICOLON		    ";"

ws [\t ]
newline \n|\r\n
reserved "++"|"--"|break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|package|range|return|select|struct|switch|type|var

%x LCOMMENT BCOMMENT BADSTR
%%

"/*"				            { BEGIN (BCOMMENT); errorColumn = column_counter; column_counter += yyleng; errorLine = line_counter; }
<BCOMMENT>{newline}			    { column_counter = 1; line_counter++; }
<BCOMMENT>.			            { column_counter += yyleng;}
<BCOMMENT><<EOF>>               { errorNoSemi = 1; YY_USER_ACTION; printf("Line %d, column %d: unterminated comment\n", errorLine, errorColumn); BEGIN(INITIAL);}
<BCOMMENT>"*/"		            { column_counter += yyleng; BEGIN(INITIAL); }

"//"				            { BEGIN(LCOMMENT); column_counter += yyleng; }
<LCOMMENT>.			            { column_counter += yyleng;}
<LCOMMENT>\n			       	{ line_counter++; BEGIN(INITIAL); column_counter = 1; if(semicolon){semicolon = 0; if(lex)printf("SEMICOLON\n"); if(yacc)return SEMICOLON;};  }

{ws}                            { column_counter += yyleng;}
{newline}                       { column_counter = 1; line_counter += 1; if(semicolon){semicolon = 0; if(lex)printf("SEMICOLON\n"); if(yacc)return SEMICOLON;};}


\"				                { errorColumn = column_counter; column_counter += yyleng; errorLine = line_counter; BEGIN(BADSTR);}

{INTEGER}                       { if(lex){printf("NATURAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;   if(yacc){PASS_TOKEN(); return NATURAL; } }
{OCTAL}                         { if(lex){printf("NATURAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;   if(yacc){PASS_TOKEN(); return NATURAL; } }
0[0-9]*                         { {printf("Line %d, column %d: invalid octal constant (%s)\n", line_counter, column_counter, yytext);} column_counter += yyleng;}
{HEX}                           { if(lex){printf("NATURAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;   if(yacc){PASS_TOKEN(); return NATURAL; } }
{DECIMAL}                       { if(lex){printf("DECIMAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;   if(yacc){PASS_TOKEN(); return DECIMAL; } }
{STRLIT}                        { if(lex){printf("STRLIT(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;    if(yacc){PASS_TOKEN(); return STRLIT; } }

{RSQ}                           { if(lex){printf("RSQ\n");}; semicolon = 1; column_counter += yyleng;                   if(yacc)return RSQ;}
{LSQ}                           { if(lex){printf("LSQ\n");}; semicolon = 0; column_counter += yyleng;                   if(yacc)return LSQ;}
{BLANKID}                       { if(lex){printf("BLANKID\n");}; semicolon = 0; column_counter += yyleng;               if(yacc)return BLANKID;}
{ASSIGN}			            { if(lex){printf("ASSIGN\n");}; semicolon = 0; column_counter += yyleng;                if(yacc)return ASSIGN;}
{STAR}				            { if(lex){printf("STAR\n");}; semicolon = 0; column_counter += yyleng;                  if(yacc)return STAR;}
{COMMA}				            { if(lex){printf("COMMA\n");}; semicolon = 0; column_counter += yyleng;                 if(yacc)return COMMA;} 
{DIV}				            { if(lex){printf("DIV\n");}; semicolon = 0; column_counter += yyleng;                   if(yacc)return DIV;}
{EQ}				            { if(lex){printf("EQ\n");}; semicolon = 0; column_counter += yyleng;                    if(yacc)return EQ;}
{GE}				            { if(lex){printf("GE\n");}; semicolon = 0; column_counter += yyleng;                    if(yacc)return GE;}
{GT}				            { if(lex){printf("GT\n");}; semicolon = 0; column_counter += yyleng;                    if(yacc)return GT;}
{LBRACE}				        { if(lex){printf("LBRACE\n");}; semicolon = 0; column_counter += yyleng;                if(yacc)return LBRACE;}
{LE}				            { if(lex){printf("LE\n");}; semicolon = 0; column_counter += yyleng;                    if(yacc)return LE;}
{LPAR}				            { if(lex){printf("LPAR\n");}; semicolon = 0; column_counter += yyleng;                  if(yacc)return LPAR;}
{LT}				            { if(lex){printf("LT\n");}; semicolon = 0; column_counter += yyleng;                    if(yacc)return LT;}
{MINUS}				            { if(lex){printf("MINUS\n");}; semicolon = 0; column_counter += yyleng;                 if(yacc)return MINUS;}
{MOD}				            { if(lex){printf("MOD\n");}; semicolon = 0; column_counter += yyleng;                   if(yacc)return MOD;}
{NE}				            { if(lex){printf("NE\n");}; semicolon = 0; column_counter += yyleng;                    if(yacc)return NE;}
{NOT}				            { if(lex){printf("NOT\n");}; semicolon = 0; column_counter += yyleng;                   if(yacc)return NOT;}
{OR}				            { if(lex){printf("OR\n");}; semicolon = 0; column_counter += yyleng;                    if(yacc)return OR;}
{PLUS}				            { if(lex){printf("PLUS\n");}; semicolon = 0; column_counter += yyleng;                  if(yacc)return PLUS;}
{RBRACE}				        { if(lex){printf("RBRACE\n");}; semicolon = 1; column_counter += yyleng;                if(yacc)return RBRACE;}
{RPAR}				            { if(lex){printf("RPAR\n");}; semicolon = 1; column_counter += yyleng;                  if(yacc)return RPAR;}
{SEMICOLON}				        { if(lex){printf("SEMICOLON\n");}; semicolon = 0; column_counter += yyleng;             if(yacc)return SEMICOLON;}

{CMDARGS}                       { if(lex){printf("CMDARGS\n");}; semicolon = 0; column_counter += yyleng;               if(yacc)return CMDARGS;}
{PARSEINT}                      { if(lex){printf("PARSEINT\n");}; semicolon = 0; column_counter += yyleng;              if(yacc)return PARSEINT;}
{STRING}                        { if(lex){printf("STRING\n");}; semicolon = 0; column_counter += yyleng;                if(yacc)return STRING;}
{BOOL}                          { if(lex){printf("BOOL\n");}; semicolon = 0; column_counter += yyleng;                  if(yacc)return BOOL;}
{FLOAT32}                       { if(lex){printf("FLOAT32\n");}; semicolon = 0; column_counter += yyleng;               if(yacc)return FLOAT32;}
{VAR}                           { if(lex){printf("VAR\n");}; semicolon = 0; column_counter += yyleng;                   if(yacc)return VAR;}
{PACKAGE}                       { if(lex){printf("PACKAGE\n");}; semicolon = 0; column_counter += yyleng;               if(yacc)return PACKAGE;}
{FUNC}                          { if(lex){printf("FUNC\n");}; semicolon = 0; column_counter += yyleng;                  if(yacc)return FUNC;}
{AND}				            { if(lex){printf("AND\n");}; semicolon = 0; column_counter += yyleng;                   if(yacc)return AND;}
{PRINT}                         { if(lex){printf("PRINT\n");}; semicolon = 0; column_counter += yyleng;                 if(yacc)return PRINT;}



{ELSE}                          { if(lex){printf("ELSE\n");}; semicolon = 0; column_counter += yyleng;                  if(yacc)return ELSE;}
{INT}                           { if(lex){printf("INT\n");}; semicolon = 0; column_counter += yyleng;                   if(yacc)return INT;}
{FOR}                           { if(lex){printf("FOR\n");}; semicolon = 0; column_counter += yyleng;                   if(yacc)return FOR;}
{IF}                            { if(lex){printf("IF\n");}; semicolon = 0; column_counter += yyleng;                    if(yacc)return IF;}
{RETURN}                        { if(lex){printf("RETURN\n");}; semicolon = 1; column_counter += yyleng;                if(yacc)return RETURN;}

{reserved}                      { if(lex){printf("RESERVED(%s)\n", yytext);} semicolon = 0; column_counter += yyleng;   if(yacc)return RESERVED;}

{IDENTIFIER}	                { if(lex){printf("IDENTIFIER(%s)\n", yytext);} semicolon = 1; column_counter += yyleng; if(yacc){PASS_TOKEN(); return IDENTIFIER; } }


.                               { printf("Line %d, column %d: illegal character (%s)\n", line_counter, column_counter, yytext); column_counter += yyleng;}

<BADSTR>\\				        { errorColumn++; printf("Line %d, column %d: invalid escape sequence (\\)\n", errorLine, errorColumn);}
<BADSTR>\\[fnrt\\\"]	        { errorColumn += 2;}
<BADSTR>\\.				        { errorColumn++; printf("Line %d, column %d: invalid escape sequence (%s)\n", errorLine, errorColumn++, yytext);}
<BADSTR>\"				        { column_counter = errorColumn + 2; errorColumn = 1; BEGIN 0;}
<BADSTR>{newline}		        { printf("Line %d, column %d: unterminated string literal\n", errorLine, column_counter - 1); column_counter = 1; line_counter++;BEGIN 0;}
<BADSTR><<EOF>>			        { printf("Line %d, column %d: unterminated string literal\n", errorLine, column_counter-1); yyterminate();}
<BADSTR>.				        { ++errorColumn;}


<INITIAL><<EOF>>	            {syn_line++; syn_column=1; if(semicolon && !errorNoSemi){semicolon = 0; if(lex) printf("SEMICOLON\n"); else return SEMICOLON;} yyterminate();}


%%
extern int yylex();
int main(int argc, char*argv[]) {

    if (argc >= 2){
        if(strcmp(argv[1], "-l") == 0){
            lex++;
            yacc = 0;
            yylex();
        }
        else if(strcmp(argv[1], "-t") == 0){
            lex = 0;
            yacc = 1;
        }
        
    }

    #ifdef DEBUG
        yydebug = 1;
    #endif
    yyparse();
    
    if(errors == 0){
        show(program, 0);
    }
    
    return 0;

}


void yyerror (const char *s){
    errors++;
   // YY_USER_ACTION;
    printf("Line %d, column %d: %s: %s\n", syn_line, syn_column, s, yytext);

}
%{

int syn_line = -1, syn_column = -1;


#define YY_USER_ACTION { syn_line = line_counter; syn_column = column_counter;}

void yyerror( const char *s);


int column_counter = 1;
int line_counter = 1;
int errorLine = 0;
int errorColumn = 0;
int errors = 0;
int semicolon = 0;
int lex = 0;
int errorNoSemi = 0;

%}
%option noyywrap



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
%option yylineno
%x LCOMMENT BCOMMENT BADSTR
%%

"/*"				            { BEGIN (BCOMMENT); errorColumn = column_counter; column_counter += yyleng; errorLine = line_counter; }
<BCOMMENT>{newline}			    { column_counter = 1; line_counter++; }
<BCOMMENT>.			            { column_counter += yyleng;}
<BCOMMENT><<EOF>>               { errorNoSemi = 1; YY_USER_ACTION; printf("Line %d, column %d: unterminated comment\n", errorLine, errorColumn); BEGIN(INITIAL);}
<BCOMMENT>"*/"		            { column_counter += yyleng; BEGIN(INITIAL); }

"//"				            { BEGIN(LCOMMENT); column_counter += yyleng; }
<LCOMMENT>.			            { column_counter += yyleng;}
<LCOMMENT>\n			       	{ if(semicolon){semicolon = 0; if(lex)printf("SEMICOLON\n");}; line_counter++; BEGIN(INITIAL); column_counter = 1; }

{ws}                            { column_counter += yyleng;}
{newline}                       { column_counter = 1; line_counter += 1; if(semicolon){semicolon = 0; if(lex)printf("SEMICOLON\n");};}


\"				                { errorColumn = column_counter; column_counter += yyleng; errorLine = line_counter; BEGIN(BADSTR);}

{INTEGER}                       { if(lex){printf("NATURAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}
{OCTAL}                         { if(lex){printf("NATURAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}
0[0-9]*                         { {printf("Line %d, column %d: invalid octal constant (%s)\n", line_counter, column_counter, yytext);} column_counter += yyleng;}
{HEX}                           { if(lex){printf("NATURAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}
{DECIMAL}                       { if(lex){printf("DECIMAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}
{STRLIT}                        { if(lex){printf("STRLIT(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}

{RSQ}                           { if(lex){printf("RSQ\n");}; semicolon = 1; column_counter += yyleng;}
{LSQ}                           { if(lex){printf("LSQ\n");}; semicolon = 0; column_counter += yyleng;}
{BLANKID}                       { if(lex){printf("BLANKID\n");}; semicolon = 0; column_counter += yyleng;}
{ASSIGN}			            { if(lex){printf("ASSIGN\n");}; semicolon = 0; column_counter += yyleng;}
{STAR}				            { if(lex){printf("STAR\n");}; semicolon = 0; column_counter += yyleng;}
{COMMA}				            { if(lex){printf("COMMA\n");}; semicolon = 0; column_counter += yyleng;}
{DIV}				            { if(lex){printf("DIV\n");}; semicolon = 0; column_counter += yyleng;}
{EQ}				            { if(lex){printf("EQ\n");}; semicolon = 0; column_counter += yyleng;}
{GE}				            { if(lex){printf("GE\n");}; semicolon = 0; column_counter += yyleng;}
{GT}				            { if(lex){printf("GT\n");}; semicolon = 0; column_counter += yyleng;}
{LBRACE}				        { if(lex){printf("LBRACE\n");}; semicolon = 0; column_counter += yyleng;}
{LE}				            { if(lex){printf("LE\n");}; semicolon = 0; column_counter += yyleng;}
{LPAR}				            { if(lex){printf("LPAR\n");}; semicolon = 0; column_counter += yyleng;}
{LT}				            { if(lex){printf("LT\n");}; semicolon = 0; column_counter += yyleng;}
{MINUS}				            { if(lex){printf("MINUS\n");}; semicolon = 0; column_counter += yyleng;}
{MOD}				            { if(lex){printf("MOD\n");}; semicolon = 0; column_counter += yyleng;}
{NE}				            { if(lex){printf("NE\n");}; semicolon = 0; column_counter += yyleng;}
{NOT}				            { if(lex){printf("NOT\n");}; semicolon = 0; column_counter += yyleng;}
{OR}				            { if(lex){printf("OR\n");}; semicolon = 0; column_counter += yyleng;}
{PLUS}				            { if(lex){printf("PLUS\n");}; semicolon = 0; column_counter += yyleng;}
{RBRACE}				        { if(lex){printf("RBRACE\n");}; semicolon = 1; column_counter += yyleng;}
{RPAR}				            { if(lex){printf("RPAR\n");}; semicolon = 1; column_counter += yyleng;}
{SEMICOLON}				        { if(lex){printf("SEMICOLON\n");}; semicolon = 0; column_counter += yyleng;}

{CMDARGS}                       { if(lex){printf("CMDARGS\n");}; semicolon = 0; column_counter += yyleng;}
{PARSEINT}                      { if(lex){printf("PARSEINT\n");}; semicolon = 0; column_counter += yyleng;}
{STRING}                        { if(lex){printf("STRING\n");}; semicolon = 0; column_counter += yyleng;}
{BOOL}                          { if(lex){printf("BOOL\n");}; semicolon = 0; column_counter += yyleng;}
{FLOAT32}                       { if(lex){printf("FLOAT32\n");}; semicolon = 0; column_counter += yyleng;}
{VAR}                           { if(lex){printf("VAR\n");}; semicolon = 0; column_counter += yyleng;}
{PACKAGE}                       { if(lex){printf("PACKAGE\n");}; semicolon = 0; column_counter += yyleng;}
{FUNC}                          { if(lex){printf("FUNC\n");}; semicolon = 0; column_counter += yyleng;}
{AND}				            { if(lex){printf("AND\n");}; semicolon = 0; column_counter += yyleng;}
{PRINT}                         { if(lex){printf("PRINT\n");}; semicolon = 0; column_counter += yyleng;}



{ELSE}                          { if(lex){printf("ELSE\n");}; semicolon = 0; column_counter += yyleng; }
{INT}                           { if(lex){printf("INT\n");}; semicolon = 0; column_counter += yyleng; }
{FOR}                           { if(lex){printf("FOR\n");}; semicolon = 0; column_counter += yyleng; }
{IF}                            { if(lex){printf("IF\n");}; semicolon = 0; column_counter += yyleng; }
{RETURN}                        { if(lex){printf("RETURN\n");}; semicolon = 1; column_counter += yyleng;}

{reserved}                      { if(lex){printf("RESERVED(%s)\n", yytext);} semicolon = 0; column_counter += yyleng;}

{IDENTIFIER}	                { if(lex){printf("IDENTIFIER(%s)\n", yytext);} semicolon = 1; column_counter += yyleng; }


.                               { printf("Line %d, column %d: illegal character (%s)\n", line_counter, column_counter, yytext); column_counter += yyleng;}

<BADSTR>\\				        { errorColumn++; printf("Line %d, column %d: invalid escape sequence (\\)\n", errorLine, errorColumn);}
<BADSTR>\\[fnrt\\\"]	        { errorColumn += 2;}
<BADSTR>\\.				        { errorColumn++; printf("Line %d, column %d: invalid escape sequence (%s)\n", errorLine, errorColumn++, yytext);}
<BADSTR>\"				        { column_counter = errorColumn + 2; errorColumn = 1; BEGIN 0;}
<BADSTR>{newline}		        { printf("Line %d, column %d: unterminated string literal\n", errorLine, column_counter - 1); column_counter = 1; line_counter++;BEGIN 0;}
<BADSTR><<EOF>>			        { printf("Line %d, column %d: unterminated string literal\n", errorLine, column_counter-1); yyterminate();}
<BADSTR>.				        { ++errorColumn;}


<INITIAL><<EOF>>	            { if(semicolon && !errorNoSemi){semicolon = 0; if(lex)printf("SEMICOLON\n");} yyterminate();}


%%
extern int yylex();
int main(int argc, char*argv[]) {

    if (argc >= 2){
        if(strcmp(argv[1], "-l") == 0){
            lex++;
            
        }
    }else
        lex = 0;
 
    yylex();
}

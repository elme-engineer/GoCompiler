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

%}
%option noyywrap



INTEGER			    [1-9][0-9]*
OCTAL			    0[0-7]*
HEX		            0[xX][0-9a-fA-F]+
IDENTIFIER          [a-zA-Z_]+([a-zA-Z_]|[0-9])*
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
newline \n|\r\n|\r
reserved "++"|"--"|break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|package|range|return|select|struct|switch|type|var
%option yylineno
%x LCOMMENT BCOMMENT BADSTR
%%

"/*"				            { BEGIN (BCOMMENT); errorColumn = column_counter; column_counter += yyleng; errorLine = line_counter; }
<BCOMMENT>{newline}			    { if(semicolon){semicolon = 0; printf("SEMICOLON\n");}; column_counter = 1; line_counter++; }
<BCOMMENT>.			            { column_counter += yyleng;}
<BCOMMENT><<EOF>>               { YY_USER_ACTION; if(semicolon){semicolon = 0; printf("SEMICOLON\n");}; printf("Line %d, column %d: unterminated comment\n", errorLine, errorColumn); BEGIN(INITIAL);}
<BCOMMENT>"*/"		            { column_counter += yyleng; BEGIN(INITIAL); }

"//"				            { BEGIN(LCOMMENT); column_counter += yyleng; }
<LCOMMENT>.			            { column_counter += yyleng;}
<LCOMMENT>\n			       	{ if(semicolon){semicolon = 0; printf("SEMICOLON\n");}; line_counter++; BEGIN(INITIAL); column_counter = 1; }

{ws}                            {column_counter += yyleng;}
{newline}                       {column_counter = 1; line_counter += 1; if(semicolon){semicolon = 0; printf("SEMICOLON\n");};}


\"				                {errorColumn = column_counter; column_counter += yyleng; errorLine = line_counter; BEGIN(BADSTR);}

{INTEGER}                       { {printf("NATURAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}
{OCTAL}                         { {printf("NATURAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}
0[0-9]*                         { fprintf(stdout, "Line %d, column %d: invalid octal constant (%s)\n", line_counter, column_counter, yytext); column_counter += yyleng;}
{HEX}                           { {printf("NATURAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}
{DECIMAL}                       { {printf("DECIMAL(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}
{STRLIT}                        { {printf("STRLIT(%s)\n", yytext);}; semicolon = 1; column_counter += yyleng;}

{RSQ}                           { {printf("RSQ\n");}; semicolon = 1; column_counter += yyleng;}
{LSQ}                           { {printf("LSQ\n");}; semicolon = 0; column_counter += yyleng;}
{BLANKID}                       { {printf("BLANKID\n");}; semicolon = 0; column_counter += yyleng;}
{ASSIGN}			            { {printf("ASSIGN\n");}; semicolon = 0; column_counter += yyleng;}
{STAR}				            { {printf("STAR\n");}; semicolon = 0; column_counter += yyleng;}
{COMMA}				            { {printf("COMMA\n");}; semicolon = 0; column_counter += yyleng;}
{DIV}				            { {printf("DIV\n");}; semicolon = 0; column_counter += yyleng;}
{EQ}				            { {printf("EQ\n");}; semicolon = 0; column_counter += yyleng;}
{GE}				            { {printf("GE\n");}; semicolon = 0; column_counter += yyleng;}
{GT}				            { {printf("GT\n");}; semicolon = 0; column_counter += yyleng;}
{LBRACE}				        { {printf("LBRACE\n");}; semicolon = 0; column_counter += yyleng;}
{LE}				            { {printf("LE\n");}; semicolon = 0; column_counter += yyleng;}
{LPAR}				            { {printf("LPAR\n");}; semicolon = 0; column_counter += yyleng;}
{LT}				            { {printf("LT\n");}; semicolon = 0; column_counter += yyleng;}
{MINUS}				            { {printf("MINUS\n");}; semicolon = 0; column_counter += yyleng;}
{MOD}				            { {printf("MOD\n");}; semicolon = 0; column_counter += yyleng;}
{NE}				            { {printf("NE\n");}; semicolon = 0; column_counter += yyleng;}
{NOT}				            { {printf("NOT\n");}; semicolon = 0; column_counter += yyleng;}
{OR}				            { {printf("OR\n");}; semicolon = 0; column_counter += yyleng;}
{PLUS}				            { {printf("PLUS\n");}; semicolon = 0; column_counter += yyleng;}
{RBRACE}				        { {printf("RBRACE\n");}; semicolon = 1; column_counter += yyleng;}
{RPAR}				            { {printf("RPAR\n");}; semicolon = 1; column_counter += yyleng;}
{SEMICOLON}				        { {printf("SEMICOLON\n");}; semicolon = 0; column_counter += yyleng;}

{CMDARGS}                       { {printf("CMDARGS\n");}; semicolon = 0; column_counter += yyleng;}
{PARSEINT}                      { {printf("PARSEINT\n");}; semicolon = 0; column_counter += yyleng;}
{STRING}                        { {printf("STRING\n");}; semicolon = 0; column_counter += yyleng;}
{BOOL}                          { {printf("BOOL\n");}; semicolon = 0; column_counter += yyleng;}
{FLOAT32}                       { {printf("FLOAT32\n");}; semicolon = 0; column_counter += yyleng;}
{VAR}                           { {printf("VAR\n");}; semicolon = 0; column_counter += yyleng;}
{PACKAGE}                       { {printf("PACKAGE\n");}; semicolon = 0; column_counter += yyleng;}
{FUNC}                          { {printf("FUNC\n");}; semicolon = 0; column_counter += yyleng;}
{AND}				            { {printf("AND\n");}; semicolon = 0; column_counter += yyleng;}
{PRINT}                         { {printf("PRINT\n");}; semicolon = 0; column_counter += yyleng;}



{ELSE}                          { {printf("ELSE\n");}; semicolon = 0; column_counter += yyleng; }
{INT}                           { {printf("INT\n");}; semicolon = 0; column_counter += yyleng; }
{FOR}                           { {printf("FOR\n");}; semicolon = 0; column_counter += yyleng; }
{IF}                            { {printf("IF\n");}; semicolon = 0; column_counter += yyleng; }
{RETURN}                        { {printf("RETURN\n");}; semicolon = 1; column_counter += yyleng;}

{reserved}                      {fprintf(yyout, "RESERVED(%s)\n", yytext); semicolon = 0; column_counter += yyleng;}

{IDENTIFIER}	                { {printf("IDENTIFIER(%s)\n", yytext);} semicolon = 1; column_counter += yyleng; }

.                               { printf("Line %d, column %d: illegal character (%s)\n", line_counter, column_counter, yytext); column_counter += yyleng;}

<BADSTR>\\				        {errorColumn++; fprintf(stdout, "Line %d, column %d: invalid escape sequence (\\)\n", errorLine, errorColumn);}
<BADSTR>\\[fnrt\\\"]	        {errorColumn += 2;}
<BADSTR>\\.				        {errorColumn++; fprintf(stdout, "Line %d, column %d: invalid escape sequence (%s)\n", errorLine, errorColumn++, yytext);}
<BADSTR>\"				        {column_counter = errorColumn + 2; errorColumn = 1; BEGIN 0;}
<BADSTR>{newline}		        {fprintf(stdout, "Line %d, column %d: unterminated string literal\n", errorLine, column_counter - 1); column_counter = 1; line_counter++;BEGIN 0;}
<BADSTR><<EOF>>			        {fprintf(stdout, "Line %d, column %d: unterminated string literal\n", errorLine, column_counter-1); yyterminate();}
<BADSTR>.				        {++errorColumn;}


<INITIAL><<EOF>>	            {if (semicolon) {semicolon = 0; fprintf(yyout, "SEMICOLON\n");} yyterminate();}


%%
extern int yylex();
int main() {
    yylex();    /* run the lexical analysis automaton i*/
    return 0;
}

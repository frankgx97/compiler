%{
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include "Node.h"
using namespace std;
#define YYSTYPE Node*
#include "parser.hpp"

#define LOG

int log(int type,int id){
#ifdef LOG
	const char names[7][10] = {
		"K_WORD  ",
		"SYMBOL  ",
		"ID      ",
		"NUMBER  ",
		"COMMENT ",
		"ERROR   ",
		"SPACES  "
	};
	fprintf(yyout,"%s %s\n",names[type-1],yytext);
#endif
	return id;
}
%}

%option yylineno

letter 	[a-zA-Z]
digit 	[0-9]
ID		(else|if|int|return|void|while)({letter}|{digit})+|{letter}+({letter}|{digit})*
NUM		{digit}+
NO_ID	[^a-zA-Z0-9]
U_LEGAL	([^(a-zA-Z0-9|=|<|>|!|\(|\)|\[|\]|\{|\}|/\*|\*/|,|\.|\+|\-|\*|\/|;|\t|\0|\n|\r|\ )])+

SPACES	(\t|\0|\r|\n|\ )+
COMMENT	\/\*([^\*^\/]*|[\*^\/*]*|[^\**\/]*)*\*\/  

%%

{SPACES}    { /* ignore */ }
{COMMENT}   { /* ignore */ }


{U_LEGAL} { return U_LEGAL; }

else 	{ yylval = new Terminal( K_ELSE		, "else" );		return K_ELSE; }
if 		{ yylval = new Terminal( K_IF		, "if" ); 		return K_IF;}
int 	{ yylval = new Terminal( K_INT		, "int" ); 		return K_INT;}
return 	{ yylval = new Terminal( K_RETURN	, "return" );	return K_RETURN; }
void 	{ yylval = new Terminal( K_VOID		, "void" ); 	return K_VOID;}
while 	{ yylval = new Terminal( K_WHILE	, "while" ); 	return K_WHILE;}
printf	{ yylval = new Terminal( K_PRINTF	, "printf" ); 	return K_PRINTF;}
read	{ yylval = new Terminal( K_READ		, "read" ); 	return K_READ;}

{ID}   { yylval = new Terminal( ID 	, string(yytext) ); return ID; }
{NUM}  { yylval = new Terminal( NUM , string(yytext) ); return NUM; }

=	{ yylval = new Terminal( O_ASSIGN	, "=" ); return O_ASSIGN;}
,	{ yylval = new Terminal( O_COMMA	, "," ); return O_COMMA;}
;	{ yylval = new Terminal( O_SEMI		, ";" ); return O_SEMI;}

\(	{ yylval = new Terminal( O_LSBRACKER	, "(" ); return O_LSBRACKER; }
\)	{ yylval = new Terminal( O_RSBRACKER	, ")" ); return O_RSBRACKER; }
\[	{ yylval = new Terminal( O_LMBRACKER	, "[" ); return O_LMBRACKER; }
\]	{ yylval = new Terminal( O_RMBRACKER	, "]" ); return O_RMBRACKER; }
\{	{ yylval = new Terminal( O_LLBRACKER	, "{" ); return O_LLBRACKER; }
\}	{ yylval = new Terminal( O_RLBRACKER	, "}" ); return O_RLBRACKER; }

\+	{ yylval = new Terminal( O_ADD	, "+" ); return O_ADD; }
\-	{ yylval = new Terminal( O_SUB	, "-" ); return O_SUB; }
\* 	{ yylval = new Terminal( O_MUL	, "*" ); return O_MUL; }
\/	{ yylval = new Terminal( O_DIV	, "/" ); return O_DIV; }

\<	{ yylval = new Terminal( O_LESS		, "<" ); 	return O_LESS;}
\<=	{ yylval = new Terminal( O_L_EQUAL	, "<=" ); 	return O_L_EQUAL;}
>	{ yylval = new Terminal( O_GREATER	, ">" ); 	return O_GREATER;}
>=	{ yylval = new Terminal( O_G_EQUAL	, ">=" ); 	return O_G_EQUAL;}
==	{ yylval = new Terminal( O_EQUAL	, "==" ); 	return O_EQUAL;}
!=	{ yylval = new Terminal( O_U_EQUAL	, "!=" ); 	return O_U_EQUAL;}

%%
int yywrap(){ return 1; }

void yyerror(const char* msg) {
    //sprintf(stderr, "%s\n", msg);
    printf("%s,%s,Line %d", yytext, msg, yylineno);
}
/*
int main(){
	return 0;
}
*/

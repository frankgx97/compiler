%{
#include <stdio.h>
#include <stdlib.h>
#include "symbols.h"

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

letter 	[a-zA-Z]
digit 	[0-9]
ID		(else|if|int|return|void|while)({letter}|{digit})+|{letter}+({letter}|{digit})*
NUM		{digit}+
NO_ID	[^a-zA-Z0-9]
U_LEGAL	([^(a-zA-Z0-9|=|<|>|!|\(|\)|\[|\]|\{|\}|/\*|\*/|,|\.|\+|\-|\*|\/|;|\t|\0|\n|\r|\ )])+

SPACES	(\t|\0|\r|\n|\ )+
COMMENT	\/\*([^\*^\/]*|[\*^\/*]*|[^\**\/]*)*\*\/  

%%

{COMMENT} { return log(CMT,COMMENT); }

{SPACES} {
//	fprintf( yyout, "SPC\n");
	return SPACES;
}

{U_LEGAL} { return log(ERROR,U_LEAGAL); }

else 	{ return log(KEY_WORD,K_ELSE	); }
if 		{ return log(KEY_WORD,K_IF		); }
int 	{ return log(KEY_WORD,K_INT		); }
return 	{ return log(KEY_WORD,K_RETURN	); }
void 	{ return log(KEY_WORD,K_VOID	); }
while 	{ return log(KEY_WORD,K_WHILE	); }

{ID} 	{ return log(ID,ID	); }
{NUM} 	{ return log(NUM,NUM); }

=	{ return log(SYMBOL,O_ASSIGN	); }
,	{ return log(SYMBOL,O_COMMA		); }
;	{ return log(SYMBOL,O_SEMI		); }

\(	{ return log(SYMBOL,O_LSBRACKER); }
\)	{ return log(SYMBOL,O_RSBRACKER); }
\[	{ return log(SYMBOL,O_LMBRACKER); }
\]	{ return log(SYMBOL,O_RMBRACKER); }
\{	{ return log(SYMBOL,O_LLBRACKER); }
\}	{ return log(SYMBOL,O_RLBRACKER); }

\+	{ return log(SYMBOL,O_ADD); }
\-	{ return log(SYMBOL,O_SUB); }
\* 	{ return log(SYMBOL,O_MUL); }
\/	{ return log(SYMBOL,O_DIV); }

\<	{ return log(SYMBOL,O_LESS		); }
\<=	{ return log(SYMBOL,O_L_EQUAL	); }
>	{ return log(SYMBOL,O_GREATER	); }
>=	{ return log(SYMBOL,O_G_EQUAL	); }
==	{ return log(SYMBOL,O_EQUAL		); }
!=	{ return log(SYMBOL,O_U_EQUAL	); }

%%
int yywrap(){ return 1; }

int main(){
	yyin  = fopen( "in.txt",  "r" );
	yyout = fopen( "out.txt", "w" );
	while(yylex());
	return 0;
}

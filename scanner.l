%{
#include <stdio.h>
#include <stdlib.h>
//#include "symbols.h"
#define YYSTYPE char *
#include "y.tab.h"

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

{COMMENT} { return COMMENT; }

{SPACES} {
//	fprintf( yyout, "SPC\n");
	return SPACES;
}

{U_LEGAL} { return U_LEGAL; }

else 	{ return K_ELSE ;}
if 		{ return K_IF	 ;}
int 	{ return K_INT	 ;}
return 	{ return K_RETURN ;}
void 	{ return K_VOID ;}
while 	{ return K_WHILE ;}
printf	{ return K_PRINTF ;}

{ID} 	{ return ID ;}
{NUM} 	{ return NUM ;}

=	{ return O_ASSIGN ;}
,	{ return O_COMMA	 ;}
;	{ return O_SEMI	 ;}

\(	{ return O_LSBRACKER ;}
\)	{ return O_RSBRACKER ;}
\[	{ return O_LMBRACKER ;}
\]	{ return O_RMBRACKER ;}
\{	{ return O_LLBRACKER ;}
\}	{ return O_RLBRACKER ;}

\+	{ return O_ADD ;}
\-	{ return O_SUB ;}
\* 	{ return O_MUL ;}
\/	{ return O_DIV ;}

\<	{ return O_LESS		 ;}
\<=	{ return O_L_EQUAL	 ;}
>	{ return O_GREATER	 ;}
>=	{ return O_G_EQUAL	 ;}
==	{ return O_EQUAL		 ;}
!=	{ return O_U_EQUAL	 ;}

%%
int yywrap(){ return 1; }

void yyerror(const char* msg) {
    //sprintf(stderr, "%s\n", msg);
    printf("%s,Line %d", msg, yylineno);
}
/*
int main(){
	return 0;
}
*/

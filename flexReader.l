%{
#include <stdio.h>
#include <stdlib.h>
#include "symbols.h"

// |(//[^\n\r]*(\n|\r))
%}

letter 	[a-zA-Z]
digit 	[0-9]
ID		{letter}+({letter}|{digit})*
NUM		{digit}+
NO_ID	[^a-zA-Z0-9]
U_LEGAL	([^(a-zA-Z0-9|=|<|>|!|\(|\)|\[|\]|\{|\}|/\*|\*/|,|\.|\+|\-|\*|\/|;|\t|\0|\n|\r|\ )])+

ELSE	"else"
SPACES	(\t|\0|\r|\n|\ )+

COMMENT	\/\*(\s|.)*?\*\/  

%%

{COMMENT} {
	fprintf( yyout, "CMT %s\n",yytext);
	return COMMENT;
}

{SPACES} {
//	fprintf( yyout, "SPC\n");
	return SPACES;
}

{U_LEGAL} {
	fprintf( yyout, "ULL %s\n",yytext);
	return U_LEAGAL;
}

else{NO_ID} {
	yyless(yyleng-1);
	fprintf( yyout, "KEY %d %s\n",K_ELSE,yytext);
	return K_ELSE;
}

if{NO_ID} {
	yyless(yyleng-1);
	fprintf( yyout, "KEY %d %s\n",K_IF,yytext);
	return K_IF;
}
int{NO_ID} {
	yyless(yyleng-1);
	fprintf( yyout, "KEY %d %s\n",K_INT,yytext);
	return K_INT;
}
return{NO_ID} {
	yyless(yyleng-1);
	fprintf( yyout, "KEY %d %s\n",K_RETURN,yytext);
	return K_RETURN;
}
void{NO_ID} {
	yyless(yyleng-1);
	fprintf( yyout, "KEY %d %s\n",K_VOID,yytext);
	return K_VOID;
}
while{NO_ID} {
	yyless(yyleng-1);
	fprintf( yyout, "KEY %d %s\n",K_WHILE,yytext);
	return K_WHILE;
}
{ID} {
	fprintf( yyout, "ID %s\n",yytext);
	return ID;
}

; {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_SEMI;
}

\( {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_LSBRACKER;
}

\) {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_RSBRACKER;
}

\{ {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_LLBRACKER;
}

\} {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_RLBRACKER;
}

\+ {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_ADD;
}

\- {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_SUB;
}

\* {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_MUL;
}

\/	{			//³ýºÅ£¬Çø·Ö×¢ÊÍ 
//	yyless(yyleng-1);
	fprintf( yyout, "SYM %s\n",yytext);
	return O_DIV;
}

= {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_ASSIGN;
}

, {
	fprintf( yyout, "SYM %s\n",yytext);
	return O_COMMA;
}

{NUM} {
	fprintf( yyout, "NUM %d\n",atoi(yytext));
	return NUM;
}


== {
	fprintf( yyout, "SYM %d\n",O_EQUAL);
	return K_ELSE;
}


%%
int yywrap(){ return 1; }

int main(){
	yyin  = fopen( "in.txt",  "r" );
	yyout = fopen( "out.txt", "w" );
	int t;
	while(t=yylex());
	return 0;
}

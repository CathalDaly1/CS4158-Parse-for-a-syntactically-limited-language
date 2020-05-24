%{
	#include <stdlib.h>
	#include <ctype.h>
	#include <string.h>
	#include "y.tab.h"

%}

%option noyywrap
%option caseless
%option yylineno

whitespace	[\n\t ]+
double		(\-?|\+)[0-9]+(\.)[0-9]+
digit		[0-9]+
id 			[A-Za-z][\-a-zA-Z0-9]*
cap 		([X]*)|([X]+\-[X]+)

%%

{whitespace}+              /* Ignore whitespace */ ;
"START"				{ return START; }
"MAIN"				{ return MAIN; }
"END-NOW"			{ return END; }
"PRINT"				{ return PRINT; }
"INPUT"				{ return INPUT; }
"ADD"				{ return ADD; }
"TO"				{ return TO; }
"EQUALS-TO"			{ return EQUALSTO; }
"MOVE"				{return MOVE; }
{cap}				{ yylval.id = yytext; return CAPACITY; }
{id}				{ yylval.id = yytext; return IDENTIFIER; }
\"(\\.|[^\"])*\"	{ return STRING; }
{digit}+"."{digit}* { yylval.dubVal = atof(yytext); return DOUBLE_LITERAL; }
\.					{ return LINE_TERMINATOR; }
;					{ return SEMICOLON; }
%%

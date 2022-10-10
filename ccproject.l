
%option yylineno

%{
#include<stdio.h>
#include<string.h>
#include"y.tab.h"
#include<math.h>
%}
%%

"$".*\n						        {strcpy(yylval.var_name, yytext);return COMMENT;}
"add<stdio.h>"                      {return LIB;}
"{"                                 {return LCB;}
"}"							        {return RCB;}
"\\l"                               {return NL;}
"main<>"					        {return MAIN;}
"int"                               {return INT_FOR_MAIN;}
"void"                              {return VOID;}
"int32"								{yylval.data_type=0; return INT;}
"chr"								{yylval.data_type=1; return CHAR;}
"fp"								{yylval.data_type=2; return FLOAT;}
"dfp"							    {yylval.data_type=3; return DOUBLE;}
"int64"                             {yylval.data_type=4; return LONG;}
"bool"                              {yylval.data_type=5; return BOOL;}
"get"                               {return GET;}
"post"                              {return POST;}
"switch"                            {return SWITCH;}
"default"                           {return DEFAULT;}
"till"                              {return TILL;}
"call"                              {return CALL;}
"elif"							    {return ELSEIF;}
"skip;"                             {return CONTINUE_STMT;}
"while"                             {return WHILE;}
"@"                                 {return AT;}
"if"								{return IF;}
"reach"								{return REACH;}
"=:"                                {return EQ;}
"<<"                                {return LL;}
">>"                                {return GG;}
"<"                                 {return LSB;}
">"                                 {return RSB;}
":"									{return COLON;}
"++"                                {return INC;}
"--"                                {return DEC;}
"for"								{return FOR;}
"stat"                              {return STATIC;}
"option"                            {return OPTION;}
"do"								{return DO;}
"("									{return LB;}
"leave"                             {return BREAKK;}
")"									{return RB;}
";"									{return SC;}
","									{return COMA;}
":="								{return ASSIGNMENT;}
"&"								    {return AND;}
"|"								    {return OR;}
">=:"								{return GEQ;}
"ret 0;"                            {return RETURN_STMT;}
"<=:"								{return LEQ;}
">:"								{return GT;}
"<:"								{return LT;}
"!!=:"								{return NEQ;}
"->"								{return EQ;}
"+"									{return PLUS;}
"-"									{return MINUS;}
"*"									{return MUL;}
"/"									{return DIV;}
"%"									{return MOD;}
"?"                                 {return QM;}
"^"                                 {return POINT;}
"!"									{return NOT;}
\"[^'"]*\"						    {strcpy(yylval.var_name, yytext);return QUOTED_STRING;}
[a-zA-Z]+[0-9]*						{strcpy(yylval.var_name, yytext);return VAR;}
[0-9]+ 								{strcpy(yylval.var_name, yytext);return NUMBER;}
[\n\t ]+							{/*For ignoring spaces and new lines*/}
%%

int yywrap(void) {
return 1;
}



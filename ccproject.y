%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
int yylex(void);
int yyerror(const char *s);
int success = 1;
int current_data_type;
int expn_type = -1;
int temp;
int var_len = 0;
int func_arg=0;
int number_list=0;
int comm_len=0;
int table_pointer = 0;
int is_it_switch=0;
int tabs_needed = 0;
char for_var[30];
int newline=0;
struct symbol_table{char var_name[30]; int type;} sym[20];
extern int lookup_in_table(char var[30]);
extern void insert_to_table(char var[30], int type);
extern void print_tabs();
char var_list[20][30];
char func_name_list[20][30];
char num_list[20][30];
char comm_list[20][30];
int  isitstring[20];
extern int *yytext;
%}
%union{
int data_type;
char var_name[30];
}

%token BREAKK POINT LIB VOID AT LCB RCB INT_FOR_MAIN RETURN_STMT CONTINUE_STMT LSB RSB QM OPTION TILL NL REACH DEFAULT CALL STATIC EQ LL GG INC DEC NUMBER MAIN COLON ASSIGNMENT POST GET SWITCH COMA SEMICOLON VAR LB RB QUOTED_STRING IF ELSE GEQ LEQ GT LT NEQ NOT AND OR GOTO ELSEIF FOR DO PLUS MINUS MUL DIV MOD WHILE COMMENT SC 

%left NEQ EQ
%left AND OR NOT
%left QM 
%left GEQ LEQ GT LT
%left PLUS MINUS
%left MUL DIV MOD
%left INC DEC

%token<data_type>INT
%token<data_type>CHAR
%token<data_type>FLOAT
%token<data_type>DOUBLE
%token<data_type>BOOL 
%token<data_type>LONG

%type<data_type>TYPE
%type<var_name>NUMBER
%type<var_name>VAR

%start go
%%

go:	 			LIB{printf("#include<stdio.h>\n");}  MAIN_STMT LCB STATEMENTS RCB {printf("}\n");}

MAIN_STMT: INT_FOR_MAIN MAIN{printf("int main()\n{\n");tabs_needed++;} 
| VOID MAIN{printf("void main()\n{\n");tabs_needed++;}

STATEMENTS: 		STATEMENTS {print_tabs();} STATEMENT
| ;

STATEMENT: 		VAR_LIST LB TYPE RB SC {  
if(current_data_type == 0)
printf("int ");
else if(current_data_type == 1)
printf("char ");
else if(current_data_type == 2)
printf("float ");
else if(current_data_type == 3)
printf("double ");  
else if(current_data_type == 4)
printf("long int ");  
else if(current_data_type == 5)
printf("bool ");  
for(int i = 0; i <= var_len - 1; i++){
insert_to_table(var_list[i], current_data_type);
if(i==var_len - 1){
printf("%s", var_list[i]);
}	
else{printf("%s,", var_list[i]);}	
}
printf(";\n");
var_len = 0;
}
| ARRAY_LIST LB TYPE RB SC {
    if(current_data_type == 0)
printf("int ");
else if(current_data_type == 1)
printf("char ");
else if(current_data_type == 2)
printf("float ");
else if(current_data_type == 3)
printf("double ");  
else if(current_data_type == 4)
printf("long int ");  
else if(current_data_type == 5)
printf("bool ");  
for(int i = 0; i <= var_len - 1; i++){	
printf("%s", var_list[i]);
}
printf("[");
var_len = 0;
for(int j = 0; j <= number_list - 1; j++){
printf("%s", num_list[j]);
}
number_list=0;
printf("]");
printf(";\n");
}
| POINTERS
| POINTER_ASSIGNMENT
| VAR {
printf("%s", yylval.var_name);
if((temp=lookup_in_table(yylval.var_name))!=-1) {
if(expn_type==-1)
expn_type=temp;
else if(expn_type!=temp) {
printf("\n type mismatch in the expression\n");
yyerror("");
exit(0);
}
}
else {
printf("\n variable \" %s\" undeclared\n", yylval.var_name);
yyerror("");
exit(0);
}
expn_type=-1;
} 
ASSIGNMENT {printf("=");} A_EXPN SC {
printf(";\n");
}
| GET GG READ_VAR_LIST SC {
printf("scanf(\"");
for(int i = 0; i < var_len; i++) {
if((temp=lookup_in_table(var_list[i])) != -1) {
if(temp==0)
printf("%%d");
else if(temp==1)
printf("%%c");
else if(temp==2)
printf("%%f");
else
printf("%%e");
}
else
{
printf("Cannot read undeclared variable %s !", yylval.var_name);
yyerror("");
exit(0);
}
}
printf("\"");
for(int i = 0; i < var_len; i++) {
printf(",&%s", var_list[i]);
}
printf(");\n");
var_len=0;
}
| WRITE_STMT
| IF_BLOCK
| IF_BLOCK ELSEIF_BLOCKS DEFAULT_BLOCK
| WHILE_LOOP
| REACH  {printf("goto ");} VAR {printf("%s", yylval.var_name);} SC {printf(";\n");}
| FUNCTIONS
| FOR_LOOP
| SWITCH_STATEMENTS
| DO_WHILE_LOOP
| FUNCTION_CALL
| CONTINUE_STMT{printf("continue;\n");}
| RETURN_STMT{printf("return 0;\n");}
| COMMENT_LIST {
char *c;
for(int i = 0; i <= comm_len-1; i++) {
c = comm_list[i];
c++;
//c++; Ignores space as well
//c[0] = 0;
//c[strlen(c)-1] = 0;
printf("//");
printf("%s", c);
}

} 
COMMENT_LIST: COMMENT{
    strcpy(comm_list[comm_len], yylval.var_name);
    comm_len++; 
}


WRITE_STMT: POST LL WRITE_VAR_LIST SC {
char *s;
printf("printf(\""); 
for(int i = 0; i <= var_len-1; i++) {
if(isitstring[i] == 1) {
s = var_list[i];
s++;
s[strlen(s)-1] = 0;
printf("%s", s);
if(newline==1){
printf("\\n");
}
}
else {	
if((temp=lookup_in_table(var_list[i])) != -1) {
if(temp==0)
{printf("%%d");}
else if(temp==1)
{printf("%%c");}
else if(temp==2)
{printf("%%f");}
else
{printf("%%e");}

if(newline==1){
    printf("\\n");
    newline=0;
}
}
else
{
printf("Cannot read undeclared variable %s !", yylval.var_name);
yyerror("");
exit(0);
}
}
}
printf("\"");
for(int i = 0; i < var_len; i++) {
if(isitstring[i] != 1)
printf(",%s", var_list[i]);
}
printf(");\n");
var_len = 0;
}


FOR_LOOP: FOR LSB{printf("for(");} VAR {strcpy(for_var, yylval.var_name); printf("%s", for_var);} 
ASSIGNMENT{printf("=");} TERMINALS SC {printf(";");}
A_EXPN SC {printf(";");}
A_EXPN
RSB{printf(")\n");} 
LCB{print_tabs();printf("{\n");tabs_needed++;} STATEMENTS RCB{tabs_needed--;print_tabs();printf("}\n");}


IF_BLOCK:		 	IF LSB {printf("if(");} 
A_EXPN RSB {printf(")\n");print_tabs();printf("{\n");tabs_needed++;} 
LCB STATEMENTS RCB
{tabs_needed--;print_tabs();printf("}\n");}


ELSEIF_BLOCKS:		ELSEIF_BLOCK ELSEIF_BLOCKS
| ;


ELSEIF_BLOCK:		ELSEIF LSB {print_tabs();printf("else if(");}
A_EXPN RSB {printf(")\n");print_tabs();printf("{\n");tabs_needed++;}
LCB STATEMENTS RCB
{tabs_needed--;print_tabs();printf("}\n");}

DEFAULT_BLOCK: 	    DEFAULT {
    print_tabs();
    if(is_it_switch==1){
        printf("default:\n");
    }
    else{printf("else\n");}
} 
COLON LCB STATEMENTS RCB


WHILE_LOOP: TILL{printf("while(");} LSB A_EXPN RSB{printf(")\n");}
DO LCB{print_tabs();printf("{\n");} STATEMENTS RCB{print_tabs();printf("}\n");}

SWITCH_STATEMENTS: OPTION{printf("switch(");is_it_switch=1;} LSB A_EXPN RSB{printf(")\n");}
LCB{print_tabs();printf("{\n");} CASE_STATEMENTS RCB{print_tabs();printf("}\n");} 

CASE_STATEMENTS: CASE_STATEMENT CASE_STATEMENTS
| DEFAULT_BLOCK
| ;

CASE_STATEMENT: VAR{print_tabs();printf("%s",yylval.var_name);} COLON{printf(":\n");} STATEMENTS BREAKK{print_tabs();printf("break");}
SC{printf(";\n");} 


FUNCTIONS: FUNCTION_NAME LSB FUNC_VAR_LIST RSB LB TYPE RB {
    if(current_data_type == 0)
printf("int ");
else if(current_data_type == 1)
printf("char ");
else if(current_data_type == 2)
printf("float ");
else if(current_data_type == 3)
printf("double "); 
else if(current_data_type == 4)
printf("long int ");  
else if(current_data_type == 5)
printf("bool ");   
for(int i = 0; i <= func_arg - 1; i++){	
printf("%s",func_name_list[i]);
}
func_arg=0;

printf("(");
for(int j = 0; j <= var_len - 1; j++){
if(j==(var_len-1)){
printf("%s", var_list[j]);
}	
else{printf("%s,", var_list[j]);}
}
printf(")");
var_len = 0;
printf("\n");
}
LCB{print_tabs();printf("{\n");tabs_needed++;} STATEMENTS RCB{tabs_needed--;print_tabs();printf("}\n");}
| STATIC{printf("static ");} FUNCTIONS


FUNCTION_CALL: CALL FUNCTION_NAME LSB FUNC_VAR_LIST RSB SC{
for(int i = 0; i <= func_arg - 1; i++){	
printf("%s",func_name_list[i]);
}
func_arg=0;

printf("(");
for(int j = 0; j <= var_len - 1; j++){
if(j==(var_len-1)){
printf("%s", var_list[j]);
}	
else{printf("%s,", var_list[j]);}
}
printf(");");
var_len = 0;
printf("\n");
}


POINTERS: POINT POINTER_LIST LB TYPE RB SC{
    if(current_data_type == 0)
printf("int ");
else if(current_data_type == 1)
printf("char ");
else if(current_data_type == 2)
printf("float ");
else if(current_data_type == 3)
printf("double ");  
else if(current_data_type == 4)
printf("long int ");  
else if(current_data_type == 5)
printf("bool ");  
printf("*");
for(int i = 0; i <= var_len - 1; i++){
if(var_len<=1){
printf("%s", var_list[i]);
}	
else{printf("%s,", var_list[i]);}
}
printf(";\n");
var_len = 0;
}

POINTER_ASSIGNMENT: POINTER_LIST{
for(int i = 0; i <= var_len - 1; i++){
printf("%s", var_list[i]);
} 
var_len=0;
}
EQ {printf("=&");} AT VAR{printf("%s",yylval.var_name);} SC{
printf(";\n");
}   
        
DO_WHILE_LOOP: DO{printf("do\n");}
LCB{print_tabs();printf("{\n");tabs_needed++;} STATEMENTS RCB{printf("\n");tabs_needed--;print_tabs();printf("}");} 
 TILL{printf("while(");} 
 LSB A_EXPN RSB{printf(")\n");}


POINTER_LIST: VAR {
strcpy(var_list[var_len], $1); 
var_len++;
}

FUNCTION_NAME: VAR {
strcpy(func_name_list[func_arg], $1); 
func_arg++;
}

VAR_LIST: 			VAR {
strcpy(var_list[var_len], $1); 
var_len++;
} COMA VAR_LIST
| VAR {
strcpy(var_list[var_len], $1); 
var_len++;
} 


FUNC_VAR_LIST: 	VAR {
strcpy(var_list[var_len], $1); 
var_len++;
} COMA VAR_LIST
| VAR {
strcpy(var_list[var_len], $1); 
var_len++;
}


ARRAY_LIST: VAR {
strcpy(var_list[var_len], $1); 
var_len++;
} LCB NUMBER_LIST RCB

NUMBER_LIST: NUMBER {
strcpy(num_list[number_list], $1); 
number_list++;
} 

TYPE : 				INT {
$$=$1;
current_data_type=$1;	
}
| CHAR  {
$$=$1;
current_data_type=$1;
}
| FLOAT {
$$=$1;
current_data_type=$1;
}
| DOUBLE {
$$=$1;
current_data_type=$1; 
}
| LONG{
current_data_type=$1;
}
| BOOL{
current_data_type=$1;
}

WRITE_VAR_LIST:		QUOTED_STRING {
strcpy(var_list[var_len], yylval.var_name); 
isitstring[var_len]=1; 
var_len++;
} LL WRITE_VAR_LIST
| VAR {
strcpy(var_list[var_len], yylval.var_name); 
var_len++;
} COMA WRITE_VAR_LIST
| VAR{
strcpy(var_list[var_len], yylval.var_name);
var_len++;
}
| QUOTED_STRING{
strcpy(var_list[var_len], yylval.var_name);
isitstring[var_len]=1;
var_len++;
}
| VAR {
strcpy(var_list[var_len], yylval.var_name); 
var_len++;
} LL NL{
    newline=1;
    //strcpy(var_list[var_len], "h"); 
    //var_len++    
}
| NL{
    newline=1;
}

READ_VAR_LIST:		VAR {
strcpy(var_list[var_len], yylval.var_name); 
var_len++;
} COMA READ_VAR_LIST
| VAR {
strcpy(var_list[var_len], yylval.var_name); 
var_len++;
}

A_EXPN: 		A_EXPN AND {printf("&&");} A_EXPN
| A_EXPN OR {printf("||");} A_EXPN
| A_EXPN LEQ {printf("<=");} A_EXPN
| A_EXPN GT {printf(">");} A_EXPN
| A_EXPN LT {printf("<");} A_EXPN
| A_EXPN NEQ {printf("!=");} A_EXPN
| A_EXPN EQ {printf("==");} A_EXPN
| NOT {printf("!");} A_EXPN 
| A_EXPN PLUS {printf("+");} A_EXPN
| A_EXPN MINUS {printf("-");} A_EXPN
| A_EXPN MUL {printf("*");} A_EXPN
| A_EXPN DIV {printf("/");} A_EXPN
| A_EXPN INC {printf("++");}
| A_EXPN DEC{printf("--");}
| A_EXPN MOD {printf("%%");} A_EXPN 	
| TERMINALS

TERMINALS:			VAR {
if((temp=lookup_in_table(yylval.var_name))!=-1) {
printf("%s", yylval.var_name);
if(expn_type==-1){
expn_type=temp;
}
else if(expn_type!=temp){
printf("\ntype mismatch in the expression\n");
yyerror("");
exit(0);
}
}
else{
printf("\n variable \"%s\" undeclared\n", yylval.var_name);
yyerror("");
exit(0);
}
}
| NUMBER {printf("%s", yylval.var_name);}


%%

int lookup_in_table(char var[30])
{
for(int i=0; i<table_pointer; i++)
{
if(strcmp(sym[i].var_name, var)==0)
return sym[i].type;
}
return -1;
}

void insert_to_table(char var[30], int type)
{
if(lookup_in_table(var)==-1)
{
strcpy(sym[table_pointer].var_name,var);
sym[table_pointer].type = type;
table_pointer++;
}
else {
printf("Multiple declaration of variable\n");
yyerror("");
exit(0);
}
}

void print_tabs() {
for(int i = 0; i < tabs_needed; i++){
printf("\t");
}
return;
}

int main() {
yyparse();
return 0;
}

int yyerror(const char *msg) {
extern int yylineno;
printf("Parsing failed\nLine number: %d %s\n", yylineno, msg);
success = 0;
return 0;
}


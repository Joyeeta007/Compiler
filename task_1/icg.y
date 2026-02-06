%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int temp_count = 1;
int line_num = 1;

int yylex(void);              // declare lexer
void yyerror(const char *s);  // declare error function

char* new_temp() {
    char* temp = malloc(10);
    sprintf(temp, "t%d", temp_count++);
    return temp;
}

void gen_code(char* result, char* arg1, char* op, char* arg2) {
    if(arg2)
        printf("%d %s = %s %s %s\n", line_num, result, arg1, op, arg2);
    else
        printf("%d %s = %s %s\n", line_num, result, op, arg1);
}
%}

%union {
    char* str;
}

%token <str> ID NUM
%token ASSIGN ADD SUB MUL DIV EXP INTDIV MOD
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN EXP_ASSIGN
%token AND OR NOT
%token LPAREN RPAREN
%token GT LT
%token NEWLINE

%left OR
%left AND
%left NOT
%left GT LT
%left ADD SUB
%left MUL DIV INTDIV MOD
%right EXP
%right UMINUS

%type <str> expression term factor unary primary
%type <str> statement
%type <str> opassign

%%

program: statement_list ;

statement_list: statement
              | statement_list NEWLINE statement ;

statement: ID ASSIGN expression {
                char* temp = new_temp();
                gen_code(temp, $3, "", NULL);
                printf("%d %s = %s\n", line_num, $1, temp);
                free($1); free($3); free(temp);
          }
        | ID opassign expression {
                char* temp1 = new_temp();
                char* temp2 = new_temp();
                char op[3];
                switch(atoi($2)) {
                    case 1: strcpy(op, "+"); break;
                    case 2: strcpy(op, "-"); break;
                    case 3: strcpy(op, "*"); break;
                    case 4: strcpy(op, "/"); break;
                    case 5: strcpy(op, "%"); break;
                    case 6: strcpy(op, "**"); break;
                }
                gen_code(temp1, $1, "", $3);
                gen_code(temp2, $1, op, temp1);
                printf("%d %s = %s\n", line_num, $1, temp2);
                free($1); free($3); free(temp1); free(temp2);
          }
        ;

opassign: ADD_ASSIGN { $$ = "1"; }
        | SUB_ASSIGN { $$ = "2"; }
        | MUL_ASSIGN { $$ = "3"; }
        | DIV_ASSIGN { $$ = "4"; }
        | MOD_ASSIGN { $$ = "5"; }
        | EXP_ASSIGN { $$ = "6"; }
        ;

expression: expression ADD term {
                char* temp = new_temp();
                gen_code(temp, $1, "+", $3);
                $$ = temp;
                free($1); free($3);
          }
        | expression SUB term {
                char* temp = new_temp();
                gen_code(temp, $1, "-", $3);
                $$ = temp;
                free($1); free($3);
          }
        | expression MUL term {
                char* temp = new_temp();
                gen_code(temp, $1, "*", $3);
                $$ = temp;
                free($1); free($3);
          }
        | expression DIV term {
                char* temp = new_temp();
                gen_code(temp, $1, "/", $3);
                $$ = temp;
                free($1); free($3);
          }
        | expression INTDIV term {
                char* temp = new_temp();
                gen_code(temp, $1, "//", $3);
                $$ = temp;
                free($1); free($3);
          }
        | expression MOD term {
                char* temp = new_temp();
                gen_code(temp, $1, "%", $3);
                $$ = temp;
                free($1); free($3);
          }
        | expression EXP term {
                char* temp = new_temp();
                gen_code(temp, $1, "**", $3);
                $$ = temp;
                free($1); free($3);
          }
        | term { $$ = $1; }
        ;

term: factor { $$ = $1; } ;
factor: unary { $$ = $1; } ;
unary: NOT unary {
                char* temp = new_temp();
                gen_code(temp, $2, "!", NULL);
                $$ = temp;
          }
      | SUB unary %prec UMINUS {
                char* temp = new_temp();
                gen_code(temp, $2, "-", NULL);
                $$ = temp;
          }
      | primary { $$ = $1; }
      ;

primary: ID { $$ = strdup($1); }
       | NUM { $$ = strdup($1); }
       | LPAREN expression RPAREN { $$ = $2; }
       ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", line_num, s);
}

int main(int argc, char* argv[]) {
    if(argc < 2) { printf("Usage: %s input.txt\n", argv[0]); return 1; }
    extern FILE* yyin;
    yyin = fopen(argv[1], "r");
    if(!yyin) { perror("fopen"); return 1; }
    yyparse();
    fclose(yyin);
    return 0;
}

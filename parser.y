%{

	#include<stdio.h>
	#include <stdlib.h>
	#include <ctype.h>
	#include <string.h>
	#include <math.h>
	#include <stdbool.h>

	extern int yylex();
	extern int yyparse();
	extern int yylineno;

	void yyerror(const char *msg);
	void trim(char *name);
	void check_identifier(char *name);
	void trim_var_name(char *name);
	void check_size_of_variable(char *name, double passed_size);
	void check_sizes(char *name, char *second_ident);
	void printVar(char *name, char* yytext);

	#define MAX_IDENTIFIERS 100
	char identifiers[MAX_IDENTIFIERS][32]; // 32 characters max
	int sizes[MAX_IDENTIFIERS];

	int number_of_identifiers = 0;

%}

%union {int value; char *id; double dubVal;}
%start start
%token <id> CAPACITY
%token <id> IDENTIFIER
%token <id> STRING
%token <dubVal> DOUBLE_LITERAL
%token START MAIN END PRINT INPUT ADD TO EQUALSTO MOVE
%token SEMICOLON INDENTIFIER LINE_TERMINATOR

%%
start:				START LINE_TERMINATOR declarations {}
					;
declarations:		declaration declarations {}
					| main {}
					;
declaration:		CAPACITY IDENTIFIER LINE_TERMINATOR { printVar($2, $1); }
					| error {}
					;
main:				MAIN LINE_TERMINATOR statements {}
					;
statements:			statement statements {}
					| end {}
					;
statement:			print {}
					| input {}
					| add {}
					| equalsto {}
					| move {}
					| error {}
					;
print:				PRINT print_expression {}
					;
print_expression:	STRING SEMICOLON print_expression {}
					| STRING LINE_TERMINATOR {}
					| IDENTIFIER SEMICOLON print_expression { check_identifier($1); }
					| IDENTIFIER LINE_TERMINATOR { check_identifier($1); }
					;
input:				INPUT input_expression {}
					;
input_expression:	IDENTIFIER LINE_TERMINATOR { check_identifier($1); }
					| IDENTIFIER SEMICOLON input_expression { check_identifier($1); }
					;
add:				ADD DOUBLE_LITERAL TO IDENTIFIER LINE_TERMINATOR { check_identifier($4); check_size_of_variable($4, $2); }
					| ADD IDENTIFIER TO IDENTIFIER LINE_TERMINATOR { check_identifier($2); check_identifier($4); check_sizes($2, $4); }
					;
equalsto:			IDENTIFIER EQUALSTO IDENTIFIER LINE_TERMINATOR { check_identifier($1); check_identifier($3); check_sizes($1, $3); }
					| IDENTIFIER EQUALSTO DOUBLE_LITERAL LINE_TERMINATOR { check_identifier($1); check_size_of_variable($1, $3); }
					;
move:				MOVE DOUBLE_LITERAL TO IDENTIFIER LINE_TERMINATOR { check_identifier($4); check_size_of_variable($4, $2); }
					| MOVE IDENTIFIER TO IDENTIFIER LINE_TERMINATOR { check_identifier($2); check_identifier($4); check_sizes($2, $4); }
					;
end:				END LINE_TERMINATOR { exit(EXIT_SUCCESS); }
					;
%%

int main(int argc, char **argv)
{
	yyparse();
	return 0;
}

void yyerror(const char *msg)
{
	fprintf(stderr, "An error occured on line %d: %s\n", yylineno, msg);
}

void printVar(char *name, char* yytext){

	trim(name); // Remove terminator
	trim_var_name(name); // Remove excess
	strupr(name);
	int lengthOfVar = strlen(name);
	//Get length of capacity(XX-XX) of variable
	int lengthOfName = strlen(yytext)-1;
	int sum = lengthOfName-lengthOfVar;
	bool exists = false;
	//Loop through variable names and check if they have been declared correctly
	//Check if variable name does not exceed 7 chars
	if(lengthOfVar <= 7) {
		for (int i = 0; i < number_of_identifiers && !exists; i++)
		//Check if identifiers have been declared already
			if (strcmp(identifiers[i], name) == 0)
				exists = true;
	}
	else {
		printf("Warning on line %d: Invalid variable length: %s - cannot be greater than 7 \n", yylineno, name);
	}
	// If variable name has already been declared, display error
	if (exists)
		printf("Warning on line %d: %s has already been initialised.\n", yylineno, name);

	strcpy(identifiers[number_of_identifiers], name);
	sizes[number_of_identifiers] = sum;
	number_of_identifiers++;
}

//Remove excess from IDENTIFIER
void trim(char *name)
{
	if (name[strlen(name)-1] == '.')
		name[strlen(name)-1] = 0;
}

void trim_var_name(char *name)
{
	bool stop = false;
	for (int i = 0; i < strlen(name) && !stop; i++)
		if (name[i] == ';' || name[i] == ' ')
		{
			name[i] = '\0';
			stop = true;
		}
}

//Checks if Identifier has been declared if used in the Main Body of the prgram. If not output an error.
void check_identifier(char *name)
{
	trim(name); 
	trim_var_name(name); 
	strupr(name);

	bool exists = false;
	for (int i = 0; i < number_of_identifiers && !exists; i++)
		if (strcmp(identifiers[i], name) == 0)
			exists = true;
	// Output error message if variable doesn't exist
	if (!exists)
		printf("Error on line %d: Identifier %s is not declared.\n", yylineno, name);
}


void check_size_of_variable(char *name, double passed_size)
{
	trim(name); // Remove terminator
	bool found = false;
	bool valid = false;
	//number_of_identifiers is the number of identifiers declared
	//identifiers is the name of the identifiers
	// Passed size is the variable size that is passed
	for (int i = 0; i < number_of_identifiers && !found; i++)
		if (strcmp(identifiers[i], name) == 0)
		{
			found = true;
			if (passed_size <= (sizes[i] * 9))
				valid = true;
		}
	// Output error
	if (!valid)
		printf("Error on line %d: %g is not a valid size for %s.\n", yylineno, passed_size, name);
}

void check_sizes(char *name, char *second_ident)
{
	trim(name); 
	trim_var_name(name);
	strupr(name);
	strupr(second_ident);

	trim(second_ident); 
	trim_var_name(second_ident); 

	bool found = false;
	bool valid = false;

	int ident_one_size = 0;
	int ident_two_size = 0;

	// Size of first identifier
	for (int i = 0; i < number_of_identifiers && !found; i++)
		if (strcmp(identifiers[i], name) == 0)
		{
			found = true;
			ident_one_size = sizes[i] * 9;
		}
	// Size of second identifier
	found = false;
	for (int i = 0; i < number_of_identifiers && !found; i++)
		if (strcmp(identifiers[i], second_ident) == 0)
		{
			found = true;
			ident_two_size = sizes[i] * 9;
		}

	if (ident_one_size <= ident_two_size)
			valid = true;

	// Output error
	if (!valid)
		printf("Error on line %d: %s does not have a valid size for %s.\n", yylineno, name, second_ident);
}

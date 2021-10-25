%{ 
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <string.h>
#include "library.h"
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
int yylex() ;
void yyerror(char * s) ;
typedef struct infos
{
 int typeval;
 char * strval;
}info;

FILE * fisier;

bool in_structure;
bool in_function;

int parametri = 0;
int parametri_functii = 0;

int scope = 0;

variabile * Lista_variabile = NULL;

int Verify_Exists_Variable(char * name)
{
     variabile * start = Lista_variabile;
     while(start != NULL)
     {
          if(strcmp(name,start->nume) == 0)
          {
               printf("Error: variable \"%s\" is redeclared. ChecK line:%d \n",name,yylineno);
               return true;
          }
          start = start->urmatoarea_variabila;
     }
     return false;
}
void AfiseazaVariabilele()
{
     variabile * start = Lista_variabile;
     while(start!= NULL)
     {
          if(start->initializat == true)
               fprintf(fisier ,"Variabila %s Tipul %s Scope-ul %d Valoarea %s\n",start->nume,GetStringType(start->tipul),start->domeniu,start->valoare);
          else
               fprintf(fisier ,"Variabila %s Tipul %s Scope-ul %d Continut: NEINITIALIZAT\n",start->nume,GetStringType(start->tipul),start->domeniu);
          start = start->urmatoarea_variabila;
     }
} 

void Insereaza_variabila(int scope, int type, char * name, char * value, int value_type, bool initialize)
{

     if(Verify_Exists_Variable(name) == true) /* Daca variabila a fost redeclarata */
          exit(ERROR);
     else if(type != value_type && initialize == true && (type-value_type)!=5) 
     {
          printf("Error: the type of variable \"%s\"[%s] is not the same as the assignment content[%s]! ChecK line:%d \n",name,GetStringType(type),GetStringType(value_type),yylineno);
          exit(ERROR);
     }
     else
     {     
          /* Alocam zona de memorie pt noua variabila */
          variabile * var = (variabile*) malloc(sizeof(variabile));
          /* Completez noul obiect */
          var->domeniu = scope;
          var->tipul = type;
          strcpy(var->nume,name);
          var->initializat = initialize;
          if(initialize == true)
              strcpy(var->valoare,value);
          /* Lipesc noul obiect la lista */
          var->urmatoarea_variabila = NULL;
          if(Lista_variabile == NULL)
               Lista_variabile = var;  
          else
          {
               var->urmatoarea_variabila = Lista_variabile;
               Lista_variabile = var;
          }
     }   
}

char elemente[NUMBER_VALUES][NUMBER_VALUES];
int types_elemente[NUMBER_VALUES];
int number_elemente,c;

vector * Lista_Vectori = NULL;

int Verify_Exists_Vector(char * name)
{
     vector * start = Lista_Vectori;
     while(start != NULL)
     {
          if(strcmp(name,start->nume) == 0)
          {
               printf("Error: vector \"%s\" is redeclared. ChecK line:%d \n",name,yylineno);
               return true;
          }
          start = start->urmatorul_vector;
     }
     return false;
}

void AfiseazaVectori()
{
     vector * start = Lista_Vectori;
     while(start!= NULL)
     {
          char answer[300]; bzero(answer,300);
          char number[25];bzero(number,25);
          /* Lipim numele */
          strcat(answer,"Vector: ");
          strcat(answer,start->nume); 
          strcat(answer," ");
          /* Lipim tipul */
          strcat(answer,"Tipul memorat: "); strcat(answer,GetStringType(start->tipul)); strcat(answer," ");
          /* Lipim scope-ul */
          strcat(answer,"Scope: ");bzero(number,25);
          InttoString(start->domeniu,number); strcat(answer,number); strcat(answer," ");
          /* Lipim dimensiunea */
          strcat(answer," Dimensiunea: "); bzero(number,25);
          InttoString(start->dimensiune,number); strcat(answer,number); strcat(answer," ");   
          /* Lipim contentul */
          if(start->initializat == true)
          {    strcat(answer,"Continut:");
               int i;
               for(i = 0; i < start->numar_elemente; i++)
               {
                    strcat(answer," ");    
                    strcat(answer,start->valoare[i]);
                    if(i + 1 != start->numar_elemente)
                         strcat(answer,",");
               }
          }
          else
               strcat(answer,"Continut: NEINITIALIZAT");
          fprintf(fisier,"%s\n",answer);
          start = start->urmatorul_vector;
     }
}



void Insereaza_Vector(int scope, int type, char * name,int size,int number_fields ,char value[NUMBER_VALUES][NUMBER_VALUES], int types_el[NUMBER_VALUES], bool initialized)
{
      if(Verify_Exists_Vector(name) == true) /* Daca vectorul a fost redeclarat */
          exit(ERROR);
     else if(number_fields > size && initialized == true)
     {
          printf("Error: To vector \"%s\" with size[%d] is trying to assing bigger content[%d]! ChecK line:%d \n",name,size,number_fields,yylineno);
          exit(ERROR);
     }
     else
     {
          /* Alocam zona de memorie pt noua variabila */
          vector * var = (vector*) malloc(sizeof(vector));
          /* Completez noul obiect */
          var->domeniu = scope;
          var->tipul = type;
          var->dimensiune = size;
          var->initializat = initialized;
          strcpy(var->nume,name);
          if(initialized == true)
          {
               var->numar_elemente = number_fields;
               var->initializat = true;
               int i;
               for(int i = 0; i < number_fields; i++ )
               {
                    if(type == types_el[i])
                         strcpy(var->valoare[i],value[i]);   
                    else
                    {
                           printf("Error: the type of vector \"%s\"[%s] is not the same as the assignment content[%s]! ChecK line:%d \n",name,GetStringType(type),GetStringType(types_el[i]),yylineno);
                    } 
               }
          }
          var->urmatorul_vector = NULL;
          if(Lista_Vectori == NULL)
               Lista_Vectori = var;  
          else
          {
               var->urmatorul_vector = Lista_Vectori;
               Lista_Vectori = var;
          }
     }   
}

structuri * Lista_Structuri = NULL;

int Verify_Exists_Structure(char * name)
{
     structuri * start = Lista_Structuri;
     while(start != NULL)
     {
          if(strcmp(name,start->nume) == 0)
          {
               printf("Error: Structure \"%s\" is redeclared. ChecK line:%d \n",name,yylineno);
               return true;
          }
          start = start->urmatoarea_structura;
     }
     return false;
}

void Insereaza_structura(int scope, char * name)
{
     
     if(Verify_Exists_Structure(name) == true) /* Daca structura a fost redeclarata */
          exit(ERROR);
     else
     {     
          /* Alocam zona de memorie pt noua variabila */
          structuri* var = (structuri*) malloc(sizeof(structuri));
          /* Completez noul obiect */
          var->domeniu = scope;
          strcpy(var->nume,name);

          /* Lipesc noul obiect la lista */
          var->urmatoarea_structura = NULL;
          if(Lista_Structuri == NULL)
               Lista_Structuri = var;  
          else
          {
               var->urmatoarea_structura = Lista_Structuri;
               Lista_Structuri = var;
          }
     }   
     
}

void Insereaza_parametri_structura(char* name, int type)
{
     structuri * start = Lista_Structuri;
     start->par[parametri].tip_parametru = type;
     strcpy(start->par[parametri].nume_parametru,name);
     parametri++;
}

void AfiseazaStructuri()
{
     structuri * start = Lista_Structuri;
     while(start!= NULL)
     {
          fprintf(fisier,"Structura: %s Scope: %d Numarul de parametri: %d Lista parametriilor: ",start->nume,start->domeniu,start->numar_parametri);
          int i = 0;
          for(i = 0; i < start->numar_parametri; i++)
          {
               fprintf(fisier,"[%s --> %s], ",GetStringType(start->par[i].tip_parametru),start->par[i].nume_parametru);
          }
          fprintf(fisier,"\n");
          start = start->urmatoarea_structura;
     }
}

functii * Lista_Functii = NULL;

void Insereaza_parametri_functii(char* name, int type)
{
     functii * start = Lista_Functii;
     start->par[parametri_functii].tip_parametru = type;
     strcpy(start->par[parametri_functii].nume_parametru,name);
     parametri_functii++;
}

void Insereaza_Functie( char * name,int type, int scope)
{
     /* Alocam zona de memorie pt noua variabila */
     functii * var = (functii*) malloc(sizeof(functii));
     /* Completez noul obiect */
     var->domeniu = scope;
     var->tip_return = type;
     strcpy(var->nume,name);
     /* Lipesc noul obiect la lista */
     var->urmatoarea_functie = NULL;
     if(Lista_Functii == NULL)
          Lista_Functii = var;  
     else
     {
          var->urmatoarea_functie = Lista_Functii;
          Lista_Functii = var;
     }
}

void AfiseazaFunctii()
{
     functii * start = Lista_Functii;
     while(start!= NULL)
     {
          fprintf(fisier,"Functia: %s Tipul return:%s Scope: %d Numarul de parametri: %d Lista parametriilor: ",start->nume,GetStringType(start->tip_return),start->domeniu,start->numar_parametri);
          int i = 0;
          for(i = 0; i < start->numar_parametri; i++)
          {
               fprintf(fisier,"[%s --> %s], ",GetStringType(start->par[i].tip_parametru),start->par[i].nume_parametru);
          }
          fprintf(fisier,"\n");
          start = start->urmatoarea_functie;
     }
}

void Verificare_semnatura()
{
     functii * cautat = Lista_Functii; functii * start = cautat->urmatoarea_functie;
     while( start != NULL )
     {
          
          if(strcmp(cautat->nume,start->nume) == 0) /* Functiile au acelasi nume */
               if( cautat->tip_return == start->tip_return ) /* Functiile au acelasi tip de return */
                    if( cautat->numar_parametri == start->numar_parametri ) /* Functiile au acelasi numar de parametri */
                    { /* verificam daca toti acesti parametri au acelasi tip */
                         bool indentic = true;
                         int i;
                         for(i = 0; i < cautat->numar_parametri; i++)
                              if(cautat->par[i].tip_parametru != start->par[i].tip_parametru)
                                   indentic = false;
                         if(indentic == true)
                         {      
                              printf("Error: Function \"%s\" is redeclared with identic signature. ChecK line:%d \n",cautat->nume,yylineno);
                              exit(ERROR);
                         }
                    }
          start = start->urmatoarea_functie;
     }
}

int Gaseste_tipul_prin_Nume(char * name,int scope)
{
     /* Incercam sa gasim acea variabila in scope-ul curent */
     variabile * start = Lista_variabile;
     while(start != NULL)
     {
          if( start->domeniu == scope)
               if(strcmp(name,start->nume) == 0)
               {
                    return start->tipul;
               }
          start = start->urmatoarea_variabila;
     }
     /* Daca nu gasim, incercam sa gasim in scopeul global */
     start = Lista_variabile;
     while(start != NULL)
     {
          if(strcmp(name,start->nume) == 0 && start->domeniu == 0) 
          {
               return start->tipul;
          }
          start = start->urmatoarea_variabila;
     }
     printf("Error: variable \"%s\" was not found in the current enviorment! Check line %d!",name,yylineno);
     exit(ERROR);
}

char * Gaseste_valoarea_prin_Nume(char * name, int scope, bool assignment)
{
     /* Incercam sa gasim acea variabila in scope-ul curent */
     variabile * start = Lista_variabile;
     while(start != NULL)
     {
          if( start->domeniu == scope)
          {
               if(strcmp(name,start->nume) == 0 && start->initializat == false)
               {
                    if(assignment == true)
                         return start->valoare;
                    else
                    {    
                         printf("Error: Variable \"%s\" was found but is not initialized! Check line %d!\n",name,yylineno);
                         exit(ERROR);
                    }
               }
               else if(strcmp(name,start->nume) == 0 && start->initializat == true)
               {
                    return start->valoare;
               }
          }
          start = start->urmatoarea_variabila;
     }
     /* Daca nu gasim, incercam sa gasim in scope-ul global */
     start = Lista_variabile;
     while(start != NULL)
     {
          if(strcmp(name,start->nume) == 0 && start->domeniu == 0 && start->initializat == false) 
          {
               if(assignment == true)
               {    start->initializat = true;     return start->valoare; }
               else
               {    printf("Error: Variable \"%s\" was found but is not initialized! Check line %d!\n",name,yylineno);
                    exit(ERROR);
               }
          }
          else if(strcmp(name,start->nume) == 0 && start->domeniu == 0 && start->initializat == true) 
          {
               return start->valoare;
          }
          start = start->urmatoarea_variabila;
     }
     printf("Error: variable \"%s\" was not found in the current enviorment! Check line %d!",name,yylineno);
     exit(ERROR);
}

int Gaseste_tipul_prin_Nume_Array(char * name, int scope)
{
     /* Incercam sa gasim acel vector in scope-ul curent */
     vector * start = Lista_Vectori;
     while(start != NULL)
     {
          if( start->domeniu == scope)
               if(strcmp(name,start->nume) == 0)
               {
                    return start->tipul;
               }
          start = start->urmatorul_vector;
     }
     /* Daca nu gasim, incercam sa gasim in scopeul global */
     start = Lista_Vectori;
     while(start != NULL)
     {
          if(strcmp(name,start->nume) == 0 && start->domeniu == 0) 
          {
               return start->tipul;
          }
          start = start->urmatorul_vector;
     }
     printf("Error: vector \"%s\" was not found in the current enviorment! Check line %d!",name,yylineno);
     exit(ERROR);
}

char * Gaseste_valoarea_prin_Nume_Array(char * name,int scope,int index)
{
     /* Incercam sa gasim acea variabila in scope-ul curent */
     vector * start = Lista_Vectori;
     while(start != NULL)
     {
          
          if( start->domeniu == scope)
          {

               if(strcmp(name,start->nume) == 0 && start->initializat == false)
               {
                    printf("Error: Vector \"%s\" was found but is not initialized! Check line %d!\n",name,yylineno);
                    exit(ERROR);
               }
               else if(strcmp(name,start->nume) == 0 && start->initializat == true)
               {

                    if(index > start->numar_elemente)
                    {
                         printf("Error: Assignment using Vector \"%s\" initialization size is smaller than the index offered! Check line %d!\n",name,yylineno);
                         exit(ERROR);
                    }
                    else
                    {
                         int i = 0;

                         for(i = 0; i < start->numar_elemente; i++)
                         {
                              
                              if(index-1 == i)
                                   return start->valoare[i];
                         }
                    }
               }
          }
          start = start->urmatorul_vector;
     }
     /* Daca nu gasim, incercam sa gasim in scope-ul global */
     start = Lista_Vectori;
     while(start != NULL)
     {
          if( start->domeniu == 0)
          {
               if(strcmp(name,start->nume) == 0 && start->initializat == false)
               {
                    printf("Error: Vector \"%s\" was found but is not initialized! Check line %d!\n",name,yylineno);
                    exit(ERROR);
               }
               else if(strcmp(name,start->nume) == 0 && start->initializat == true)
               {
                    if(index > start->numar_elemente)
                    {
                         printf("Error: Vector \"%s\" initialization size is smaller than the index offered! Check line %d!\n",name,yylineno);
                         exit(ERROR);
                    }
                    else
                    {
                         int i = 0;
                         for(i = 0; i < start->numar_elemente; i++)
                         {
                              if(index-1 == i)
                                   return start->valoare[i];
                         }
                    }
               }
          }
          start = start->urmatorul_vector;
     }
     printf("Error: Vector \"%s\" was not found in the current enviorment! Check line %d!",name,yylineno);
     exit(ERROR);
}

structuri * Gaseste_structura(char * name)
{
     structuri * start = Lista_Structuri;
     while(start!= NULL)
     {
          if(strcmp(start->nume,name) == 0)
               return start;
          start = start->urmatoarea_structura;
     }
     printf("Error: structure \"%s\" was not found! Check line %d\n",name,yylineno);
     exit(ERROR);
}

variabile * Gaseste_variabila(char * name, int scope)
{
     /* Incercam sa gasim acea variabila in scope-ul curent */
     variabile * start = Lista_variabile;
     while(start != NULL)
     {
          if( start->domeniu == scope)
               if(strcmp(name,start->nume) == 0 )
                    return start;
          start = start->urmatoarea_variabila;
     }
     /* Daca nu gasim, incercam sa gasim in scope-ul global */
     start = Lista_variabile;
     while(start != NULL)
     {
          if(strcmp(name,start->nume) == 0 && start->domeniu == 0 ) 
               return start;
          start = start->urmatoarea_variabila;
     }
     printf("Error: variable \"%s\" was not found in the current enviorment! Check line %d!",name,yylineno);
     exit(ERROR);
}

bool Gaseste_variabila_in_structura(char * name, structuri * place)
{
     int i;
     for(int i = 0; i< place->numar_parametri; i++)
     {   
          if(strcmp(place->par[i].nume_parametru,name)== 0)
               return true;
     }
     return false;
}

int Gaseste_tipul_prin_Nume_Functie(char * name)
{
     functii * start = Lista_Functii;
     while(start != NULL)
     {
          if(strcmp(name,start->nume) == 0)
               return start->tip_return;
          start = start->urmatoarea_functie;
     }
     exit(ERROR);
}

void gaseste_functia( char * name )
{    
     bool gasit = false;
     functii * start = Lista_Functii;
     while(start!= NULL)
     {
          if(strcmp(start->nume,name) == 0)
          {
               gasit = true;
               break;
          }
          start = start->urmatoarea_functie;
     }
     if(gasit == false)
     {
          printf("Error: No function with name \"%s\" found. Check line: %d!\n",name,yylineno);
          exit(ERROR);
     }
}


functii * Obtine_functie_urmatoare_nume(char * name, functii * start)
{
     while(start!=NULL)
     {
          if(strcmp(name,start->nume) == 0)
               return start;
          start = start->urmatoarea_functie;
     }
     return start;
}

int parametri_apel = 0;
int par_type[NUMBER_VALUES];

%}
%union {
int typeval;
char* strval;
info* val;
struct expr_info* expr_ptr;
struct arg_info* arg_ptr;
}

%token <typeval>TYP_BOOL TYP_INT TYP_FLOAT TYP_CHAR TYP_STRING TYP_CONST_BOOL TYP_CONST_INT TYP_CONST_FLOAT TYP_CONST_CHAR TYP_CONST_STRING ARRAY
%token <strval> IDENTIFIER 
%token <val>INT_VALUE FLOAT_VALUE CHAR_VALUE STRING_VALUE BOOL_VALUE
%token FOR WHILE BREAK CONTINUE IF ELSE ASSIGN RETURN FUNCTION CALL_FUNCTION COMMA SEMICOLON PLUS_PLUS STRUCT_OBJECT
%token MULTIPLY_MULTIPLY PLUS MULTIPLY MINUS DIVIDE NOT EQUAL AND OR LESS BIGGER LEFT_BRACE RIGHT_BRACE LEFT_ROUND_BRACKETS
%token RIGHT_ROUND_BRACKETS LEFT_SQUARE_BRACKETS RIGHT_SQUARE_BRACKETS BEGN END TYP_STRUCT CONST_TYP STRUCT 
%token THAN EVAL DOT TYP_ARRAY 
%start progr
%type<typeval> TYP
%type<val> expression list_expression value

%%

progr: full_declaratii bloc {printf("Programul respecta sintaxa\n");}
     | bloc {printf("Programul respecta sintaxa\n");}
     ; 

TYP :  TYP_BOOL 
    {
         $$ = $1;
    }
    |  TYP_INT
    {
         $$ = $1;
    }
    |  TYP_FLOAT 
    {
         $$ = $1;
    }
    |  TYP_CHAR 
    {
         $$ = $1;
    }
    |  TYP_STRING
    {
         $$ = $1;
    }
    |  TYP_CONST_BOOL 
    {
         $$ = $1;
    }
    |  TYP_CONST_INT
    {
         $$ = $1;
    }  
    |  TYP_CONST_FLOAT
    {
         $$ = $1;
    } 
    |  TYP_CONST_CHAR 
    {
         $$ = $1;
    }
    |  TYP_CONST_STRING 
    {
         $$ = $1;
    }
    ;

full_declaratii : declaratie SEMICOLON
                | declaratie_functie SEMICOLON
                | declaratie_structura SEMICOLON
                | full_declaratii declaratie SEMICOLON
                | full_declaratii declaratie_structura SEMICOLON
                | full_declaratii declaratie_functie SEMICOLON
                ;

declaratie_functie : FUNCTION TYP IDENTIFIER { in_function = true; if(in_structure == false) scope++; Insereaza_Functie($3,$2,scope); } LEFT_ROUND_BRACKETS lista_param { Lista_Functii->numar_parametri = parametri_functii; parametri_functii = 0; Verificare_semnatura(); } RIGHT_ROUND_BRACKETS  LEFT_BRACE list {in_function = false;} RIGHT_BRACE 
                   ;

declaratie_structura : STRUCT IDENTIFIER { scope++; Insereaza_structura(scope,$2); } LEFT_BRACE { in_structure = true; } full_declaratii { Lista_Structuri->numar_parametri = parametri; in_structure = false; parametri = 0; in_structure = false; } RIGHT_BRACE
                     ;


declaratie : TYP IDENTIFIER ASSIGN expression
           {
               if(in_structure == true)
               {    
                    Insereaza_variabila(scope,$1,$2,$4->strval,$4->typeval,true); 
                    Insereaza_parametri_structura($2,$1); 
               }
               else if( in_function == true)
               {
                    Insereaza_variabila(scope,$1,$2,$4->strval,$4->typeval,true);
               }
               else
                    Insereaza_variabila(GLOBAL_SCOPE,$1,$2,$4->strval,$4->typeval,true);

           }
           | TYP IDENTIFIER 
           {
               if(in_structure == true)
               {    
                    Insereaza_variabila(scope,$1,$2,"",0,false);
                    Insereaza_parametri_structura($2,$1); 
               }
               else if( in_function == true)
               {
                    Insereaza_variabila(scope,$1,$2,"",0,false);
               }
               else
                    Insereaza_variabila(GLOBAL_SCOPE,$1,$2,"",0,false);
           }
           | ARRAY LESS TYP BIGGER IDENTIFIER LEFT_SQUARE_BRACKETS INT_VALUE RIGHT_SQUARE_BRACKETS ASSIGN LEFT_BRACE list_expression RIGHT_BRACE 
           {
               int nr = atoi($7->strval);
               Insereaza_Vector(scope, $3, $5 , nr , number_elemente , elemente , types_elemente, true);
               number_elemente = 0;
           }
           | ARRAY LESS TYP BIGGER IDENTIFIER LEFT_SQUARE_BRACKETS INT_VALUE RIGHT_SQUARE_BRACKETS 
           {
               int nr = atoi($7->strval);
               Insereaza_Vector(scope, $3, $5 , nr , 0, 0 , NULL, false);
           }
           ;

lista_param : 
            | TYP IDENTIFIER { Insereaza_parametri_functii($2, $1); }
            | lista_param COMMA TYP IDENTIFIER { Insereaza_parametri_functii($4, $3); }
            ;
            
      
bloc : BEGN {scope++; in_function = true;} list END  
     ;
     


list_expression : 
                {
                    c++;
                }
                | expression 
                {
                    strcpy(elemente[number_elemente],$1->strval);
                    types_elemente[number_elemente] = $1->typeval; 
                    number_elemente ++;
                }
                | list_expression COMMA expression
                {
                    strcpy(elemente[number_elemente],$3->strval);
                    types_elemente[number_elemente] = $3->typeval; 
                    number_elemente ++;
                }
                ;

expression : value
           {
               $$ = $1;
           }
           | IDENTIFIER LEFT_SQUARE_BRACKETS INT_VALUE RIGHT_SQUARE_BRACKETS 
           {
               info * value = (info *)malloc(sizeof(info));
               
               value->typeval = Gaseste_tipul_prin_Nume_Array($1,scope);
               int nr = atoi($3->strval);
               value->strval = Gaseste_valoarea_prin_Nume_Array($1,scope,nr);
               $$ = value;
           }
           | IDENTIFIER
           {
               info * value = (info *)malloc(sizeof(info));
               value->typeval = Gaseste_tipul_prin_Nume($1,scope);
               if(value->typeval >= 5) value->typeval = value->typeval - 5;
               value->strval = Gaseste_valoarea_prin_Nume($1,scope,false);
               $$ = value;
           }
           | LEFT_ROUND_BRACKETS expression PLUS expression RIGHT_ROUND_BRACKETS
           {	
	          info * value = (info *)malloc(sizeof(info));
	          int int1,int2;
	          float float1,float2;
	          char char1,char2;
	          char rezultat[30];
	          if(probl_expresion($2->typeval,$4->typeval)==true)
	          {
		          if($2->typeval==0)
		          {
			          int1 = atoi($2->strval);
		               int2 = atoi($4->strval);
			          value->typeval = $2->typeval;
                         sprintf(rezultat,"%d",int1+int2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==1)
		          {
			          float1 = atof($2->strval);
		               float2 = atof($4->strval);
			          value->typeval = $2->typeval;
		               sprintf(rezultat,"%g",float1 + float2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==5)
		          {
			          int1 = atoi($2->strval);
		               int2 = atoi($4->strval);
			          value->typeval = $2->typeval;
			          sprintf(rezultat,"%d",int1 + int2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          if($2->typeval==6)
		          {
			          float1 = atof($2->strval);
		               float2 = atof($4->strval);
			          value->typeval = $2->typeval;
		               sprintf(rezultat,"%g",float1 + float2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          if($2->typeval==2)
		          {
			          printf("Error:Cannot do this operation on bool types!Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          if($2->typeval==3)
		          {
			          printf("Error:Cannot do this operation on char types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          if($2->typeval==4)
		          {
			          printf("Error:Cannot do this operation on string types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          if($2->typeval==7)
		          {
			          printf("Error:Cannot do this operation on const bool types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          if($2->typeval==8)
		          {
			          printf("Error:Cannot do this operation on const char types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          if($2->typeval==9)
		          {
			          printf("Error:Cannot do this operation on const string types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }			
	          }
	          else
	          {
		          printf("Error:Cannot add different types!Check line %d!\n",yylineno);
		          exit(ERROR);
	          }			
           }
           | LEFT_ROUND_BRACKETS expression MINUS expression RIGHT_ROUND_BRACKETS  
           {	
	          info * value = (info *)malloc(sizeof(info));
	          int int1,int2;
	          float float1,float2;
	          char char1,char2;
	          char rezultat[30];
	          if(probl_expresion($2->typeval,$4->typeval)==true)
	          {
		          if($2->typeval==0)
		          {
			          int1 = atoi($2->strval);
		               int2 = atoi($4->strval);
			          value->typeval = $2->typeval;
                         sprintf(rezultat,"%d",int1-int2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==1)
		          {
			          float1 = atof($2->strval);
		               float2 = atof($4->strval);
			          value->typeval = $2->typeval;
		               sprintf(rezultat,"%g",float1 - float2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==5)
		          {
			          int1 = atoi($2->strval);
		               int2 = atoi($4->strval);
			          value->typeval = $2->typeval;
			          sprintf(rezultat,"%d",int1 - int2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          if($2->typeval==6)
		          {
			          float1 = atof($2->strval);
		               float2 = atof($4->strval);
			          value->typeval = $2->typeval;
		               sprintf(rezultat,"%g",float1 - float2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==2)
		          {
			          printf("Error:Cannot do this operation on bool types!Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==3)
		          {
			          printf("Error:Cannot do this operation on char types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==4)
		          {
			          printf("Error:Cannot do this operation on string types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==7)
		          {
			          printf("Error:Cannot do this operation on const bool types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==8)
		          {
			          printf("Error:Cannot do this operation on const char types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==9)
		          {
			          printf("Error:Cannot do this operation on const string types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }			
	          }
	          else
	          {
		          printf("Error:Cannot substract different types!Check line %d!\n",yylineno);
		          exit(ERROR);
	          }			
           }
           | LEFT_ROUND_BRACKETS expression MULTIPLY expression RIGHT_ROUND_BRACKETS
           {	
	          info * value = (info *)malloc(sizeof(info));
	          int int1,int2;
	          float float1,float2;
	          char char1,char2;
	          char rezultat[30];
	          if(probl_expresion($2->typeval,$4->typeval)==true)
	          {
		          if($2->typeval==0)
		          {
			          int1 = atoi($2->strval);
		               int2 = atoi($4->strval);
			          value->typeval = $2->typeval;
                         sprintf(rezultat,"%d",int1*int2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==1)
		          {
			          float1 = atof($2->strval);
		               float2 = atof($4->strval);
			          value->typeval = $2->typeval;
		               sprintf(rezultat,"%g",float1 * float2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==5)
		          {
			          int1 = atoi($2->strval);
		               int2 = atoi($4->strval);
			          value->typeval = $2->typeval;
			          sprintf(rezultat,"%d",int1 * int2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          if($2->typeval==6)
		          {
			          float1 = atof($2->strval);
		               float2 = atof($4->strval);
			          value->typeval = $2->typeval;
		               sprintf(rezultat,"%g",float1 * float2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==2)
		          {
			          printf("Error:Cannot do this operation on bool types!Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==3)
		          {
			          printf("Error:Cannot do this operation on char types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==4)
		          {
			          printf("Error:Cannot do this operation on string types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==7)
		          {
			          printf("Error:Cannot do this operation on const bool types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==8)
		          {
			          printf("Error:Cannot do this operation on const char types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==9)
		          {
			          printf("Error:Cannot do this operation on const string types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }			
	          }
	          else
	          {
		          printf("Error:Cannot multiply different types!Check line %d!\n",yylineno);
		          exit(ERROR);
	          }			
           }
           | LEFT_ROUND_BRACKETS expression DIVIDE expression RIGHT_ROUND_BRACKETS
           {	
	          info * value = (info *)malloc(sizeof(info));
	          int int1,int2;
	          float float1,float2;
	          char char1,char2;
	          char rezultat[30];
	          if(probl_expresion($2->typeval,$4->typeval)==true)
	          {
		          if($2->typeval==0)
		          {
			          int1 = atoi($2->strval);
		               int2 = atoi($4->strval);
			          value->typeval = $2->typeval;
                         if(int2 == 0)
                         {
                              printf("Error:Cannot divide by 0! Check line %d!\n",yylineno);
		                    exit(ERROR);
                         }     
                         sprintf(rezultat,"%d",int1/int2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==1)
		          {
			          float1 = atof($2->strval);
		               float2 = atof($4->strval);
			          value->typeval = $2->typeval;
                         if(float2 == 0.0)
                         {
                              printf("Error:Cannot divide by 0! Check line %d!\n",yylineno);
		                    exit(ERROR);
                         }     
		               sprintf(rezultat,"%g",float1 + float2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==5)
		          {
			          int1 = atoi($2->strval);
		               int2 = atoi($4->strval);
			          value->typeval = $2->typeval;
                         if(float2 == 0)
                         {
                              printf("Error:Cannot divide by 0! Check line %d!\n",yylineno);
		                    exit(ERROR);
                         }  
			          sprintf(rezultat,"%d",int1 + int2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==6)
		          {
			          float1 = atof($2->strval);
		               float2 = atof($4->strval);
			          value->typeval = $2->typeval;
                         if(float2 == 0.0)
                         {
                              printf("Error:Cannot divide by 0! Check line %d!\n",yylineno);
		                    exit(ERROR);
                         }  
		               sprintf(rezultat,"%g",float1 + float2);
			          value->strval = rezultat;
			          $$=value;
		          }
		          else if($2->typeval==2)
		          {
			          printf("Error:Cannot do this operation on bool types!Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==3)
		          {
			          printf("Error:Cannot do this operation on char types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==4)
		          {
			          printf("Error:Cannot do this operation on string types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==7)
		          {
			          printf("Error:Cannot do this operation on const bool types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==8)
		          {
			          printf("Error:Cannot do this operation on const char types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }
		          else if($2->typeval==9)
		          {
			          printf("Error:Cannot do this operation on const string types !Check line %d!\n",yylineno);
			          exit(ERROR);
		          }			
	          }
	          else
	          {
		          printf("Error:Cannot divide different types!Check line %d!\n",yylineno);
		          exit(ERROR);
	          }			
           }
           | LEFT_ROUND_BRACKETS expression LESS expression RIGHT_ROUND_BRACKETS
           {
			int int1,int2;
			float float1,float2;
			int care=0 ;
			info * value = (info *)malloc(sizeof(info));
			if(verif_expresii($2->typeval,$4->typeval)==true)	
			{	
				
				if($2->typeval==0)
				{
					int1 = atoi($2->strval);
		      			care=1;
				}	
				else if($2->typeval==1)
				{
					float1 = atof($2->strval);
					care=2;

				}
				else if($2->typeval==5)
				{
					int1 = atoi($2->strval);
					care=5;

				}
				else if($2->typeval==6)
				{
					float1 = atof($2->strval);
					care=6;

				}
				if($4->typeval==0)
				{
					care=care*10+1;
					int2 = atoi($4->strval);
					
				}
				else if($4->typeval==1)
				{
					care=care*10+2;
					float2 = atof($4->strval);

				}
				else if($4->typeval==5)
				{
					care=care*10+5;
					int2 = atoi($4->strval);

				}
				else if($4->typeval==6)
				{
					care=care*10+6;
					float2 = atof($4->strval);

				}
				if(care==11 || care==15 || care==51 || care==55)
				{
					value->typeval=2;
					if(int1 < int2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                        		 value->strval=exemplu;
					}
						
				}
				else if(care==12 || care==16 || care==52 || care==56)
				{
					value->typeval=2;
					if(int1 < float2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                        		 value->strval=exemplu;
					}
				}
				else if(care==21 || care==25 || care==61 || care==65)
				{
					value->typeval=2;
					if(float1 < int2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                        		 value->strval=exemplu;
					}
				}
				else if(care==22 || care==26 || care==62 || care==66 )
				{
					value->typeval=2;
					if(float1 < float2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                        		 value->strval=exemplu;
					}
				}
				
				$$=value;
			}
			else
			{
				printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
				exit(ERROR);

			}

		 }
           | LEFT_ROUND_BRACKETS expression BIGGER expression RIGHT_ROUND_BRACKETS
           {
			int int1,int2;
			float float1,float2;
			int care=0 ;
			info * value = (info *)malloc(sizeof(info));
			if(verif_expresii($2->typeval,$4->typeval)==true)	
			{	
				
				if($2->typeval==0)
				{
					int1 = atoi($2->strval);
		      			care=1;
				}	
				else if($2->typeval==1)
				{
					float1 = atof($2->strval);
					care=2;

				}
				else if($2->typeval==5)
				{
					int1 = atoi($2->strval);
					care=5;

				}
				else if($2->typeval==6)
				{
					float1 = atof($2->strval);
					care=6;

				}
				if($4->typeval==0)
				{
					care=care*10+1;
					int2 = atoi($4->strval);
					
				}
				else if($4->typeval==1)
				{
					care=care*10+2;
					float2 = atof($4->strval);

				}
				else if($4->typeval==5)
				{
					care=care*10+5;
					int2 = atoi($4->strval);

				}
				else if($4->typeval==6)
				{
					care=care*10+6;
					float2 = atof($4->strval);

				}
				if(care==11 || care==15 || care==51 || care==55)
				{
					value->typeval=2;
					if(int1 > int2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                        		 value->strval=exemplu;
					}
						
				}
				else if(care==12 || care==16 || care==52 || care==56)
				{
					value->typeval=2;
					if(int1 > float2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                        		 value->strval=exemplu;
					}
				}
				else if(care==21 || care==25 || care==61 || care==65)
				{
					value->typeval=2;
					if(float1 > int2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                        		 value->strval=exemplu;
					}
				}
				else if(care==22 || care==26 || care==62 || care==66 )
				{
					value->typeval=2;
					if(float1 > float2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                        		 value->strval=exemplu;
					}
				}
				
				$$=value;
			}
			else
			{
				printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
				exit(ERROR);

			}

		 }
           | LEFT_ROUND_BRACKETS expression EQUAL expression RIGHT_ROUND_BRACKETS
           {
			int int1,int2;
			float float1,float2;
			int care=0 ;
			info * value = (info *)malloc(sizeof(info));
			if(verif_expresii($2->typeval,$4->typeval)==true)	
			{	
				
				if($2->typeval==0)
				{
					int1 = atoi($2->strval);
		      			care=1;
				}	
				else if($2->typeval==1)
				{
					float1 = atof($2->strval);
					care=2;

				}
				else if($2->typeval==5)
				{
					int1 = atoi($2->strval);
					care=5;

				}
				else if($2->typeval==6)
				{
					float1 = atof($2->strval);
					care=6;

				}
				if($4->typeval==0)
				{
					care=care*10+1;
					int2 = atoi($4->strval);
					
				}
				else if($4->typeval==1)
				{
					care=care*10+2;
					float2 = atof($4->strval);

				}
				else if($4->typeval==5)
				{
					care=care*10+5;
					int2 = atoi($4->strval);

				}
				else if($4->typeval==6)
				{
					care=care*10+6;
					float2 = atof($4->strval);

				}
				if(care==11 || care==15 || care==51 || care==55)
				{
					value->typeval=2;
					if(int1 == int2)
					{
						char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
						char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                         		value->strval=exemplu;
					}
						
				}
				else if(care==12 || care==16 || care==52 || care==56)
				{
					value->typeval=2;
					if(int1 == float2)
					{
						char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
						char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                         		value->strval=exemplu;
					}
				}
				else if(care==21 || care==25 || care==61 || care==65)
				{
					value->typeval=2;
					if(float1 == int2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;	
					}
					else
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                         		value->strval=exemplu;
					}
				}
				else if(care==22 || care==26 || care==62 || care==66 )
				{
					value->typeval=2;
					if(float1 == float2)
					{
					char * exemplu = malloc(6);
                         		strcpy(exemplu,"true");
                        		 value->strval=exemplu;
					}
					else
					{
						char * exemplu = malloc(6);
                         		strcpy(exemplu,"false");
                         		value->strval=exemplu;
					}
				}
				
				$$=value;
			}
			else
			{
				printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
				exit(ERROR);

			}

		 }
           | NOT expression
           {
               info * value = (info *)malloc(sizeof(info));            
               if($2->typeval==2)
               {
                    
                    value->typeval=2;
                    if(strcmp($2->strval,"true")==0)
                    {
                       char * exemplu = malloc(6);
                         strcpy(exemplu,"false");
                         value->strval=exemplu;
                    }
                    else
                    {
                       char * exemplu = malloc(6);
                         strcpy(exemplu,"true");
                         value->strval=exemplu;
                    }
                    $$=value;
                
               }
               else
               {
                    printf("Error:Cannot use this type in the expression! Check line %d!\n",yylineno);
                    exit(ERROR);
               }
           }
           | LEFT_ROUND_BRACKETS expression AND expression RIGHT_ROUND_BRACKETS
           {
               info * value = (info *)malloc(sizeof(info));
               if($2->typeval==2 && $4->typeval==2)
               {
                    value->typeval=2;
                    if(strcmp($2->strval,"true")==0 && strcmp($4->strval,"true")==0)
                    {
                         char * exemplu = malloc(6);
                         strcpy(exemplu,"true");
                         value->strval=exemplu;
                    }
                    else 
                    {
                      char * exemplu = malloc(6);
                         strcpy(exemplu,"false");
                         value->strval=exemplu;
                    }
                    $$=value;
               }
               else
               {
                printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
                        exit(ERROR);
               }

           }
           | LEFT_ROUND_BRACKETS expression OR expression RIGHT_ROUND_BRACKETS
           {
               info * value = (info *)malloc(sizeof(info));
               if($2->typeval==2 && $4->typeval==2)
               {
                    value->typeval=2;
                    if(strcmp($2->strval,"false")==0 && strcmp($4->strval,"false")==0)
                    {
                         char * exemplu = malloc(6);
                         strcpy(exemplu,"false");
                         value->strval=exemplu;
                    }
                    else 
                    {
                        char * exemplu = malloc(6);
                         strcpy(exemplu,"true");
                         value->strval=exemplu;
                    }
                    $$=value;
               }
               else
               {
                printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
                        exit(ERROR);
               }

           }
           | LEFT_ROUND_BRACKETS expression MULTIPLY_MULTIPLY expression RIGHT_ROUND_BRACKETS
           {
			info * value = (info *)malloc(sizeof(info));
			if($2->typeval==3)
			{ 
				if($4->typeval==0)
				{
					char c[20];
					value->typeval=4;
					char* raspuns =(char *) malloc(30);
					bzero(raspuns,sizeof(raspuns));
					int num= atoi($4->strval);
					strcpy(c,$2->strval);
					strcpy(c,c+1);
					c[1]='\0';
					strcat(raspuns,"\"");
					while(num!=0)
					{
						strcat(raspuns,c);
						num=num-1;
					}
					strcat(raspuns,"\"");
					value->strval=raspuns;
					$$=value;
				}
				else
				{
					printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
					exit(ERROR);
				}
			
			}
			else if($4->typeval==3)
			{ 
				if($2->typeval==0)
				{
					char c[20];
					value->typeval=4;
					char* raspuns =(char *) malloc(30);
					bzero(raspuns,sizeof(raspuns));
					int num= atoi($2->strval);
					strcpy(c,$4->strval);
					strcpy(c,c+1);
					c[1]='\0';
					strcat(raspuns,"\"");
					while(num!=0)
					{
						strcat(raspuns,c);
						num=num-1;
					}
					strcat(raspuns,"\"");
					value->strval=raspuns;
					$$=value;
				}
				else
				{
					printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
					exit(ERROR);
				}
			}
			else if($4->typeval==4)
			{ 	
				if($2->typeval==0)
				{
					char c[20];
					value->typeval=4;
					char* raspuns =(char *) malloc(30);
					bzero(raspuns,sizeof(raspuns));
					int num= atoi($2->strval);
					strcpy(c,$4->strval);
					strcpy(c,c+1);
					int len=strlen(c);
					c[len-1]='\0';
					strcat(raspuns,"\"");
					while(num!=0)
					{
						strcat(raspuns,c);
						num=num-1;
					}
					
					strcat(raspuns,"\"");
					value->strval=raspuns;
					$$=value;
				}
				else
				{
					printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
					exit(ERROR);
				}
			}
			else if($2->typeval==4)
			{ 
				if($4->typeval==0)
				{
					char c[20];
					value->typeval=4;
					char* raspuns =(char *) malloc(30);
					bzero(raspuns,sizeof(raspuns));
					int num= atoi($4->strval);
					strcpy(c,$2->strval);
                         c[strlen(c)-1] = 0;
					strcpy(c,c+1);
					strcat(raspuns,"\"");
					while(num!=0)
					{
						strcat(raspuns,c);
						num=num-1;
					}
					strcat(raspuns,"\"");
					value->strval=raspuns;
					$$=value;
				}
				else
				{
					printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
					exit(ERROR);
				}
			
			}
			else
			{
				printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
					exit(ERROR);
			}
			
		 }
           | LEFT_ROUND_BRACKETS expression PLUS_PLUS expression RIGHT_ROUND_BRACKETS
           {
			//char 3 string 4
			info * value = (info *)malloc(sizeof(info));
			if ($2->typeval==3)
			{ 
				if($4->typeval==3)
				{
					char c[10];
					char d[10];
					value->typeval=4;
					char* raspuns =(char *) malloc(30);
					bzero(raspuns,sizeof(raspuns));
					strcpy(c,$2->strval);
					strcpy(c,c+1);
					c[1]='\0';
					strcpy(d,$4->strval);
					strcpy(d,d+1);
					d[1]='\0';
					strcat(raspuns,"\"");
					strcat(raspuns,c);
					strcat(raspuns,d);
					strcat(raspuns,"\"");
					value->strval=raspuns;
					$$=value;
				}
                    else if($4->typeval == 4)
                    {
                         char c[20];
					char d[20];
					value->typeval=4;
					char* raspuns =(char *) malloc(30);
					bzero(raspuns,sizeof(raspuns)); bzero(c,20);bzero(d,20);
					strcpy(c,$4->strval);
                         c[strlen(c)-1] = 0;
					strcpy(c,c+1);
					strcpy(d,$2->strval);
                         d[strlen(d)-1] = 0;
					strcpy(d,d+1);
					strcat(raspuns,"\"");
					strcat(raspuns,d);
					strcat(raspuns,c);
					strcat(raspuns,"\"");
					value->strval=raspuns;
					$$=value;
                    }
				else
				{
					printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
					exit(ERROR);
				}
			
			}
			else if($4->typeval==4)
			{ 	
				if($2->typeval==4)
				{
					char c[20];
					char d[20];
					value->typeval=4;
					char* raspuns =(char *) malloc(30);
					bzero(raspuns,sizeof(raspuns));bzero(c,20);bzero(d,20);
					strcpy(c,$4->strval);
                         c[strlen(c)-1] = 0;
					strcpy(c,c+1);
					strcpy(d,$4->strval);
                         d[strlen(d)-1] = 0;
					strcpy(d,d+1);
					strcat(raspuns,"\"");
					strcat(raspuns,c);
					strcat(raspuns,d);
					strcat(raspuns,"\"");
					value->strval=raspuns;
					$$=value;
				}
				else if($2->typeval==3)
				{
					
					char c[20];
					char d[20];
					value->typeval=4;
					char* raspuns =(char *) malloc(30);
					bzero(raspuns,sizeof(raspuns)); bzero(c,20);bzero(d,20);
					strcpy(c,$4->strval);
                         c[strlen(c)-1] = 0;
					strcpy(c,c+1);
					strcpy(d,$2->strval);
                         d[strlen(d)-1] = 0;
					strcpy(d,d+1);
					strcat(raspuns,"\"");
					strcat(raspuns,c);
					strcat(raspuns,d);
					strcat(raspuns,"\"");
					value->strval=raspuns;
					$$=value;
				}
				else
				{	
					printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
					exit(ERROR);
				}
			}
			else if($4->typeval==3)
			{ 
				
				if($2->typeval==4)
				{
					
					char c[20];
					char d[20];
					value->typeval=4;
					char* raspuns =(char *) malloc(30);
					bzero(raspuns,sizeof(raspuns));bzero(c,20);bzero(d,20);
					strcpy(c,$2->strval);
                         c[strlen(c)-1] = 0;
					strcpy(c,c+1);
					strcpy(d,$4->strval);
                         d[strlen(d)-1] = 0;
					strcpy(d,d+1);
					strcat(raspuns,"\"");
					strcat(raspuns,c);
					strcat(raspuns,d);
					strcat(raspuns,"\"");
					value->strval=raspuns;
					$$=value;
				}
				else
				{	
					printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
					exit(ERROR);
				}
			}
			else
			{
				printf("Error:Cannot use this type in the expression!Check line %d!\n",yylineno);
					exit(ERROR);
			}
			
		 }
           | IDENTIFIER DOT IDENTIFIER
           {
               structuri * gasit = Gaseste_structura($1);
               if(Gaseste_variabila_in_structura($3,gasit) == false)
               {
                    printf("Error: Variable \"%s\" was not found in the structure \"%s\"! Check line:%d!",$3,$1,yylineno);
                    exit(ERROR);
               }
               int scope_cautat = gasit->domeniu;
               info * value = (info *)malloc(sizeof(info));
               value->typeval = Gaseste_tipul_prin_Nume($3,scope_cautat);
               value->strval = Gaseste_valoarea_prin_Nume($3,scope_cautat,false);
               $$ = value;
           }
          | IDENTIFIER DOT IDENTIFIER LEFT_ROUND_BRACKETS expression RIGHT_ROUND_BRACKETS
           {
                    //todo
           }
          ;

value : INT_VALUE 
      {
          $$ = $1;
      }
      | BOOL_VALUE
      {
          $$ = $1;
      } 
      | STRING_VALUE
      {
          $$ = $1;
      }
      | FLOAT_VALUE
      {
          $$ = $1;
      }
      | CHAR_VALUE
      {
          $$ = $1;
      }
      ;

list : statement SEMICOLON 
     | list statement SEMICOLON
     ;

statement: declaratie 
         | IDENTIFIER ASSIGN expression
         {
               int tip = Gaseste_tipul_prin_Nume($1,scope);
               if(tip != $3->typeval)
               {
                    printf("Error: the type of variable \"%s\"[%s] is not the same as the assignment content[%s]! ChecK line:%d \n",$1,GetStringType(tip),GetStringType($3->typeval),yylineno);
                    exit(ERROR);
               }
               char * change = Gaseste_valoarea_prin_Nume($1,scope,true);
               strcpy(change,$3->strval);
         }
         | IDENTIFIER LEFT_SQUARE_BRACKETS INT_VALUE RIGHT_SQUARE_BRACKETS ASSIGN expression 
         {
               int tip = Gaseste_tipul_prin_Nume_Array($1,scope);
               if(tip != $6->typeval)
               {
                    printf("Error: the type of vector \"%s\"[%s] is not the same as the assignment content[%s]! ChecK line:%d \n",$1,GetStringType(tip),GetStringType($6->typeval),yylineno);
                    exit(ERROR);
               }
               int nr = atoi($3->strval);
               char * change = Gaseste_valoarea_prin_Nume_Array($1,scope,nr);
               strcpy(change,$6->strval);
         }
         | CALL_FUNCTION EVAL LEFT_ROUND_BRACKETS expression RIGHT_ROUND_BRACKETS
         {
              if($4->typeval == TYPE_INT)
                    printf("Eval result: %s\n",$4->strval);
         }
         | CALL_FUNCTION IDENTIFIER  LEFT_ROUND_BRACKETS lista_apel RIGHT_ROUND_BRACKETS
         {
               
              gaseste_functia($2); /* Daca am gasit functia, atunci verificam si signatura este corecta */
              /* Verificam toate functiile cu aceasi signatura */
              bool potrivire = false;
              functii * start = Obtine_functie_urmatoare_nume($2,Lista_Functii);
                
              while(start != NULL && potrivire == false)
              {
                    if(start->numar_parametri == parametri_apel - 1 )
                    {
                         bool okay = true;
                         int i = 0;
                         for(i = 0; i < parametri_apel-1; i++)
                         {
                              if(par_type[i]!=start->par[i].tip_parametru)
                                   okay = false;
                         }    
                         if(okay == true)
                              potrivire = true;
                    }
                    start = Obtine_functie_urmatoare_nume($2,start->urmatoarea_functie);
              }
              if(potrivire == false)
              {
                   printf("Error: Call function \"%s\" does not match with any existing signatures! Check line %d!",$2,yylineno);
                   exit(ERROR);
              }
              parametri_apel = 0;
         }
         | IF LEFT_ROUND_BRACKETS expression RIGHT_ROUND_BRACKETS THAN LEFT_BRACE list RIGHT_BRACE
         {
              if($3->typeval != TYPE_BOOL)
              {
                   printf("Error: if condition is not a boolean value! Check line %d!\n",yylineno);
                   exit(ERROR);
              }
         }
         | IF LEFT_ROUND_BRACKETS expression RIGHT_ROUND_BRACKETS LEFT_BRACE list RIGHT_BRACE ELSE LEFT_BRACE list RIGHT_BRACE
         {
               if($3->typeval != TYPE_BOOL)
              {
                   printf("Error: if condition is not a boolean value! Check line %d!\n",yylineno);
                   exit(ERROR);
              }
         }
         | WHILE LEFT_ROUND_BRACKETS expression RIGHT_ROUND_BRACKETS LEFT_BRACE list RIGHT_BRACE
         {
              if($3->typeval != TYPE_BOOL)
              {
                   printf("Error: while condition is not a boolean value! Check line %d!\n",yylineno);
                   exit(ERROR);
              }
         }
         | FOR LEFT_ROUND_BRACKETS IDENTIFIER ASSIGN expression SEMICOLON expression SEMICOLON IDENTIFIER ASSIGN expression RIGHT_ROUND_BRACKETS LEFT_BRACE list RIGHT_BRACE
         {     if($7->typeval != TYPE_BOOL)
               {
                    printf("Error: For condition is not a boolean value! Check line %d!\n",yylineno);
                    exit(ERROR);
               }
               int tip = Gaseste_tipul_prin_Nume($3,scope);
               if( tip != $5->typeval)
               {
                    printf("Error: In for(first) trying to assign to \"%s\"[%d] a value of type [%d]",$3,tip,$5->typeval);
                    exit(ERROR);
               }
               tip = Gaseste_tipul_prin_Nume($9,scope);
               if( tip != $11->typeval)
               {
                    printf("Error: In for(second) trying to assign to \"%s\"[%d] a value of type [%d]",$9,tip,$11->typeval);
                    exit(ERROR);
               }
         }
         | IDENTIFIER DOT IDENTIFIER ASSIGN expression
         {
               structuri * gasit = Gaseste_structura($1);
               if(Gaseste_variabila_in_structura($3,gasit) == false)
               {
                    printf("Error: Variable \"%s\" was not found in the structure \"%s\"! Check line:%d!",$3,$1,yylineno);
                    exit(ERROR);
               }
               int scope_cautat = gasit->domeniu;
               char * change = Gaseste_valoarea_prin_Nume($3,scope_cautat,true);
               strcat(change,$5->strval);
               variabile * found = Gaseste_variabila($3,scope_cautat);
               found->initializat = true;
         }
         | IDENTIFIER DOT IDENTIFIER LEFT_ROUND_BRACKETS list_expression RIGHT_ROUND_BRACKETS
         {
              //TODO
         }
         ;
        
lista_apel : expression
           {
                par_type[parametri_apel] = $1->typeval;
                parametri_apel++;
           }
           | lista_apel COMMA expression
           {
                par_type[parametri_apel] = $3->typeval;
                parametri_apel++;
           }
           | apel_functie
           | lista_apel COMMA apel_functie
           ;
apel_functie : CALL_FUNCTION IDENTIFIER LEFT_ROUND_BRACKETS lista_apel RIGHT_ROUND_BRACKETS
             {
                    int tip = Gaseste_tipul_prin_Nume_Functie($2);
                    par_type[parametri_apel] = tip;
                    parametri_apel++;
             }
             ;

%%
void yyerror(char * s)
{
     printf("eroare: %s la linia:%d\n",s,yylineno);
     exit(ERROR);
}

int main( int argc, char* argv[] )
{
     
     yyin=fopen(argv[1],"r");
     yyparse();
     fisier = fopen("symbol_tabel.txt","w");
     AfiseazaVariabilele();
     AfiseazaVectori();
     AfiseazaStructuri();
     AfiseazaFunctii();
} 

import java.util.ArrayList;
%%
%class Scanner
%standalone
%line
%column

/**
  * Definicion de macros
 */
Whitespace=[ \t\n\r]
numeros=[0-9]+ | ([0-9.]+) | ([.0-9]+)
numerosH=[0-9]+
letrasH=[A-F]+
cEscape=[\n,\xNN,\uNNNN,\xNN]
letras=[a-zA-Z_]+
simbolos=[|°!¡#$%&/=(){}[]?¿<>@·~\^_;.:,\"\`]

%{
  public static ArrayList<Token> tokens = new ArrayList<>();  
  public static ArrayList<Token> errores = new ArrayList<>();  
%}

%eofval{
  for(Token t: tokens){
    t.print();
  }

  System.out.println("\nErrores\n");
  for(Token t: errores){
    t.print();
  }
  return 0;
%eofval}

%%

/** 
  * Espacios en blanco
  */

{Whitespace} {/* Ignorar */}

/**
 * Comentarios
 * 
 */
"//"([ ]* | {numeros} | {simbolos} | {letras} )*(\n) {/*Ignore*/}

/**
  * Comentarios de bloque
  */

"/*"({Whitespace} | {numeros} | {simbolos} | {letras} | {cEscape})*(\r|\n|\r\n)* ( "*/" ) {/*Ignore*/}

/**
  * Literales hexadecimales
  */

hex\"({numerosH}|{letrasH})+\"    {tokens.add(new Token(yytext(), yyline, yycolumn, "Literal Hexadecimal"));}

/** 
  * Palabras reservadas
  */

address |
as |
bool |
break |
byte |
bytes((3[0-2])|([1-2][0-9])|[1-9])? |
constructor |
continue |
contract |
delete |
do |
else |
enum |
false |
for |
hex |
from |
function |
if |
import |
int(256|128|64|32|16|8)? |
internal |
mapping |
modifier |
payable |
pragma |
private |
public |
return |
returns |
solidity |
string |
struct |
this |
true |
ufixed |
uint(256|128|64|32|16|8)? |
var |
view |
while {
  //System.out.printf("Palabra reservada %s en linea %d columna %d \n", yytext(), yyline, yycolumn);
  tokens.add(new Token(yytext().trim(), yyline, yycolumn, "Parabra reservada"));
}

/**
  * TRANSAC 
 */ 

balance |
call | 
callcode |
delegatecall |
send |
transfer {
  tokens.add(new Token(yytext(), yyline, yycolumn, "Transac"));
}

/**
  * UNITS
 */
days |
ether |
finney |
hours |
minutes |
seconds |
szabo|
weeks|
wei|
years
{
  tokens.add(new Token(yytext(), yyline, yycolumn, "Units"));
}

/**
  * Literales
 */
{numeros}+( e- | e )?{numerosH}+                  {tokens.add(new Token(yytext(), yyline, yycolumn, "Literal numerico"));}
{numeros}+      {tokens.add(new Token(yytext(), yyline, yycolumn, "Literal numerico"));}
\"({Whitespace} | {numeros} | {simbolos} | {letras} | {cEscape})+\" | \'( {Whitespace} |{numeros} | {simbolos} | {letras} | {cEscape})\'    {tokens.add(new Token(yytext(), yyline, yycolumn, "Literal String"));}


/**
  * IDENTIFICADORES
 */
{letras} ({letras}|{numeros})* {tokens.add(new Token(yytext(), yyline, yycolumn, "Identificador"));}

/**
  * OPERADORES
 */
"!" |"&&"|"^" |"=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"^"|
"~" |"+" |"-" |"" |"/" |"%" |"*"| "<<" |">>"|"="|"," |";"|"."|
"(" |")"|"["|"]" |"?"|":" |"{"|"}"|"+="|"-="|"*=" |"/="
{tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));}

. {errores.add(new Token(yytext(), yyline, yycolumn, "Error"));}

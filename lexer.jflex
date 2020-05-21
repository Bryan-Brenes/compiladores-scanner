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
numeros=[0-9]

%{
  public static ArrayList<Token> tokens = new ArrayList<>();  
  public static ArrayList<Token> errores = new ArrayList<>();  
%}

%eofval{
  for(Token t: tokens){
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
 */


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
from |
function |
hex |
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

. {}

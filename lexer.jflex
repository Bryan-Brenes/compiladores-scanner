import java.util.ArrayList;
%%
%class Scanner
%standalone
%line
%column

/**
  * Definicion de macros
 */
Whitespace=[ \t\n]
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
bytes([1-9]|([1-2][0-9])|(3[0-2]))?({Whitespace}){1} |
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
int(8|16|32|64|128|256)? |
internal |
mapping |
modifier |
payable |
pragma |
Pragma |
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
uint(8|16|32|64|128|256)? |
var |
view |
while {
  //System.out.printf("Palabra reservada %s en linea %d columna %d \n", yytext(), yyline, yycolumn);
  tokens.add(new Token(yytext().trim(), yyline, yycolumn, "Parabra reservada"));
}

. {}

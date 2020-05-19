import java.util.ArrayList;
%%
%class Scanner
%standalone
%line
%column

/**
  * Definicion de macros
 */
Whitespace=[\t\n]
numeros=[0-9]

%{
  public static ArrayList<Token> tokens = new ArrayList<>();  
%}

%eofval{
  for(Token t: tokens){
    t.print();
  }
  return 0;
%eofval}

%%

/** 
  * Palabras reservadas
  */

address |
as |
bool |
break |
byte |
bytes |
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
int |
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
uint |
var |
view |
while {
  //System.out.printf("Palabra reservada %s en linea %d columna %d \n", yytext(), yyline, yycolumn);
  tokens.add(new Token(yytext(), yyline, yycolumn));
}

. {}

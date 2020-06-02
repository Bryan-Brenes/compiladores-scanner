/* JFlex example: partial Java language lexer specification */
import java.util.ArrayList;
/**
    * This class is a simple example lexer.
    */
%%

%class Lexer
%unicode
%standalone
%line
%column

%{
    StringBuffer string = new StringBuffer();
    StringBuffer stringN = new StringBuffer();
    public static int banderaN = 0;
    public static int bandera = 0;
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

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]
numbersH       = [0-9]+
lettersH       = [A-F]+
numberN        = [0-9]+ | "."([0-9]+)

/*************************************************************************************/
/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} | {DocumentationComment}

TraditionalComment   = "/*" [^*] ~"*/" | "/*" "*"+ "/"
// Comment can be the last line of the file, without line terminator.
EndOfLineComment     = "//" {InputCharacter}* {LineTerminator}?
DocumentationComment = "/**" {CommentContent} "*"+ "/"
CommentContent       = ( [^*] | \*+ [^/*] )*
/*************************************************************************************/

Identifier = [:jletter:] [:jletterdigit:]*

DecIntegerLiteral = 0 | [1-9][0-9]*

%state STRING
%state hexaState
%state hexaStateC
%state hexaStateError
%state hexaStateCError
%state numberState
%state NaturalNumbers
%state Chars
%state Identificadorcillo
%state hope

%%

/* keywords */
<YYINITIAL> "address" | "as" | "bool" | "break" | "byte" | "bytes"((3[0-2])|([1-2][0-9])|[1-9])? |
"constructor" | "continue" | "contract" | "delete" | "do" | "else" | "enum" | "false" | "for" | "from" | "function" |
"if" | "import" | "int"(256|128|64|32|16|8)? | "internal" | "mapping" | "modifier" | "payable" | "pragma" | "private" |
"public" | "return" | "returns" | "solidity" | "string" | "struct" | "this" | "true" | "ufixed" | "uint"(256|128|64|32|16|8)? |
"var" | "view" | "while" { tokens.add(new Token(yytext().trim(), yyline, yycolumn, "Palabra reservada"));}

/**
  * TRANSAC 
 */ 
<YYINITIAL> "balance" | "call"| "callcode" | "delegatecall" | "send" | "transfer"
{ tokens.add(new Token(yytext(), yyline, yycolumn, "Transac")); }

/**
  * UNITS
 */
<YYINITIAL> "days" | "ether" | "finney" | "hours" | "minutes" | "seconds" | "szabo" | "weeks"| "wei"| "years"
{ tokens.add(new Token(yytext(), yyline, yycolumn, "Units")); }

<YYINITIAL> "hex"\" { string.setLength(0); 
                      string.append(yytext());
                      yybegin(hexaState);}                 
<YYINITIAL> "hex"\' { string.setLength(0); 
                      string.append(yytext());
                      yybegin(hexaStateC);}
<YYINITIAL> "hex" { tokens.add(new Token(yytext().trim(), yyline, yycolumn, "Palabra reservada"));}

<YYINITIAL> {////////////////////////////////////////////////////////////////////////////////


/*Error Decimal */
( "-"* {numbersH}*  ("..")+ (".")*  "-"* {numbersH}* )  
{errores.add(new Token(yytext(), yyline, yycolumn, "Error Decimal"));banderaN =0;}

( "+"* "-"* ("0")+ {numbersH} )                              
{ errores.add(new Token(yytext(), yyline, yycolumn, "Error Decimal"));banderaN =0;}

( "-"* (".")+ ("-")* {numbersH} )                       
{ errores.add(new Token(yytext(), yyline, yycolumn, "Error Decimal"));banderaN =0;}




// j@m
/* identifiers */
{Identifier} { 
  tokens.add(new Token(yytext(), yyline, yycolumn, "Identificador"));
  stringN.setLength(0);
  stringN.append(yytext());
  banderaN = 1;
}


/* literals */
{numberN} {
  string.setLength(0);
  string.append(yytext());
  yybegin(numberState);
  banderaN =0;
}


\" { 
  string.setLength(0); yybegin(STRING); bandera = yycolumn;
  banderaN =0;
}


\' { 
  string.setLength(0); yybegin(Chars); bandera = yycolumn;
  banderaN =0;
}


/* operators */
"!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"|"|"^"|
"~" | "+" |"-" | "*" |"/" |"%" |"**"| "<<" |">>"|"="|"," |";"|"."|
"(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/=" {
  tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
  banderaN =0;
}

/* comments */
{Comment} { /* ignore */ ;banderaN =0;}

/* whitespace */
{WhiteSpace} { /* ignore */ ;banderaN =0;}


[^A-Za-z0-9\n\r\f\t\!\&\^\=\|\<\>\~\+\-\*\/\%\,\;\.\(\)\[\]\?\:\{\}] {
  
  if(banderaN == 1 ){
    stringN.append(yytext()); yybegin(hope);
    
   }
   else{
     stringN.setLength(0);
     stringN.append(yytext());yybegin(hope);
   } 
   }


}///////////////////////////////////////////////////////////////////////////////////////////////


<hope>{
  ( \n|\ )  { 
        errores.add(new Token(stringN.toString(), yyline, yycolumn, "Error: identificador"));
        banderaN =0;
        yybegin(YYINITIAL);
  }
  [^]     {stringN.append(yytext());}
}




<Identificadorcillo>{
    {WhiteSpace} | {LineTerminator} | "{" | "}" | "(" | ")" | ";" | "[" | "]"
    { errores.add(new Token(string.toString(), yyline, bandera, "Error: identificador")); yybegin(YYINITIAL); }

    [^\{\}\(\)\;\r\n\t\f]          { string.append(yytext()); }

}

<STRING> {
  \" {
    yybegin(YYINITIAL);
    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal string"));
  }

  {LineTerminator} { 
    System.out.println("HOLA");
    //string.append( yytext() );
    errores.add(new Token(string.toString(), yyline, bandera, "Error stringASAD"));
    yybegin(YYINITIAL);
  }
    
  [^\n\r\"\'\\]+ { 
    string.append( yytext() );  
  }
    
  [^] {
    errores.add(new Token(string.toString(), yyline, yycolumn, "Error string"));
    yybegin(YYINITIAL);
  }
}

<Chars> {
  \' {
    yybegin(YYINITIAL);
    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal char"));
  }

  {LineTerminator} { 
    System.out.println("HOLA2");
    string.append( yytext() );
    errores.add(new Token(string.toString(), yyline, bandera, "Error char"));
    yybegin(YYINITIAL);
  }

  [^\n\r\"\'\\]+ {
    string.append( yytext() );
  }

  [^] {
    errores.add(new Token(string.toString(), yyline, yycolumn, "Error char"));
    yybegin(YYINITIAL);
  }
}

<hexaState> {
  \" { 
    yybegin(YYINITIAL);
    string.append( yytext() ); 
    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal hexadecimal/Palabra Reservada")); 
  }

  \' {
    errores.add(new Token(yytext(), yyline, yycolumn, "Error: comillas de cierre incorrectas"));
    yybegin(YYINITIAL);
  }

  {WhiteSpace} {
    errores.add(new Token(yytext(), yyline, yycolumn, "Error: hexadecimal sin cierre"));
    yybegin(YYINITIAL);
  }

  ";" {
    tokens.add(new Token(yytext(), yyline, yycolumn, "Operador")); 
    errores.add(new Token("Comillas", yyline, yycolumn, "Error: hexadecimal sin cierre"));
    yybegin(YYINITIAL);
  }

  {lettersH} {
    string.append( yytext() );
  }

  {numbersH} {
    string.append( yytext() ); 
  }

  [^A-Fa-f0-9\;] {
    errores.add(new Token(yytext(), yyline, yycolumn, "Error: Numero no es hexadecimal"));
    yybegin(hexaStateError);
  }
}

<hexaStateError> {
  \" { 
    yybegin(YYINITIAL);
  }

  [^] {

  }

}

<hexaStateC> {
  \' {
    yybegin(YYINITIAL);
    string.append( yytext() ); 
    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal hexadecimal/Palabra Reservada")); 
  }

  \" {
    errores.add(new Token(yytext(), yyline, yycolumn, "Error: comillas de cierre incorrectas"));
    yybegin(YYINITIAL);
  }

  {WhiteSpace} {
    errores.add(new Token(yytext(), yyline, yycolumn, "Error: hexadecimal sin cierre"));
    yybegin(YYINITIAL);
  }

  ";" {
    tokens.add(new Token(yytext(), yyline, yycolumn, "Operador")); 
    errores.add(new Token("Comillas", yyline, yycolumn, "Error: hexadecimal sin cierre"));
    yybegin(YYINITIAL);
  }

  {lettersH} { 
    string.append( yytext() ); 
  }

  {numbersH} {
    string.append( yytext() ); 
  }

  [^A-Fa-f0-9\;] {
    errores.add(new Token(yytext(), yyline, yycolumn, "Error: Numero no es hexadecimal"));
    yybegin(YYINITIAL);
  }
}

<hexaStateCError> {
  \' { 
    yybegin(YYINITIAL);
  }

  [^] {

  }
}

<numberState> {
  {WhiteSpace} | "," {
    yybegin(YYINITIAL);
    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
  }

  ")" {
    yybegin(YYINITIAL);
    tokens.add(new Token(string.toString(), yyline, yycolumn, "literal numerico"));
    tokens.add(new Token(")", yyline+1, yycolumn, "Operador"));
  }

  ";" {
    yybegin(YYINITIAL);
    tokens.add(new Token(string.toString(), yyline, yycolumn, "literal numerico"));
    tokens.add(new Token(";", yyline+1, yycolumn, "Operador"));
  }

  {numbersH} { string.append(yytext());}
  "." { 
    string.append(yytext());
  }

  "e" { 
    yybegin(NaturalNumbers);
    string.append(yytext());
  }

  [A-DF-Za-df-z] { 
    string.append(yytext()); yybegin(Identificadorcillo); 
  }
}

<NaturalNumbers> {
  {WhiteSpace} {
    if(bandera == 1){
      yybegin(YYINITIAL);
      errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Literal numerico"));
    }
    else{
      yybegin(YYINITIAL);
      tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
    }
  }

  ";" {
    if(bandera == 1){
      yybegin(YYINITIAL);
      errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Literal numerico"));
      tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
    }
    else{
      yybegin(YYINITIAL);
      tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
      tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
    }
  }

  {numbersH} { 
    string.append(yytext());
  }

  "-" { 
    string.append(yytext());
  }

  [^\-\;] { 
    bandera = 1; 
    string.append(yytext());
  }
}

/* error fallback */
[^] {
  System.out.println(yyline);
  System.out.println(yycolumn); 
  // throw new Error("Illegal character <"+ yytext()+">"); 
}
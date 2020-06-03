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
    public static int bandera2 = 0;
    public static int bandera3 = 0;
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
simbolos = "~" | ")" | "]" |"}"
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


/*************************************[STATES]************************************************/
%state STRING
%state hexaState
%state hexaStateC
%state hexaStateError
%state hexaStateCError
%state numberState
%state NaturalNumbers
%state Chars
%state Identificadorcillo
%state stateNosibol
%state filtro
%state otraMas
%%



/*************************************[PRINCIPALES]**********************************************/

/* keywords */
<YYINITIAL> "address" | "as" | "bool" | "break" | "byte" | "bytes"((3[0-2])|([1-2][0-9])|[1-9])? |
"constructor" | "continue" | "contract" | "delete" | "do" | "else" | "enum" | "false" | "for" | "from" | "function" |
"if" | "import" | "int"(256|128|64|32|16|8)? | "internal" | "mapping" | "modifier" | "payable" | "pragma" | "private" |
"public" | "return" | "returns" | "solidity" | "string" | "struct" | "this" | "true" | "ufixed" | "uint"(256|128|64|32|16|8)? |
"var" | "view" | "while" { tokens.add(new Token(yytext().trim(), yyline, yycolumn, "Palabra reservada"));}


/*************************************[TRANSAC ]**********************************************/

<YYINITIAL> "balance" | "call"| "callcode" | "delegatecall" | "send" | "transfer"
{ tokens.add(new Token(yytext(), yyline, yycolumn, "Transac")); }



/*************************************[UNITS]**********************************************/
<YYINITIAL> "days" | "ether" | "finney" | "hours" | "minutes" | "seconds" | "szabo" | "weeks"| "wei"| "years"
{ tokens.add(new Token(yytext(), yyline, yycolumn, "Units")); }

<YYINITIAL> "hex"\" { string.setLength(0); 
                      string.append(yytext());
                      yybegin(hexaState);}                 
<YYINITIAL> "hex"\' { string.setLength(0); 
                      string.append(yytext());
                      yybegin(hexaStateC);}
<YYINITIAL> "hex" { tokens.add(new Token(yytext().trim(), yyline, yycolumn, "Palabra reservada"));}

<YYINITIAL> {


/*************************************[Error Decimal]************************************************/

( "-"* {numbersH}*  ("..")+ (".")*  "-"* {numbersH}* )  
{errores.add(new Token(yytext(), yyline, yycolumn, "Error Decimal"));}

( "+"* "-"* ("0")+ {numbersH} )                              
{ errores.add(new Token(yytext(), yyline, yycolumn, "Error Decimal"));}

( "-"* (".")+ ("-")* {numbersH} )                       
{ errores.add(new Token(yytext(), yyline, yycolumn, "Error Decimal"));}





/*************************************[ identifiers]************************************************/
{simbolos}+ {Identifier}+ {
  string.setLength(0);
  string.append(yytext());
  errores.add(new Token(string.toString(), yyline, yycolumn, "Error Decimal"));
  yybegin(YYINITIAL);

}

{Identifier} {
stringN.setLength(0);
string.setLength(0);
string.append(yytext());
stringN.append(yytext());
yybegin(filtro);
}



/*************************************[ literals ]************************************************/
{numberN} {
  string.setLength(0);
  string.append(yytext());
  yybegin(numberState);
  banderaN =0;
  bandera2 = 0;
  bandera3= 0;
}


\" { 
  string.setLength(0); yybegin(STRING); bandera = yycolumn;
}


\' { 
  string.setLength(0); yybegin(Chars); bandera = yycolumn;
}



/*************************************[ operators ]************************************************/
"!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"|"|"^"|
"~" | "+" |"-" | "*" |"/" |"%" |"**"| "<<" |">>"|"="|"," |";"|"."|
"(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/=" {
  tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
}

/*************************************[ comments ]************************************************/
/* comments */
{Comment} { /* ignore */ ;banderaN =0;}

/* whitespace */
{WhiteSpace} { /* ignore */ ;banderaN =0;}


/*************************************[ No simbolos ]************************************************/
[^A-Za-z0-9\n\r\f\t\!\&\^\=\|\<\>\~\+\-\*\/\%\,\;\.\(\)\[\]\?\:\{\}] {
     stringN.setLength(0);
     stringN.append(yytext());
     yybegin(stateNosibol);
   }


}
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////



/*************************************[ filtro ]************************************************/
<filtro>{    
  "!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"|"|"^"|
  "+" |"-" | "*" |"/" |"%" |"**"| "<<" |">>"|"="|"," |";"|"."|
  "(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/=" 
  {  
    tokens.add(new Token(string.toString(), yyline, yycolumn, "Identificador"));
    tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
    yybegin(YYINITIAL);
  }

  {simbolos}  {string.append(yytext()) ;
              errores.add(new Token(string.toString(), yyline, yycolumn, "Error Identificador"));
              yybegin(YYINITIAL);}

  [^ A-Za-z0-9\n\r\f\t\!\&\^\=\|\<\>\~\+\-\*\/\%\,\;\.\(\)\[\]\?\:\{\} ]   {
    stringN.append(yytext());
    yybegin(stateNosibol);
  }


  [^]   {
    tokens.add(new Token(string.toString(), yyline, yycolumn, "Identificador"));
    yybegin(YYINITIAL);
  }            

}

/*************************************[ No simbolos filtros ]************************************************/
<stateNosibol>{
   ("{" | "}" | "(" | ")" | ";" | "[" | "]" |"//" )  {  
        tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));     
        errores.add(new Token(stringN.toString(), yyline, yycolumn, "Error: identificador"));
        yybegin(YYINITIAL);
  }
  ({WhiteSpace})  {   
        errores.add(new Token(stringN.toString(), yyline, yycolumn, "Error: identificador"));
        yybegin(YYINITIAL);
  }
  [^]  {stringN.append(yytext());yybegin(stateNosibol);}
}


/*************************************[ identificador especial ]************************************************/

<Identificadorcillo>{
    {WhiteSpace} | {LineTerminator} | "{" | "}" | "(" | ")" | ";" | "[" | "]"
    { errores.add(new Token(string.toString(), yyline, bandera, "Error: identificador")); yybegin(YYINITIAL); }
    [^\{\}\(\)\;\r\n\t\f]          { string.append(yytext()); }

}


/*************************************[ strings  ]************************************************/
<STRING> {
  \" {
    yybegin(YYINITIAL);
    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal string"));
  }

  {LineTerminator} { 
    errores.add(new Token(string.toString(), yyline, bandera, "Error stringASAD"));
    yybegin(YYINITIAL);
  }
    
  [^\n\r\"\']+ { 
    string.append( yytext() );  
  }
    
  [^] {
    errores.add(new Token(string.toString(), yyline, yycolumn, "Error string"));
    yybegin(YYINITIAL);
  }
}


/*************************************[ chars ]************************************************/
<Chars> {
  \' {
    yybegin(YYINITIAL);
    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal char"));
  }

  {LineTerminator} { 
    string.append( yytext() );
    errores.add(new Token(string.toString(), yyline, bandera, "Error char"));
    yybegin(YYINITIAL);
  }

  [^\n\r\"\']+ {
    string.append( yytext() );
  }

  [^] {
    errores.add(new Token(string.toString(), yyline, yycolumn, "Error char"));
    yybegin(YYINITIAL);
  }
}


/*************************************[ hexa ]************************************************/
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
    string.append(yytext());
    yybegin(hexaStateError);
  }
}

/*************************************[ hexa error ]************************************************/
<hexaStateError> {
  {WhiteSpace}   { yybegin(YYINITIAL); errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Numero no es hexadecimal")); }
  \" | \; { 
    yybegin(YYINITIAL);
    string.append(yytext());
    errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Numero no es hexadecimal"));
  }

  [^] {
    string.append(yytext());
  }
}

/*************************************[ hexa comillas simples ]************************************************/
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
    string.append(yytext());
    yybegin(hexaStateCError);
  }
}


/*************************************[ hexa error  ]************************************************/
<hexaStateCError> {
  {WhiteSpace}   { yybegin(YYINITIAL); errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Numero no es hexadecimal")); }

  \' | \; { 
    yybegin(YYINITIAL);
    string.append(yytext());
    errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Numero no es hexadecimal"));
  }

  [^] {
    string.append(yytext());
  }
}
 
 /*************************************[ numeros  ]************************************************/
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
    yybegin(otraMas);
    string.append(yytext());
  }

"!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"|"|"^"|
"~" | "+" |"-" | "**" |"/" |"%" |"*"| "<<" |">>"|"="|"," |";"|"."|
"(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/=" {
  tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
  tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
  yybegin(YYINITIAL);
}

  [A-DF-Za-df-z] { 
    string.append(yytext()); yybegin(Identificadorcillo); 
  }
}

<otraMas> {
  "-" {
    string.append(yytext());
    bandera2 = 1;
    yybegin(NaturalNumbers);
  }

  [A-Za-z]+([A-Za-z]*[0-9]*)* {
    System.out.println("Hola");
    string.append(yytext());
    errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Literal numerico"));
    yybegin(YYINITIAL);
  }

  [0-9]+ {
    if (bandera3 == 1){
      string.append(yytext());
      errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Literal numerico"));
      yybegin(YYINITIAL);
    }
    else{
      string.append(yytext());
      yybegin(NaturalNumbers);
    }
  }

  [\;\!\&\^\=\!\|\<\>\~\+\*\/\%\,\(\)\[\]\?\:\{\}] {
    if (bandera3 == 0){
      string.append(yytext());
      bandera3 = 1;
      yybegin(otraMas);
    }
    else{
      errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Literal numerico"));
      tokens.add(new Token(yytext(), yyline, yycolumn, "Error: Literal numerico"));
      yybegin(YYINITIAL);
    }
  }
}

/*************************************[ numeros naturales ]************************************************/
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

  "!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"|"|"^"|
  "~" | "+" | "**" |"/" |"%" |"*"| "<<" |">>"|"="|"," |";"|
  "(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/=" {
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
    if((bandera2 == 1) && (bandera == 1)){
      yybegin(YYINITIAL);
      errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Literal numerico"));
      tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
    }
    else if ((bandera2 == 1) && (bandera == 0)){
      yybegin(YYINITIAL);
      tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
      tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
    }
    else if ((bandera2 == 0) && (bandera == 1)){
      yybegin(YYINITIAL);
      errores.add(new Token(string.toString(), yyline, yycolumn, "Error: Literal numerico"));
      tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
    }
    else {
      yybegin(YYINITIAL);
      tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
      tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
    }
  }

  [^\-\;\!\&\^\=\!\|\<\>\~\+\*\/\%\,\(\)\[\]\?\:\{\}] { 
    bandera = 1; 
    string.append(yytext());
  }
}


/************************************[ error fallback ]************************************************/
[^] {
  System.out.println(yyline);
  System.out.println(yycolumn); 
  // throw new Error("Illegal character <"+ yytext()+">"); 
}
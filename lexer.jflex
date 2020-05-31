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
    public static int errorLine = -1;
    public static int errorColumn = -1;
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
lettersH       = [A-Fa-f]+
numberN        = [0-9]+ | "."([0-9]+)

simbolos       = "!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"^"|
                 "~" | "+" |"-" | "*" |"/" |"%" |"<<" |">>"|"="|"," |";"|
                 "(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/="

simbolosB       = "!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"^"|
                 "~" | "+" | "*" |"/" |"%" |"*"| "<<" |">>"|"="|"," | ";" |
                 "(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/=" 

/*************************************************************************************/
/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} | {DocumentationComment}

TraditionalComment   = "/*" [^*] ~"*/" | "/*" "*"+ "/"
// Comment can be the last line of the file, without line terminator.
EndOfLineComment     = "//" {InputCharacter}* {LineTerminator}?
DocumentationComment = "/**" {CommentContent} "*"+ "/"
CommentContent       = \* \** [^/*]*

// fuente: Manual de usuario de JFlex
/*************************************************************************************/

Identifier = [:jletter:] [:jletterdigit:]*

%state STRING
%state hexaState
%state numberState
%state NaturalNumbers
%state Chars
%state Comments
%state lineComment
%state errorNumeros
%state stringError
%state charError
%state hexaStateC
%state hexaStateError
%state hexaStateCError
%state indetifierState
%state indetifierError
%state decimalError
%state OperadoresState
%%

<YYINITIAL> {simbolos} {tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));}

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

<YYINITIAL> {
    ( "-"* ("0")+ {numbersH} )        { errores.add(new Token(yytext(), yyline, yycolumn, "Error Decimal"));}
    ( (".." | "...")+ "-"* {numberN}) { errores.add(new Token(yytext(), yyline, yycolumn, "Error decimal"));}
    /* identifiers */
    ({Identifier}|{simbolos})         { string.setLength(0); string.append(yytext()); yybegin(indetifierState);}
    ({numberN}{Identifier})           { string.setLength(0); string.append(yytext()); yybegin(indetifierError);}

    /* literals */
    {numberN}                      {
                                    string.setLength(0);
                                    string.append(yytext());
                                    yybegin(numberState);
                                   }

    \"                             { string.setLength(0); yybegin(STRING);}
    \'                             { string.setLength(0); yybegin(Chars);}

    /* comments */
    "/*"                          {
                                    errorLine = -1;
                                    errorColumn = -1; 
                                    yybegin(Comments);
                                   }
    "//"                           { yybegin(lineComment); }

    /* whitespace */
    {WhiteSpace}                   { /* ignore */ }
}

<STRING> {
    \"                            {
                                   yybegin(YYINITIAL);
                                   tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal string"));
                                  }
    \'                            { 
                                    errores.add(new Token("Comilla", yyline, yycolumn, "Error: cierre de comilla incorrecto"));
                                    yybegin(YYINITIAL);
                                  }
    {LineTerminator}              { 
                                    errores.add(new Token("Salto linea", yyline, yycolumn, "Error: strings deben ir en la misma linea"));
                                    yybegin(stringError);
                                  }
    "\\""n"                       { string.append( yytext() ); }
    "\\xNN"                       { string.append( yytext() ); }
    "\\uNNNN"                     { string.append( yytext() ); }
    [^\"\'\n\r]+                  { 
                                    string.append( yytext() ); 
                                  }
}

<Chars> {
    \'                            {
                                   yybegin(YYINITIAL);
                                   tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal char"));
                                  }
    \"                            { 
                                    errores.add(new Token("Comilla", yyline, yycolumn, "Error: cierre de comilla incorrecto")); 
                                    yybegin(YYINITIAL);
                                  }
    {LineTerminator}              { 
                                    errores.add(new Token("Salto linea", yyline, yycolumn, "Error: chars deben ir en la misma linea"));
                                    yybegin(charError);
                                  }
    "\\n"                         { string.append( yytext() ); }
    "\\xNN"                       { string.append( yytext() ); }
    "\\uNNNN"                     { string.append( yytext() ); }
    [^\"\'\n\r]+                  { 
                                    string.append( yytext() ); 
                                  }
}

<hexaState> {
    \"                            { yybegin(YYINITIAL);
                                    string.append( yytext() ); 
                                    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal hexadecimal/Palabra Reservada")); 
                                  }
    \'                            {
                                    errores.add(new Token(yytext(), yyline, yycolumn, "Error: comillas de cierre incorrectas"));
                                    yybegin(YYINITIAL);
                                  }
    {WhiteSpace}                  {
                                    errores.add(new Token(yytext(), yyline, yycolumn, "Error: hexadecimal sin cierre"));
                                    yybegin(YYINITIAL);
                                  }
    ";"                           {
                                    tokens.add(new Token(yytext(), yyline, yycolumn, "Operador")); 
                                    errores.add(new Token("Comillas", yyline, yycolumn, "Error: hexadecimal sin cierre"));
                                    yybegin(YYINITIAL);
                                  }
    {lettersH}                    { string.append( yytext() ); }
    {numbersH}                    { string.append( yytext() ); }
    [^A-Fa-f0-9\;]                  {
                                    errores.add(new Token(yytext(), yyline, yycolumn, "Error: Numero no es hexadecimal"));
                                    yybegin(hexaStateError);
                                  }
}

<hexaStateError> {
    \"                            { 
                                    yybegin(YYINITIAL);
                                  }
    [^]                           { }

}

<hexaStateC> {
    \'                            { yybegin(YYINITIAL);
                                    string.append( yytext() ); 
                                    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal hexadecimal/Palabra Reservada")); 
                                  }
    \"                            {
                                    errores.add(new Token(yytext(), yyline, yycolumn, "Error: comillas de cierre incorrectas"));
                                    yybegin(YYINITIAL);
                                  }
    {WhiteSpace}                  {
                                    errores.add(new Token(yytext(), yyline, yycolumn, "Error: hexadecimal sin cierre"));
                                    yybegin(YYINITIAL);
                                  }
    ";"                           {
                                    tokens.add(new Token(yytext(), yyline, yycolumn, "Operador")); 
                                    errores.add(new Token("Comillas", yyline, yycolumn, "Error: hexadecimal sin cierre"));
                                    yybegin(YYINITIAL);
                                  }
    {lettersH}                    { string.append( yytext() ); }
    {numbersH}                    { string.append( yytext() ); }
    [^A-Fa-f0-9\;]                {
                                    errores.add(new Token(yytext(), yyline, yycolumn, "Error: Numero no es hexadecimal"));
                                    yybegin(YYINITIAL);
                                  }
}

<hexaStateCError> {
    \'                            { 
                                    yybegin(YYINITIAL);
                                  }
    [^]                           { }
}

<numberState> {
    {WhiteSpace}                  {
                                    yybegin(YYINITIAL);
                                    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
                                  }
    // [:jletter:]                   {
    //                                 yybegin(YYINITIAL);
    //                                 tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
    //                               }
    {simbolosB}                    {
                                    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
                                    tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));
                                    yybegin(YYINITIAL);
                                  }
    {numbersH}                    { string.append(yytext());}
    "."                           { string.append(yytext());}
    "e"                           { yybegin(NaturalNumbers);
                                    string.append(yytext());}
    [^]                           {
                                    string.append(yytext());
                                    yybegin(errorNumeros);
                                  }
}

<NaturalNumbers> {
    {WhiteSpace} | {simbolosB}     {
                                    yybegin(YYINITIAL);
                                    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
                                  }
    {numbersH}                    { string.append(yytext());}
    "-"                           { string.append(yytext());}
    [^]                           {
                                    string.append(yytext());
                                    yybegin(errorNumeros);
                                  }
}

<Comments> {
    "*/"                          { 
                                    if(errorLine != -1){
                                    errores.add(new Token("*", errorLine, errorColumn, "Error: linea sin * <comentario bloque>"));
                                  }
                                    yybegin(YYINITIAL);
                                  }

    \*{InputCharacter}*{LineTerminator}         { }
    {InputCharacter}*{LineTerminator}                            { 
                                                                  if(errorLine == -1){
                                                                    errorLine = yyline;
                                                                    errorColumn = yycolumn;
                                                                  }
                                                                }
    <<EOF>>                       { errores.add(new Token("/**", yyline, yycolumn, "Error: llave comentario abierta")); }
}

<lineComment> {
    {LineTerminator}              { yybegin(YYINITIAL); }
     [^]                            { }  
}

<indetifierError> {
     \n  {
                   errores.add(new Token(string.toString(), yyline, yycolumn, "Error de identificador"));
                   yybegin(YYINITIAL);
                  }
    [^]           {string.append(yytext());}
}

<indetifierState> {
  
     \n  {
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador"));
                   yybegin(YYINITIAL);
                  }
    \             {string.append(yytext()); yybegin(indetifierError);}
    {simbolos}    {string.append(yytext()); yybegin(indetifierError);}
    [^]             {string.append(yytext());}
  
}

<decimalError> {
     \n  {
                   errores.add(new Token(string.toString(), yyline, yycolumn, "Error Decimal"));
                   yybegin(YYINITIAL);
                  }
    [^]           {string.append(yytext());}
}

<errorNumeros> {
  {WhiteSpace}                    {
                                    yybegin(YYINITIAL);
                                    errores.add(new Token(string.toString(), yyline, yycolumn, "Error: numero mal formado"));
                                  }
  [^]                             {string.append(yytext());} 
}

<stringError> {
    \"                            {
                                    yybegin(YYINITIAL);
                                  }
    \'                            {
                                    yybegin(YYINITIAL);
                                  }
    [^\"\']+                        { }
}

<charError> {
    \'                            {
                                    yybegin(YYINITIAL);
                                  }
    \"                            {
                                    yybegin(YYINITIAL);
                                  }
    [^\"\']+                        { }
}

/* error fallback */
[^]                              { 
                                  System.out.println(yyline);
                                  System.out.println(yycolumn);
                                  throw new Error("Illegal character <"+ yytext()+">"); 
                                 }

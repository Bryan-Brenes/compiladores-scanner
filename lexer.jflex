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
lettersH       = [A-F]+
numberN        = [0-9]+ | "."([0-9]+)
simbolos       = "!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"^"|
                 "~" | "+" |"-" | "*" |"/" |"%" |"*"| "<<" |">>"|"="|"," |";"|
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
%state indetifierState
%state indetifierError
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


 /////////////////////////////////////////////////////////////////////////////
///////////////////////////////JM////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//<YYINITIAL>(identifiers | simbolos | numbersN)*  { System.out.println("picha"); string.append(yytext()); yybegin(indetifierState);}
//<YYINITIAL>(numberN|simbolos)*       { string.append(yytext()); yybegin(indetifierError);}// simbolo o numero 
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
                     

<YYINITIAL> {


 /////////////////////////////////////////////////////////////////////////////
///////////////////////////////JM////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
    /* identifiers */
    ({Identifier}|whitespace| {simbolos})      {string.append(yytext()); yybegin(indetifierState);}
    ({numberN}{Identifier})*         {string.append(yytext()); yybegin(indetifierError);}
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

    /* literals */
    {numberN}                      {
                                    string.setLength(0);
                                    string.append(yytext());
                                    yybegin(numberState);
                                   }

    \"                             { string.setLength(0); yybegin(STRING);}
    \'                             { string.setLength(0); yybegin(Chars);}

    /* operators */
    "!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"^"|
    "~" | "+" |"-" | "*" |"/" |"%" |"*"| "<<" |">>"|"="|"," |";"|"."|
    "(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/="           {tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));}

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
    [^\"\\]+                      { string.append( yytext() ); }
    {Identifier}                  { string.append( yytext() ); }
    "\\n"                         { string.append( yytext() ); }
    "\\xNN"                       { string.append( yytext() ); }
    "\\uNNNN"                     { string.append( yytext() ); }
    // "\'"                          {  }
}

<Chars> {
    \'                            {
                                   yybegin(YYINITIAL);
                                   tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal char"));
                                  }
    [^\n\r\"\'\\]+                  { string.append( yytext() ); }
    {Identifier}                  { string.append( yytext() ); }
}

<hexaState> {
    \"                            { yybegin(YYINITIAL);
                                    string.append( yytext() ); 
                                    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal hexadecimal/Palabra Reservada")); }
    {lettersH}                    { string.append( yytext() ); }
    {numbersH}                    { string.append( yytext() ); }
}

<numberState> {
    {WhiteSpace} | {simbolos}     {
                                    yybegin(YYINITIAL);
                                    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
                                  }
    {numbersH}                    { string.append(yytext());}
    "."                           { string.append(yytext());}
    "e"                           { yybegin(NaturalNumbers);
                                    string.append(yytext());}

}

<NaturalNumbers> {
    {WhiteSpace} | {simbolos}     {
                                    yybegin(YYINITIAL);
                                    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal numerico"));
                                  }
    {numbersH}                    { string.append(yytext());}
    "-"                           { string.append(yytext());}
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
    .*                            { }  
}





/////////////////////////////////////////////////////////////////////////////
///////////////////////////////////JM////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
<indetifierError> {
     \n  {
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "Error de identificador"));
                   yybegin(YYINITIAL);
                   string.setLength(0);
                  }
    [^]           {string.append(yytext());}
}


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
<indetifierState> {
  
     \n  {
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador"));
                   yybegin(YYINITIAL);
                   string.setLength(0);
                  }
    //{simbolos}   {string.append(yytext()); yybegin(indetifierError);}
    {simbolos}   {string.append(yytext()); yybegin(indetifierError);}
    [^]             {string.append(yytext());}
  
}

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////



/* error fallback */
[^]                              { 
                                  System.out.println(yyline);
                                  System.out.println(yycolumn);
                                  throw new Error("Illegal character <"+ yytext()+">"); 
                                 }


/*
*
asda
*/















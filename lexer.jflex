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
    public static int flag = 0;
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
Letars         = [a-zA-Z_]+
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
WhiteSpace     = {LineTerminator} | [ \t\f]
numbersH       = [0-9]+
lettersH       = [A-Fa-f]+
numberN        = [0-9]+ | "."([0-9]+)

simbolos       = "!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"|"|"^"|
                 "~" | "+" |"-" | "*" |"/" |"%" | "**" |"<<" |">>"|"="|"," |"."|";"|
                 "(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/="

simbolosB       = "!" | "&&"|"^" | "=="|"!="|"||"|"<="|"<" |">="|">" |"&"|"^"|
                 "~" | "+" | "*" |"/" |"%" |"*"| "<<" |">>"|"="|"," | ";" |
                 "(" | ")" |"[" | "]" | "?"|":" |"{"|"}"|"+="|"-="|"*=" |"/=" 

/*************************************************************************************/


/* MACROS */


// fuente: Manual de usuario de JFlex
/*************************************************************************************/

Identifier = [:jletter:] [:jletterdigit:]*// NO INCLUYE NEGATIVOS



/////////////////////////////////////////////////////
////////////////////[  STATES  ]/////////////////////
/////////////////////////////////////////////////////
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
%state SpaceStateError
%state SpaceStateDone
%state selectNumber
%state selectExtra
%state selectSemiID
%%
/////////////////////////////////////////////////////



/////////////////////////////////////////////////////
////////////////////[  OPERADORES  ]/////////////////
/////////////////////////////////////////////////////
<YYINITIAL> {simbolos} {tokens.add(new Token(yytext(), yyline, yycolumn, "Operador"));}
/////////////////////////////////////////////////////



/////////////////////////////////////////////////////
////////////////////[  KEYWORDS  ]///////////////////
/////////////////////////////////////////////////////
<YYINITIAL> "address" | "as" | "bool" | "break" | "byte" | "bytes"((3[0-2])|([1-2][0-9])|[1-9])? |
"constructor" | "continue" | "contract" | "delete" | "do" | "else" | "enum" | "false" | "for" | "from" | "function" |
"if" | "import" | "int"(256|128|64|32|16|8)? | "internal" | "mapping" | "modifier" | "payable" | "pragma" | "private" |
"public" | "return" | "returns" | "solidity" | "string" | "struct" | "this" | "true" | "ufixed" | "uint"(256|128|64|32|16|8)? |
"var" | "view" | "while" { tokens.add(new Token(yytext().trim(), yyline, yycolumn, "Palabra reservada"));}
/////////////////////////////////////////////////////



/////////////////////////////////////////////////////
////////////////////[  TRANSAC  ]/////////////////////
/////////////////////////////////////////////////////
<YYINITIAL> "balance" | "call"| "callcode" | "delegatecall" | "send" | "transfer"
{ tokens.add(new Token(yytext(), yyline, yycolumn, "Transac")); }
/////////////////////////////////////////////////////



/////////////////////////////////////////////////////
////////////////////[  UNITS  ]//////////////////////
/////////////////////////////////////////////////////
<YYINITIAL> "days" | "ether" | "finney" | "hours" | "minutes" | "seconds" | "szabo" | "weeks"| "wei"| "years"
{ tokens.add(new Token(yytext(), yyline, yycolumn, "Units")); }
/////////////////////////////////////////////////////



/////////////////////////////////////////////////////
////////////////////[  HEX  ]////////////////////////
/////////////////////////////////////////////////////
<YYINITIAL> "hex"\" { string.setLength(0); 
                      string.append(yytext());
                      yybegin(hexaState);}                 
<YYINITIAL> "hex"\' { string.setLength(0); 
                      string.append(yytext());
                      yybegin(hexaStateC);}
<YYINITIAL> "hex" { tokens.add(new Token(yytext().trim(), yyline, yycolumn, "Palabra reservada"));}
/////////////////////////////////////////////////////



<YYINITIAL> {


     /////////////////////////////////////////////////////
     /////////////////[  DECIMALES  ]/////////////////////
     /////////////////////////////////////////////////////
    ( "-"* ("0")+ {numbersH} )        { string.setLength(0); string.append(yytext());errores.add(new Token(yytext(), yyline, yycolumn, "Error Decimal"));}
    (".")+ { string.setLength(0);string.append(yytext()); yybegin(decimalError);}
    /////////////////////////////////////////////////////



    /////////////////////////////////////////////////////
    //////////////////[  NUMEROS   ]////////////////////
    /////////////////////////////////////////////////////
    {numberN}                      {string.setLength(0);string.append(yytext());yybegin(selectNumber);}
    /////////////////////////////////////////////////////

    
     /////////////////////////////////////////////////////
     //////////////[  IDENTIFICADORES  ]//////////////////
     /////////////////////////////////////////////////////
     ({Identifier}|{simbolos})          { string.setLength(0); string.append(yytext()); yybegin(indetifierState);}
    /////////////////////////////////////////////////////



    


    /////////////////////////////////////////////////////
   //////////////////[  LITERALES  ]////////////////////
   /////////////////////////////////////////////////////
    \"                             { string.setLength(0); yybegin(STRING);}
    \'                             { string.setLength(0); yybegin(Chars);}
   /////////////////////////////////////////////////////



   /////////////////////////////////////////////////////
   //////////////////[  COMENTARIOS  ]///////////////////
   /////////////////////////////////////////////////////
    "/*"                          {
                                    errorLine = -1;
                                    errorColumn = -1; 
                                    yybegin(Comments);
                                   }
    "//"                           { yybegin(lineComment); }
   /////////////////////////////////////////////////////


   /////////////////////////////////////////////////////
   //////////////////[  WHITESPACE  ]///////////////////
   /////////////////////////////////////////////////////
    /* whitespace */
    {WhiteSpace}                   { /* ignore */ }
  /////////////////////////////////////////////////////


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
    ("..")+                       { string.append(yytext()) ; yybegin(decimalError);}
    "."                           { string.append(yytext());}
    "e"                           { yybegin(NaturalNumbers);
                                    string.append(yytext());}

     ///////////////////////////////////////////////////////////////////////
     //{numberN}       {string.append(yytext());yybegin(decimalError);}// si el numero es negativo
     //{simbolos}    {string.append(yytext());yybegin(decimalError);}// si hay mas de un punto 
     {Letars}        { } // si encuentra una letra manda a error de identificador  
    /////////////////////////////////////////////////////////////////////// 
  
    [^]                           {
                                    string.append(yytext());
                                    yybegin(errorNumeros);///////////////
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

























/////////////////////////////////////////////////////////
//------------PONCHO APLICA ERRO
/////////////////////////////////////////////////////////
///---------------[IDENTIFICADORES]--------------------//
/////////////////////////////////////////////////////////
<indetifierState> {
     (\n)  {
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador 1.1"));
                   yybegin(YYINITIAL);
                  }
     (;|"{")  {
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.1"));
                   string.setLength(0); 
                   string.append(yytext());
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "operador1.1"));
                   yybegin(YYINITIAL);
                  }
    (\ )+         {yybegin(SpaceStateDone);}  
    {simbolos}    {string.append(yytext()); yybegin(indetifierError);}
    {numberN}     {string.append(yytext());}
    {Identifier}  {string.append(yytext());}
    [^]           {}//------------PONCHO LLAMA A ERROR
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///---------------[ERROR IDENTIFICADOR]----------------//
/////////////////////////////////////////////////////////
<indetifierError> {
  (\n)  { 
                   errores.add(new Token(string.toString(), yyline, yycolumn, "Error de identificador2.1"));
                   yybegin(YYINITIAL);
                  }   
   ("{"\n| ";"\n)  {
                   errores.add(new Token(string.toString(), yyline, yycolumn, "Error de identificador2.2"));
                   string.setLength(0);
                   string.append(yytext());
                   string.setLength(1);
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "operador2.3"));
                   yybegin(YYINITIAL);
            } 
              
    {simbolos}    {string.append(yytext());}
    {numberN}     {string.append(yytext());}
    {Identifier}  {string.append(yytext());} 
    (\ )+          {yybegin(SpaceStateError);}   
    [^]          {}//------------PONCHO LLAMA A ERROR              
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[SPACE STATE ERROR]---------------//
/////////////////////////////////////////////////////////

<SpaceStateDone> {
     (\n)  {
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador 7.1"));
                   yybegin(YYINITIAL);
                  }
     ("{"\n| ";"\n)  { 
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador 7.1"));
                   string.setLength(0);
                   string.append(yytext());
                   string.setLength(1);
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "operador7.2"));
                   yybegin(YYINITIAL);
                  }  
    {simbolos}    {string.append(yytext());}
    {numberN}     {string.append(yytext());}
    {Identifier}  {string.append(yytext());} 
    (\ )+          {yybegin(SpaceStateDone);} 
      [^]          {}//------------PONCHO LLAMA A ERROR
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[SPACE STATE ERROR]---------------//
/////////////////////////////////////////////////////////
<SpaceStateError> {
      \n          {errores.add(new Token(string.toString(), yyline, yycolumn, "Error de identificador4.2"));
                   yybegin(YYINITIAL);
                   }
    
      ("{"|";")  {tokens.add(new Token(yytext().toString(), yyline, yycolumn, "operador4.1"));
                  yybegin(SpaceStateError);
                  }                           

      {simbolos}    {string.append(yytext());yybegin(indetifierError);}
      {numberN}     {string.append(yytext());yybegin(indetifierError);}
      {Identifier}  {string.append(yytext()); yybegin(indetifierError);} 
      (\ )+          {yybegin(SpaceStateError);}               
     // ("/")+         {yybegin(lineComment); }//ESTA VARA SE COME TODA LA LINEA 
      [^]          {}//------------PONCHO LLAMA A ERROR
}
/////////////////////////////////////////////////////////










/////////////////////////////////////////////////////////
///------------------[SELECT NUMBER]-------------------//
/////////////////////////////////////////////////////////
<selectNumber> {
     ({numberN} |"e"|"."|";" )+  {string.append(yytext());yybegin(numberState);}
     \n  {yybegin(numberState);}//PELIGRO COMENTAR
     [^] {string.append(yytext());yybegin(selectExtra);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[SELECT EXTRA]-------------------//
/////////////////////////////////////////////////////////
<selectExtra> {
     ({Letars}|{simbolos}*) {string.append(yytext());yybegin(indetifierError);}               
}
/////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////
///-----------------[ERROR DECIMAL]--------------------//
/////////////////////////////////////////////////////////
<decimalError> {
    (\n) {errores.add(new Token(string.toString(), yyline, yycolumn, "Error Decimal"));
                     string.setLength(0); 
                     yybegin(YYINITIAL);
                 }
    {simbolos}    {string.append(yytext());}
    {numberN}     {string.append(yytext());}
    {Letars}  {string.append(yytext());} 
    [^]          {string.append(yytext());}
}
/////////////////////////////////////////////////////////



























/////////////////////////////////////////////////////////
///------------------[ERROR NUMBER]-------------------//
/////////////////////////////////////////////////////////
<errorNumeros> {
  {WhiteSpace}                    {
                                    errores.add(new Token(string.toString(), yyline, yycolumn, "Error: numero mal formado")); 
                                    yybegin(YYINITIAL);
                                  }
  [^]                             {string.append(yytext());} 
}
/////////////////////////////////////////////////////////






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
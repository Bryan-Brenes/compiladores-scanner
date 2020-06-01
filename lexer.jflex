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


simbolosI       = "!"|"~"|"," |"."|
                 "(" | ")" |"[" | "]" | "?"|":" |"}"|"*=" |"/="                 

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

//PUNTO Y COMA
%state plusSimbolT
%state plusSimbolF


// CORCHETES
%state plusSimbolX
%state plusSimbolX1

//IGUAL 
%state plusSimbolT1
%state plusSimbolF1

//DOBLE AND 
%state plusSimbolT2
%state plusSimbolF2

//DOBLE IGUAL
%state plusSimbolT3
%state plusSimbolF3

//DIFERNETE IGUAL
%state plusSimbolT4
%state plusSimbolF4

//TECHO
%state plusSimbolT5
%state plusSimbolF5

//UNA O
%state plusSimbolT6
%state plusSimbolF6

//UNA &
%state plusSimbolT7
%state plusSimbolF7

//UNA |
%state plusSimbolT8
%state plusSimbolF8

//"<="
%state plusSimbolT9
%state plusSimbolF9

//">="
%state plusSimbolT10
%state plusSimbolF10

//">"
%state plusSimbolT11
%state plusSimbolF11


//"<"
%state plusSimbolT12
%state plusSimbolF12

//"+="
%state plusSimbolT13
%state plusSimbolF13

//"-="
%state plusSimbolT14
%state plusSimbolF14

// +
%state plusSimbolT15
%state plusSimbolF15


//-
%state plusSimbolT16
%state plusSimbolF16


//"*" 
%state plusSimbolT17
%state plusSimbolF17

//"%" 
%state plusSimbolT18
%state plusSimbolF18


//**
%state plusSimbolT19
%state plusSimbolF19


//<<
%state plusSimbolT20
%state plusSimbolF20

//>>
%state plusSimbolT21
%state plusSimbolF21

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
    ( "-"*  {numbersH}* + ("..")+  "-"*{numbersH}* )        { string.setLength(0); string.append(yytext());errores.add(new Token(yytext(), yyline, yycolumn, "Error Decimal"));}
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

//---------------------------------[LIMPIO]-------------------------------------//
//---------------------------------[INICIO]-------------------------------------//

/////////////////////////////////////////////////////////
//------------PONCHO APLICA ERRO
/////////////////////////////////////////////////////////
///---------------[IDENTIFICADORES]--------------------//
/////////////////////////////////////////////////////////
<indetifierState> {
     (\ )+         {}    
     (\n)  {
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador 1.1"));
                   yybegin(YYINITIAL);
                  }
    (";")      {yybegin(plusSimbolT);}
    ("{")      {yybegin(plusSimbolT1);}     
    ("=")      {yybegin(plusSimbolX);} 
    ("&&")     {yybegin(plusSimbolT2);}  
    ("==")     {yybegin(plusSimbolT3);}  
    ("!=")     {yybegin(plusSimbolT4);}  
    ("^")      {yybegin(plusSimbolT5);}  
    ("||")     {yybegin(plusSimbolT6);} 
    ("&")      {yybegin(plusSimbolT7);}   
    ("|")      {yybegin(plusSimbolT8);}    
    ("<=")     {yybegin(plusSimbolT9);}  
    (">=")     {yybegin(plusSimbolT10);}  
    (">")     {yybegin(plusSimbolT11);}  
    ("<")     {yybegin(plusSimbolT12);}  
    ("+=")     {yybegin(plusSimbolT13);}
    ("-=")     {yybegin(plusSimbolT14);} 
    ("+")     {yybegin(plusSimbolT15);}
    ("-")     {yybegin(plusSimbolT16);}
    ("*")     {yybegin(plusSimbolT17);}  
    ("%")     {yybegin(plusSimbolT18);} 
    ("**")     {yybegin(plusSimbolT19);}
    ("<<")     {yybegin(plusSimbolT20);}    
    (">>")     {yybegin(plusSimbolT21);}                        
    ("{"\n| ";"\n)  {
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2"));
                   string.setLength(0);
                   string.append(yytext());
                   string.setLength(1);
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "operador1.3"));
                   yybegin(YYINITIAL);
                  }                  
    ("{//"|";//") {
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.4"));
                   string.setLength(0);
                   string.append(yytext());
                   string.setLength(1);
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "operador1.5"));
                   yybegin(lineComment);           
    }    
    {simbolosI}    {string.append(yytext()); yybegin(indetifierError);}
    {numberN}     {string.append(yytext());}
    {Identifier}  {string.append(yytext());}
    [^]           {}//------------PONCHO LLAMA A ERROR
}
/////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////
//------------PONCHO APLICA ERRO
/////////////////////////////////////////////////////////
///---------------[ERROR IDENTIFICADOR]----------------//
/////////////////////////////////////////////////////////
<indetifierError> {
  (\ )+          {}  
  (\n)  { 
                   errores.add(new Token(string.toString(), yyline, yycolumn, "Error de identificador2.1"));
                   yybegin(YYINITIAL);
                  }
   (";"| (\ )+)      {yybegin(plusSimbolF);}
   ("{"| (\ )+)      {yybegin(plusSimbolF1);} 
   ("=")             {yybegin(plusSimbolX1);}
   ("&&")            {yybegin(plusSimbolF2);}  
   ("==")            {yybegin(plusSimbolF3);}  
   ("!=")            {yybegin(plusSimbolF4);}  
   ("^")             {yybegin(plusSimbolF5);}   
   ("||")             {yybegin(plusSimbolF6);} 
   ("&")             {yybegin(plusSimbolF7);} 
   ("|")             {yybegin(plusSimbolF8);}  
   ("<=")     {yybegin(plusSimbolT9);}
   (">=")     {yybegin(plusSimbolF10);}
   (">")     {yybegin(plusSimbolF11);}  
   ("<")     {yybegin(plusSimbolF12);}
    ("+=")     {yybegin(plusSimbolF13);}
    ("-=")     {yybegin(plusSimbolF14);}
    ("+")     {yybegin(plusSimbolF15);}
    ("-")     {yybegin(plusSimbolF16);}
    ("*")     {yybegin(plusSimbolF17);}  
    ("%")     {yybegin(plusSimbolF18);} 
     ("**")     {yybegin(plusSimbolF19);}
    ("<<")     {yybegin(plusSimbolF20);}
    (">>")     {yybegin(plusSimbolF21);}       
   ("{"\n| ";"\n)  {
                   errores.add(new Token(string.toString(), yyline, yycolumn, "Error de identificador2.2"));
                   string.setLength(0);
                   string.append(yytext());
                   string.setLength(1);
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "operador2.3"));
                   yybegin(YYINITIAL);
            } 
    ("{//"|";//") {
                   errores.add(new Token(string.toString(), yyline, yycolumn, "Error de identificador2.5"));
                   string.setLength(0);
                   string.append(yytext());
                   string.setLength(1);
                   tokens.add(new Token(string.toString(), yyline, yycolumn, "operador2.6"));
                   yybegin(lineComment);           
    } 
    ("//") {       errores.add(new Token(string.toString(), yyline, yycolumn, "Error de identificador2.4"));
                   yybegin(lineComment);           
    } 
          
    {simbolos}   {string.append(yytext());}
    {numberN}     {string.append(yytext());}
    {Identifier}  {string.append(yytext());} 
    
    [^]          {}//------------PONCHO LLAMA A ERROR              
}
/////////////////////////////////////////////////////////




/////////////////////////////////////////////////////////
//------------PONCHO ACA HAY UN PROBLEMA 
/////////////////////////////////////////////////////////
///------------------[SELECT NUMBER]-------------------//
/////////////////////////////////////////////////////////
<selectNumber> {
     ({numberN} |"e"|"."|";" )+  {string.append(yytext());yybegin(numberState);}
     \n  {yybegin(numberState);}//PELIGRO COMENTAR
     {Letars} {string.append(yytext());yybegin(indetifierError);}    
     [^] {string.append(yytext());yybegin(selectExtra);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[SELECT EXTRA]-------------------//
/////////////////////////////////////////////////////////
<selectExtra> {
     ({Letars}|{simbolos}) {string.append(yytext());yybegin(indetifierError);}               
}
/////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////












//------------------------------[PUNTO Y COMA]----------------------------------//
//---------------------------------[INICIO]-------------------------------------//

/////////////////////////////////////////////////////////
///--------------[PUNTO Y COMA TRUE]-------------------//
/////////////////////////////////////////////////////////
<plusSimbolT> {
   (\n| \ )  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token(";", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {string.append(";");string.append(yytext());yybegin(indetifierError);} 
   {simbolos}    {string.append(";");string.append(yytext());yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////
///--------------[PUNTO Y COMA FALSE]-------------------//
/////////////////////////////////////////////////////////
<plusSimbolF> {
   (\n| \ )  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token(";", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {string.append(";");string.append(yytext());yybegin(indetifierError);} 
   {simbolos}    {string.append(";");string.append(yytext());yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//------------------------------[PUNTO Y COMA]----------------------------------//
//----------------------------------[FIN]--------------------------------------//



//------------------------------[ CORCHETES ]----------------------------------//
//----------------------------------[INICIO]-----------------------------------//

/////////////////////////////////////////////////////////
///-----------------[CORCHETE TRUE]--------------------//
/////////////////////////////////////////////////////////
<plusSimbolT1> {
   (\n| \ )  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("{", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {string.append("{");string.append(yytext());yybegin(indetifierError);} 
   {simbolos}    {string.append("{");string.append(yytext());yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////
///---------------[CORCHETE  FALSE]--------------------//
/////////////////////////////////////////////////////////
<plusSimbolF1> {
   (\n| \ )  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("{", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {string.append("{");string.append(yytext());yybegin(indetifierError);} 
   {simbolos}    {string.append("{");string.append(yytext());yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//------------------------------[ CORCHETES ]----------------------------------//
//---------------------------------[FIN]---------------------------------------//














//--------------------------------[ IGUAL ]----------------------------------//
//--------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolX> {
   (\n| \ | {Identifier}|{numberN})  {  
                                       tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                                       tokens.add(new Token("=", yyline, yycolumn, "operador1.3.p"));
                                       yybegin(YYINITIAL);
                                       }
   {Identifier}  {yybegin(YYINITIAL);} 
   {simbolos}    {yybegin(YYINITIAL);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[IGUAL FALSE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolX1> {
   (\n| \ | {Identifier}|{numberN})  { errores.add(new Token(string.toString(), yyline, yycolumn, "ERROR identificador1.2.pPP"));
                                        tokens.add(new Token("=", yyline, yycolumn, "operador1.3.p"));
                                        yybegin(YYINITIAL);
                                        }
   {Identifier}  {yybegin(YYINITIAL);} 
   {simbolos}    {yybegin(YYINITIAL);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//




//----------------------------[ DOBLE AND ]----------------------------------//
//-------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE AND TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT2> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("&&", yyline, yycolumn, "operador1.3.p"));
                  yybegin(YYINITIAL);
                  }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE AND FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF2> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("&&", yyline, yycolumn, "operador1.3.p"));
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE AND ]----------------------------------//
//----------------------------------[FIN]----------------------------------//



//----------------------------[ DOBLE IGUAL ]----------------------------------//
//-------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT3> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("==", yyline, yycolumn, "operador1.3.p"));
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF3> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("==", yyline, yycolumn, "operador1.3.p"));
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//







//----------------------------[ DOBLE IGUAL ]----------------------------------//
//-------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT4> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("!=", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF4> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("!=", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//






//----------------------------[ DOBLE IGUAL ]----------------------------------//
//-------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT5> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("^", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF5> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("^", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//




//----------------------------[ DOBLE IGUAL ]----------------------------------//
//-------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT6> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("||", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF6> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("||", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//




//----------------------------[ DOBLE IGUAL ]----------------------------------//
//-------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT7> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("&", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF7> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("&", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//





//----------------------------[ DOBLE IGUAL ]----------------------------------//
//-------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT8> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("|", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF8> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("|", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//





 

//----------------------------[ DOBLE IGUAL ]----------------------------------//
//-------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT9> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("<=", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF9> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("<=", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//



//----------------------------[ DOBLE IGUAL ]----------------------------------//
//-------------------------------[INICIO]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT10> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token(">=", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF10> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token(">=", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//



// (">")     {yybegin(plusSimbolT11);}  ("<")     {yybegin(plusSimbolT11);}
 


/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT11> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token(">", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF11> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token(">", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//



/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT12> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("<", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF12> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("<", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//




/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT13> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("+=", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////
///------------------[DOBLE IGUAL FLASE]----------------------//
/////////////////////////////////////////////////////////
<plusSimbolF13> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("+=", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//




/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT14> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("-=", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



// /////////////////////////////////////////////////////////
// ///------------------[DOBLE IGUAL FLASE]----------------------//
// /////////////////////////////////////////////////////////
<plusSimbolF14> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("-=", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
 }
// /////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//





/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT15> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("+", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



// /////////////////////////////////////////////////////////
// ///------------------[DOBLE IGUAL FLASE]----------------------//
// /////////////////////////////////////////////////////////
<plusSimbolF15> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("+", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
 }
// /////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//



/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT16> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("-", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



// /////////////////////////////////////////////////////////
// ///------------------[DOBLE IGUAL FLASE]----------------------//
// /////////////////////////////////////////////////////////
<plusSimbolF16> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("-", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
 }
// /////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//







/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT17> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("*", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



// /////////////////////////////////////////////////////////
// ///------------------[DOBLE IGUAL FLASE]----------------------//
// /////////////////////////////////////////////////////////
<plusSimbolF17> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("*", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
 }
// /////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//




/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT18> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("%", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



// /////////////////////////////////////////////////////////
// ///------------------[DOBLE IGUAL FLASE]----------------------//
// /////////////////////////////////////////////////////////
<plusSimbolF18> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("%", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
 }
// /////////////////////////////////////////////////////////



//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//

/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT19> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("**", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



// /////////////////////////////////////////////////////////
// ///------------------[DOBLE IGUAL FLASE]----------------------//
// /////////////////////////////////////////////////////////
<plusSimbolF19> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("**", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
 }
// /////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//






/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT20> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token("<<", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



// /////////////////////////////////////////////////////////
// ///------------------[DOBLE IGUAL FLASE]----------------------//
// /////////////////////////////////////////////////////////
<plusSimbolF20> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token("<<", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
 }
// /////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//








/////////////////////////////////////////////////////////
///------------------[ DOBLE IGUAL TRUE ]---------------------//
/////////////////////////////////////////////////////////
<plusSimbolT21> {
   (\n| \ | {Identifier}|{numberN})  {    tokens.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.p"));
                  tokens.add(new Token(">>", yyline, yycolumn, "operador1.3.p"));
                  
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
}
/////////////////////////////////////////////////////////



// /////////////////////////////////////////////////////////
// ///------------------[DOBLE IGUAL FLASE]----------------------//
// /////////////////////////////////////////////////////////
<plusSimbolF21> {
   (\n| \ | {Identifier}|{numberN})  {    errores.add(new Token(string.toString(), yyline, yycolumn, "identificador1.2.pPP"));
                  tokens.add(new Token(">>", yyline, yycolumn, "operador1.3.p"));                
                  yybegin(YYINITIAL);
          }
   {Identifier}  {yybegin(indetifierError);} 
   {simbolos}    {yybegin(indetifierError);}   
 }
// /////////////////////////////////////////////////////////

//--------------------------------[ DOBLE IGUAL ]----------------------------------//
//----------------------------------[FIN]----------------------------------//










/////////////////////////////////////////////////////////
//------------PONCHO APLICA ERRO
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
    {Letars}      {string.append(yytext());} 
    [^]       {}//------APLICA ACA 
}
/////////////////////////////////////////////////////////


//---------------------------------[LIMPIO]-------------------------------------//
//---------------------------------[FINAL]-------------------------------------//






















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
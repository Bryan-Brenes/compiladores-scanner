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

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} | {DocumentationComment}

TraditionalComment   = "/*" [^*] ~"*/" | "/*" "*"+ "/"
// Comment can be the last line of the file, without line terminator.
EndOfLineComment     = "//" {InputCharacter}* {LineTerminator}?
DocumentationComment = "/**" {CommentContent} "*"+ "/"
CommentContent       = ( [^*] | \*+ [^/*] )*

Identifier = [:jletter:] [:jletterdigit:]*

DecIntegerLiteral = 0 | [1-9][0-9]*

%state STRING

%%

/* keywords */
<YYINITIAL> "address" | "as" | "bool" | "break" | "byte" | "bytes"((3[0-2])|([1-2][0-9])|[1-9])? |
"constructor" | "continue" | "contract" | "delete" | "do" | "else" | "enum" | "false" | "for" | "hex" | "from" | "function" |
"if" | "import" | "int"(256|128|64|32|16|8)? | "internal" | "mapping" | "modifier" | "payable" | "pragma" | "private" |
"public" | "return" | "returns" | "solidity" | "string" | "struct" | "this" | "true" | "ufixed" | "uint"(256|128|64|32|16|8)? |
"var" | "view" | "while" { tokens.add(new Token(yytext().trim(), yyline, yycolumn, "Parabra reservada"));}

<YYINITIAL> "boolean"            { tokens.add(new Token(yytext(), yyline, yycolumn, "Palabra reservada"));}
<YYINITIAL> "break"              { tokens.add(new Token(yytext(), yyline, yycolumn, "Palabra reservada"));}

<YYINITIAL> {
    /* identifiers */
    {Identifier}                   { tokens.add(new Token(yytext(), yyline, yycolumn, "Identificador"));}

    /* literals */
    {DecIntegerLiteral}            { tokens.add(new Token(yytext(), yyline, yycolumn, "Literal numerico"));}
    \"                             { string.setLength(0); yybegin(STRING); }

    /* operators */
    "="                            { tokens.add(new Token(yytext(), yyline, yycolumn, "Operador igual"));}
    "=="                           { tokens.add(new Token(yytext(), yyline, yycolumn, "Operador igual igual"));}
    "+"                            { tokens.add(new Token(yytext(), yyline, yycolumn, "Operador suma"));}

    /* comments */
    {Comment}                      { /* ignore */ }

    /* whitespace */
    {WhiteSpace}                   { /* ignore */ }
}

<STRING> {
    \"                             {
                                    yybegin(YYINITIAL);
                                    tokens.add(new Token(string.toString(), yyline, yycolumn, "Literal string"));
                                   }
    [^\n\r\"\\]+                   { string.append( yytext() ); }
    {Identifier}                   { string.append( yytext() ); }
}

/* error fallback */
[^]                              { throw new Error("Illegal character <"+ yytext()+">"); }
%{

#include "scanner.hh"
#include <fstream>
#include <string>
#define YY_DECL int Scanner::yylex()

struct token
    {
      enum yytokentype
      {
        MNEMONIC = 258,
        NUMBER = 259,
        IDENTIFIER = 260,
        LOGICAL_OP=261,
        ARITH_OP=262,
        BRACKETS=263,
        BASE_TYPE=264,
        UNARY_OP=265,
        EOFILE = 266,
        OTHERS = 267,
        INCLUDES= 268,
        SYMBOL=269,
        OTHER_OPERATIONS=270,
      };
    };
%}


/* %option debug */
%option nodefault
%option yyclass="Scanner"
%option noyywrap
%option c++

%%

%{          /** Code executed at the beginning of yylex **/
      FlexLexer::yy_flex_debug = 1;
%}
[ \t]                                       //skip
struct|return|for|while|include|if|for|while          return token::MNEMONIC;
(-?)[[:digit:]]+|[[:digit:]]*"."[[:digit:]]*                            return token::NUMBER;
"#"[[:alpha:]][[alpha]]*                    return token::INCLUDES;    
int|float|void|int"*"|void"*"|float"*"                              return token::BASE_TYPE;
[a-zA-Z][a-zA-Z0-9]*                          return token::IDENTIFIER;
";"                                         return ';';
"="                                         return token::OTHER_OPERATIONS;
OR_OP|AND_OP|EQ_OP|NE_OP|LE_OP|GE_OP|"<"|">"  return token::LOGICAL_OP;
"+"|"-"|"*"|"/"                             return token::ARITH_OP;
"_"|"!"|"&"|"++"                               return token::UNARY_OP;
","                                         return ',';
"("                                         return '(';
")"                                         return ')';
"["                                         return '[';
"]"                                         return ']';
"{"                                         return '{';
"}"                                         return '}';
":"                                         return ':';    
"\n"                                        return '\n';
<<EOF>>                                  yyterminate();
.				                          return token::OTHERS;
%%

std::string tok_to_string(int tok) 

{
  std::string strval;
   if (tok < 255)
    {
      
      strval = (char)tok;
      return strval;
    }
   else 
    {
      switch ((token::yytokentype) tok) 
      {
        case token::MNEMONIC: return "MNEMONIC";
        case token::ARITH_OP: return "ARITH_OP";
        case token::LOGICAL_OP: return "LOGICAL_OP";
        case token::IDENTIFIER: return "IDENTIFIER";
        case token::BASE_TYPE: return "BASE_TYPE";
        case token::BRACKETS: return "BRACKETS";
        case token::UNARY_OP: return "UNARY_OP";
        case token::INCLUDES: return "INCLUDES";
        case token::OTHERS: return "OTHERS";
        case token::NUMBER: return "NUMBER";
        case token::SYMBOL: return "SYMBOL";
        case token::OTHER_OPERATIONS: return "OTHER_OPERATIONS";
        case token::EOFILE: return "EOFILE";
    }
  }
  return "";
}

int main( int /* argc */, char** /* argv */ )
{ 
  using namespace std;
  fstream in_file, out_file;
  in_file.open("test-c.c", ios::in);
  out_file.open("test-c.output", ios::out);
  Scanner scanner(in_file, out_file);
  int tok = scanner.yylex ();

  while(tok != 0)
    {
      out_file << "_______________________________" << endl;
      out_file << "The token is : ";
      out_file << tok_to_string(tok) << endl;
      out_file << "The lexeme is : ";
      out_file << scanner.YYText() << endl;
      tok = scanner.yylex();
    }
  return 0;

}

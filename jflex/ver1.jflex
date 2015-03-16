/*David Cobbley
 *Autolight  
 */


%%

%standalone


%class jParse

//   jflex ver1.jflex 
//   javac jParse.java
//
// The resulting program can then be run as follows:
//   
//   java jParse sample.txt  > out.tex

//Print out the body statement for HTML

%init{
  System.out.println("");
  System.out.println("\\documentclass{article}");
  System.out.println("\\usepackage[utf8]{inputenc}");
  System.out.println("\\usepackage{amsmath,amssymb,amsthm,tabu,enumerate,tikz}");
  System.out.println("\\usepackage[margin=1in]{geometry}");
  System.out.println("\\usepackage{verbatim} % Allows Multi-line comments ");
  System.out.println("\\usepackage{multicol}");
  System.out.println("\\usetikzlibrary{automata,positioning}");
  System.out.println("\\newcommand{\\encode}[1]{\\langle #1 \\rangle}");
  System.out.println("\\usepackage{paralist}");
  System.out.println("  \\let\\enumerate\\compactenum");
  System.out.println("\\title{Midterm Solutions}");
  System.out.println("\\author{dcobbley }");
  System.out.println("\\date{March 2015}");
  System.out.println("\\begin{document}");
  System.out.println("\\maketitle");

%init}

// There is a similar %eof feature that allows us to specify code that
// will be executed when the program reaches the end of the input file.
// This provides a convenient place for us to put the code that produces
// the HTML lines that are required at the end of every output file:

%eof{
  System.out.println("\\end{document}");
%eof}

//straight output.
%{
  void echo() {
    int len = yylength();       // Find length of current lexeme
    for (int i=0; i<len; i++) { // Run through each character in turn
      char c = yycharat(i);
      switch (c) {              // and translate as appropriate ...
        case '<' : System.out.print("$<$");  break;
        case '>' : System.out.print("$>$");  break;
        case '&' : System.out.print("\\&"); break;
        case '|' : System.out.print("$|$"); break;
        default  : System.out.print(c);       break;
      }
    }
  }
%}


//<a href="clock://1230">1230</a>

//Tag for coloring
%{
  void tag(String cl) {
    System.out.print("<a href=\"" + cl + "://");
    echo();
    System.out.print("\">");
    echo();
    System.out.print("</a>");
  }
%}
//Tag for coloring HTTP
%{
  void tagHttp(String cl) {
    System.out.print("<a href=\"" + cl);
    echo();
    System.out.print("\">");
    echo();
    System.out.print("</a>");
  }
%}



// The parameter cl is used to specify a particular token class/style;
// given the opening lines of HTML shown above, this should be one of
// "keyword", "comment", "literal", or "invalid".  We can define some
// quick helper methods for each of these four cases as follows:

%{
  void clock() { tag("clock"); }
  void web() { tag("http"); }
  void mailto() { tag("mailto"); }
  void ping() { tag("ping"); }
  void invalid() { tag("invalid"); }
  void http() { tagHttp("");}
%}

// Now we are ready to give regular expressions for each of the input
// elements that can appear in a valid mini program.  We will use the
// following rules to specify the syntax of identifiers, whitespace,
// and comments:

Identifier         = [:jletter:] [:jletterdigit:]*

LineTerminator     = \r|\n|\r\n
WhiteSpace         = {LineTerminator} | [ \t\f] 

//Time
PMDot = [a|A|p|P] \. [m|M] \.
PMNoDot = [a|A|p|P] [m|M]
ClockAmPm = ([" "|\t|\n|\r]* {PMDot}|[" "|\t|\n|\r]* {PMNoDot})?

TIME = ([0|1]? [0-9]) : [0-5] [0-9] {ClockAmPm}  
NOTTIME = ({CHAR}|[0-9]) {TIME} 


HTTP = (http s? "://" )?
HTTPS = (http s? "://" )
//NOTHTTP = (http s? ":///" )?
CHAR = [a-zA-Z\+\.\_\-]+
EMAIL = [a-zA-Z\+_\-]+
NONCHAR =[^a-zA-Z0-9]
WEB = [a-zA-Z\+_\/]+
WEBNOSLASH = [a-zA-Z\+_]+

TWOFIFTYFIVE = ([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5]) 
IP = ({TWOFIFTYFIVE} \.) {3} {TWOFIFTYFIVE}


%%

// Once again, we can adopt the definitions for mini tokens that were
// provided in the original mini lexer.  We group the tokens here so
// that multiple patterns can be combined into a single regular expression
// and then share a single action.
/*
{NOTTIME} {echo();}
//Match time 12 hour
{TIME} /[^0-9] {clock();}

//Not 24hours
([0-1][0-9]|2[0-3])[0-5][0-9][0-9]  {echo();}

//match time 24 hour
([0-1][0-9]|2[0-3])[0-5][0-9]  {clock();}

//Non Email
{CHAR} \@ {EMAIL}+ \.{EMAIL}+ (\.{EMAIL}+){3} {echo();}

//Email
{CHAR} \@ {EMAIL}+ \.{EMAIL}+ (\.{EMAIL}+){0,2}  {mailto();}

//Non Web
{HTTP}{WEBNOSLASH} \. {WEB} (\. {WEB}){3} {echo();} 
//Non Web
{HTTP} \/ {WEBNOSLASH} \. {WEB} (\. {WEB}){0,2} {echo();} 

//http
{HTTPS} {WEBNOSLASH} \. {WEB} (\. {WEB}){0,2} {http();} 

//Web
{HTTP} {WEBNOSLASH} \. {WEB} (\. {WEB}){0,2} {web();} 

//IP Addresses
{IP} {ping();}

//Not Ip
[0-9\.]* {echo();}
*/
// Basic punctuation and operator symbols are echoed directly to the output
// without any syntax coloring:

","  | "["  | "]"  | "("  | ")"  | "{"  | "}" | ";" |
"="  | "==" | ">"  | ">=" | "<"  | "<=" | "!" | "~" |
"!=" | "&"  | "&&" | "|"  | "||" | "^"  | "*" | "+" |
"-" | "/"   | "."    { echo(); }

// Finally, identifiers and whitespace are output without any coloring
{Identifier}    { echo(); }
{WhiteSpace}    { echo(); }

//Anything we missed?
.|\n            { echo();
                }

// ---------------------------------------------------------------------

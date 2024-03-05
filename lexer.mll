{
  open Parser
  (* let string_to_bool str =
  match String.lowercase_ascii str with
  | "true"  -> true
  | "false" -> false *)
  exception UnknownToken of char 
  exception InvalidToken of string
}


let letters = ['a'-'z']
let digit_string = ['0'-'9']
let cap_letters = ['A'-'Z']
let underscore = '_'
let prime = '\''
let variables = (cap_letters|underscore)(digit_string|cap_letters|letters|underscore)*
let invalid_variables = (((prime|letters|digit_string)(letters|cap_letters|digit_string|prime|underscore)|((letters|cap_letters|digit_string|prime|underscore)*))  *)
let string_constants = '"' [^'"']* '"'
(* let bool_constants = "true"|"false"|"True" |"False"  *)
let float_constants = (digit_string+)"."(digit_string+)  (*Floats have been assumed to be of the format "int+ . int+" *)
let predicate = (letters)(digit_string|cap_letters|underscore|letters)*
let invalid_predicate = (digit_string|cap_letters|underscore)(digit_string|cap_letters|underscore|letters)*

rule token = parse
  [' ' '\t' '\n']+                               { token lexbuf }      (* skip blanks *)
| "is"                                           { IS }
| ['0'-'9']+ as i                                { INT_CONSTANT(int_of_string i) }
| float_constants as f                           { FLOAT_CONSTANT (float_of_string f) }
(* | bool_constants as b                            { BOOL_CONSTANT (string_to_bool b) } *)
| string_constants as s                          { STRING_CONSTANT(String.sub s 1 (String.length s - 2)) }
| variables as v                                 { VARIABLES(v) }
| predicate as p                                 { PREDICATE(p) }
| (invalid_variables | invalid_predicate) as i   { raise (InvalidToken(i)) }
| "->"                                           { IF_THEN }
| ":-"                                           { IMPLY }
| '('                                            { LPAREN }
| ')'                                            { RPAREN }
| '['                                            { LBRAC }
| ']'                                            { RBRAC }
| '.'                                            { DOT }
| ','                                            { COMMA }
| '!'                                            { CUT }
| '+'                                            { PLUS }
| '-'                                            { MINUS }
| '*'                                            { MUL }
| '/'                                            { DIV }
| '>'                                            { GREATER_THAN }
| '<'                                            { LESS_THAN }
| '='                                            { EQUALS }
| "<="                                           { LESS_EQ }
| ">="                                           { GREATER_EQ }
| "\\="                                          { NOT_EQ }
| "\\+"                                          { NEG }          (*have assumed if used, have been used just before predicate*)
| '|'                                            { PIPE }
| ';'                                            { OR_ELSE }
| eof                                            { EOF }
| _ as u                                         { raise (UnknownToken(u))}
(* Multiline / singleline comments may be added *)

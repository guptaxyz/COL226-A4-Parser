%{
    open Ast
%}

%token <int> INT_CONSTANT
%token <float> FLOAT_CONSTANT
// %token <bool> BOOL_CONSTANT
%token <string> STRING_CONSTANT VARIABLES PREDICATE ERROR_INVALID 
%token <char> ERROR_UNKNOWN_CHARACTER
%token PLUS MINUS MUL DIV IMPLY 
%token LPAREN RPAREN LBRAC RBRAC
%token GREATER_THAN LESS_THAN EQUALS LESS_EQ GREATER_EQ NOT_EQ NEG
%token DOT COMMA CUT EOF PIPE OR_ELSE IF_THEN IS


%left PIPE OR_ELSE
%left COMMA
%nonassoc EQUALS NOT_EQ LESS_THAN GREATER_THAN GREATER_EQ LESS_EQ 
%left PLUS MINUS
%left MUL DIV
%left IF_THEN
%nonassoc IS
%nonassoc UMINUS NEG 
%nonassoc DOT

%start program goal             
%type <Ast.program> program
%type <Ast.goal> goal

%%
// A program is a sequence of clauses. 

// • A clause can either be a fact or a rule.
// • A fact has a head but no body. A rule has a head and a body.  

// • The head is a single atomic formula.
// • A body is a sequence of atomic formulas.
// • An atomic formula is a k-ary predicate symbol followed by k terms.
// • A term is either a variable, a constant, or a k-ary function symbol with k
// subterms.
// • A goal is a sequence of atomic formulas.

program:
    EOF                         { [] }
    | seq_clause EOF            { $1 }
    ;
 
seq_clause:
    clause                      { [$1] }
    | clause seq_clause         { ($1)::$2 }
    ;

clause:
    atom DOT                                                        { Fact(Head($1)) }
    | head IMPLY body DOT                                           { Rule(Head($1),Body($3)) }
    | head IMPLY LPAREN body RPAREN DOT                             { Rule(Head($1),Body($4)) }
    | atom_seq IF_THEN atom_comma_seq OR_ELSE atom_comma_seq DOT    { IfThenElse($1,$3,$5)} 
    ;

goal:
    atom_seq  DOT               {Goal($1)}

head:
    atom                        { $1 }
    ;

body:
    atom_seq                    { $1 }
    ;

atom_seq:
    atom                              { A($1) }
    | atom OR_ELSE atom_seq           { Or($1,$3) }
    | atom COMMA atom_seq             { And($1,$3) }
    ;

atom_comma_seq:
    atom                                    { A($1) }
    | atom COMMA atom_comma_seq             { And($1,$3) }
    ;

atom:
    PREDICATE                                         { Atom($1,[]) }  
    | PREDICATE LPAREN term_seq RPAREN                { Atom($1, $3) }
    | NEG PREDICATE LPAREN term_seq RPAREN            { Atom(Ast.concat (Ast.concat "Neg ( " $2) " )",$4) }   
    | term EQUALS term                                { Atom("0_EQ", [$1; $3]) }
    | term NOT_EQ term                                { Atom("1_NEQ", [$1; $3]) }
    | term LESS_THAN term                             { Atom("<", [$1; $3]) }
    | term GREATER_THAN term                          { Atom(">", [$1; $3]) }
    | term LESS_EQ term                               { Atom("<=", [$1; $3]) }
    | term GREATER_EQ term                            { Atom(">=", [$1; $3]) }
    | CUT                                             { Atom("2_CUT", []) }
    | term IS term                                    { Atom("3_IS",[$1;$3]) }                     
    ;

term_seq:
    term                              { [$1] }
    | term COMMA term_seq             { ($1)::$3 }
    ;

term:
    VARIABLES                                         { Var($1) }
    | INT_CONSTANT                                    { Int($1) }
    | FLOAT_CONSTANT                                  { Float($1) }
    | STRING_CONSTANT                                 { Str($1) }
    | PREDICATE                                       { Operation($1,[]) }
    | int_term PLUS int_term                          { Operation("+",[$1;$3]) }
    | int_term MINUS int_term                         { Operation("-",[$1;$3]) }
    | int_term MUL int_term                           { Operation("*",[$1;$3]) }
    | int_term DIV int_term                           { Operation("/",[$1;$3]) }
    | MINUS int_term %prec UMINUS                     { Operation("~",[$2]) }
    | PREDICATE LPAREN term_seq RPAREN                { Operation($1,$3) }
    | list                                            { $1 }

int_term:
    VARIABLES                                         { Var($1) }
    | INT_CONSTANT                                    { Int($1) }
    | FLOAT_CONSTANT                                  { Float($1) }
    | PREDICATE                                       { Operation($1,[]) }
    | PREDICATE LPAREN term_seq RPAREN                { Operation($1,$3) }
    | int_term PLUS int_term                          { Operation("+",[$1;$3]) }
    | int_term MINUS int_term                         { Operation("-",[$1;$3]) }
    | int_term MUL int_term                           { Operation("*",[$1;$3]) }
    | int_term DIV int_term                           { Operation("/",[$1;$3]) }
    | MINUS int_term %prec UMINUS                     { Operation("~",[$2]) }


list:
    LBRAC RBRAC                               { Operation("Empty_List",[]) }        //Since, operations can only have predicates as first element thus, no caps occupied
    | LBRAC list_elements RBRAC               { $2 }

list_elements:
    term                                           { Operation("List", [$1; Operation("Empty_List",[])]) }
    | term COMMA list_elements                     { Operation("List", [$1; $3]) }
    | term PIPE term                               { Operation("List", [$1; $3]) }
    ;


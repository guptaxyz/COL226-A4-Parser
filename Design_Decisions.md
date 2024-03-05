# PARSER for PROLOG using OCamlYacc:

The lexer for the prolog has been defined in the file _"lexer.mll"_, the parser in _"parser.mly"_ and the datatype used across the parser and in the output in _"ast.ml"_ , meanwhile, _"run.ml"_ contains the code which links all these files together.

In order to output the abstract syntax tree of your .pl file using the parser, use the below format in the command line:

```
$ make
$ ./run <.pl file>
```
## Design Decisions:

### Basic Design Decisions :

The abstract structure of a Prolog program is the following:
- A program is a sequence of clauses. 
- A clause can either be a fact or a rule.
- A fact has a head but no body. A rule has a head and a body.  
- The head is a single atomic formula.
- A body is a sequence of atomic formulas.
- An atomic formula is a k-ary predicate symbol followed by k terms.
- A term is either a variable, a constant, or a k-ary function symbol with k subterms.
- A goal is a sequence of atomic formulas.

### Specific Design Decisions/ Features :

- The parser implements many non-standard syntax of prolog as well, such as
    - _If-Then-Else_ : In prolog, If-then-Else is represented by ( Clause: a->b;c. ), where, a,b,c are atom sequences and the parser supports this. I have supported If_Then_Else for a clause.
    - _Or_ : have supported the use of Or (";") in-between atoms in addition to the standard And (","), thus, `Atom sequences, will support both the use of Or ";", And ","`
    - _Negation_ : "\\+" - supports the use of negation in-front of atoms
    - _Is_ : support the use of is in atoms ( Atom : _term is term_ )

- The parser supports nesting of terms, and stores Or, And seperators within Atoms in a nested fashion. However, in order to maintain the aestheticness of the tree, and easy visibility of the trees (all Atoms at a similar level), the tress are to be read with the design decision of, `'Or' as seperator between atoms where mentioned, otherwise 'And' as seperator`. 

### Testcases
 
```
$- Input: A>=0->print("A is non-negative");print("A is negative").

PROGRAM -->
        CLAUSE -->
                IF_THEN_ELSE -->
                        IF -->  (
                                ATOM -->
                                        GTE -->
                                                Variable :  A
                                                Int_const :  0
                                )
                        THEN --> (
                                ATOM -->
                                        Predicate : print
                                                String_const :  A is non-negative
                                 )
                        ELSE --> (
                                ATOM -->
                                        Predicate : print
                                                String_const :  A is negative
                                 )

$- Input: positive(A):-(A>0,print("A is positive");A<0,print("A is negative"); print("A is zero")).

PROGRAM -->
        CLAUSE -->
                RULE -->
                        HEAD -->
                                ATOM -->
                                        Predicate : positive
                                                Variable :  A
                        BODY -->
                                ATOM -->
                                        GT -->
                                                Variable :  A
                                                Int_const :  0
                                ATOM -->
                                        Predicate : print
                                                String_const :  A is positive
                           ||
                        Or ||
                           ||
                                ATOM -->
                                        LT -->
                                                Variable :  A
                                                Int_const :  0
                                ATOM -->
                                        Predicate : print
                                                String_const :  A is negative
                           ||
                        Or ||
                           ||
                                ATOM -->
                                        Predicate : print
                                                String_const :  A is zero

$- Input: append([H|T1], L2, [H|T3]) :- append(T1, L2, T3).

PROGRAM -->
        CLAUSE -->
                RULE -->
                        HEAD -->
                                ATOM -->
                                        Predicate : append
                                                List: [
                                                         Variable :  H
                                                         Variable :  T1
                                                      ]
                                                Variable :  L2
                                                List: [
                                                         Variable :  H
                                                         Variable :  T3
                                                      ]
                        BODY -->
                                ATOM -->
                                        Predicate : append
                                                Variable :  T1
                                                Variable :  L2
                                                Variable :  T3
```

##### ADITYA GUPTA
##### 2021CS10554

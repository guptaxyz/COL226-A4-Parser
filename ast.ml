(* A program is a sequence of clauses. 

• A clause can either be a fact or a rule.
• A fact has a head but no body. A rule has a head and a body.  

• The head is a single atomic formula.
• A body is a sequence of atomic formulas.
• An atomic formula is a k-ary predicate symbol followed by k terms.
• A term is either a variable, a constant, or a k-ary function symbol with k
subterms.
• A goal is a sequence of atomic formulas. *)

type variable = string
type predicate = string (*| Neg of predicate*)
type term = Var of variable | Int of int | Float of float | Str of string  | Operation of predicate * term list (*Operation is basically a node, with first term denoting the operation/predicate*)
type atom = Atom of predicate * term list
type atom_seq = Or of atom * atom_seq | And of atom * atom_seq | A of atom
type goal = Goal of atom_seq
type body = Body of atom_seq
type head = Head of atom
type clause = Fact of head | Rule of head * body | IfThenElse of atom_seq * atom_seq * atom_seq
type program = clause list
;;

let concat (pred1:predicate) (pred2:predicate) : predicate =
  let x:string = pred1 and y:string = pred2 in
    let z:predicate = x^y in
      z

let rec print_term_seq (tl:term list)(s:string) = match tl with
    [] -> Printf.printf ""
  | [x] -> (print_term x s )
  | x :: xs ->  (print_term x s; Printf.printf "%s" s; print_term_seq xs s )


and print_list_body (t:term) (s:string) = match t with
    Operation("List", [t1; Operation("Empty_List", [])]) -> print_term t1 s
  | Operation("List", [t1; t2]) -> (
      print_term t1 s;
      Printf.printf " %s " s ;
      print_list_body t2 s;
    )
  | t1 -> print_term t1 s;


and print_term (t:term) (s:string) = match t with
  (* Var(v) -> Printf.printf " %s " v 
      *)
  Var(v) -> (Printf.printf "Variable : "; Printf.printf " %s " v ; Printf.printf "\n")
| Operation("Empty_List", []) -> Printf.printf "List: []\n"
| Operation(r, []) -> (Printf.printf "Function : "; Printf.printf " %s " r ; Printf.printf "\n")
| Operation("List", _) -> ( Printf.printf "List: [\n";
    Printf.printf " %s " (s^"\t") ;
    print_list_body t (s^"\t");
    Printf.printf " %s " s ;
    Printf.printf "     ]\n";
  )
| Int(n) -> (Printf.printf "Int_const : "; Printf.printf " %d " n ; Printf.printf "\n" )
| Float(f) -> (Printf.printf "Float_const : ";  Printf.printf " %f " f ; Printf.printf "\n" )
| Str(r) -> (Printf.printf "String_const : ";  Printf.printf " %s " r ; Printf.printf "\n" )
| Operation(k,l) -> (Printf.printf "Function : "; Printf.printf " %s " k; Printf.printf "\n"; Printf.printf " %s " s; Printf.printf "\t"; print_term_seq l (s^"\t")) 


and  print_tree (p:program) = 
  match p with
    [] -> Printf.printf ""
  | [x] -> (Printf.printf "\tCLAUSE -->\n"; 
  print_clause x "\t\t"; )
  | x :: xs -> (Printf.printf "\tCLAUSE -->\n"; 
                print_clause x "\t\t"; print_tree xs)

and print_clause (c:clause) (s: string)=
   match c with
    Fact(Head(h)) -> (Printf.printf "%s" s;Printf.printf "FACT -->\n"; Printf.printf "\t\t\tHEAD -->\n";print_atom h "\t\t\t\t" ) 
  | Rule(Head(h),Body(b)) -> (Printf.printf "%s" s;Printf.printf "RULE -->\n";Printf.printf "\t\t\tHEAD -->\n";print_atom h "\t\t\t\t";
                              Printf.printf "\t\t\tBODY -->\n";print_atom_seq b "\t\t\t")
  | IfThenElse(p,q,r) -> (Printf.printf "%s" s;Printf.printf "IF_THEN_ELSE -->\n";Printf.printf "\t\t\tIF -->  (\n";print_atom_seq p "\t\t\t";
  Printf.printf "\t\t\t\t)\n\t\t\tTHEN --> (\n"; print_atom_seq q "\t\t\t"; Printf.printf "\t\t\t\t )\n\t\t\tELSE --> (\n"; print_atom_seq r "\t\t\t"; 
  Printf.printf "\t\t\t\t )\n")
  (* | Goal() *)

and print_atom (h:atom) (s: string) = 
  Printf.printf "%s" s;
  Printf.printf "ATOM -->\n";
  match h with
  (* Atom(concat "~" p,q) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "NEG -->\n"; Printf.printf "%s" s; Printf.printf "\t\t"; 
  Printf.printf "Predicate : "; Printf.printf "%s" p; Printf.printf "%s" s; Printf.printf "\t\t\t" ; print_term_seq q (s^"\t\t\t")) *)
  |  Atom("0_EQ",[p;q]) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "EQ -->\n"; Printf.printf "%s" s; Printf.printf "\t\t"; 
    print_term p (s^"\t\t") ; Printf.printf "%s" s; Printf.printf "\t\t" ; print_term q (s^"\t\t"))
  | Atom("1_NEQ",[p;q]) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "NEQ -->\n"; Printf.printf "%s" s; Printf.printf "\t\t"; 
  print_term p (s^"\t\t") ; Printf.printf "%s" s; Printf.printf "\t\t" ; print_term q (s^"\t\t"))
  | Atom("<",[p;q]) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "LT -->\n"; Printf.printf "%s" s; Printf.printf "\t\t"; 
  print_term p (s^"\t\t"); Printf.printf "%s" s; Printf.printf "\t\t" ; print_term q (s^"\t\t"))
  | Atom(">",[p;q]) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "GT -->\n"; Printf.printf "%s" s; Printf.printf "\t\t"; 
  print_term p (s^"\t\t"); Printf.printf "%s" s; Printf.printf "\t\t" ; print_term q (s^"\t\t") )
  | Atom(">=",[p;q]) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "GTE -->\n"; Printf.printf "%s" s; Printf.printf "\t\t"; 
  print_term p (s^"\t\t") ; Printf.printf "%s" s; Printf.printf "\t\t" ; print_term q (s^"\t\t") )
  | Atom("<=",[p;q]) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "LTE -->\n"; Printf.printf "%s" s; Printf.printf "\t\t"; 
  print_term p (s^"\t\t") ; Printf.printf "%s" s; Printf.printf "\t\t" ; print_term q (s^"\t\t") )
  | Atom("2_CUT",[]) -> (Printf.printf "%s" s; Printf.printf "\tCUT";)
  | Atom("3_IS",[p;q]) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "is -->\n"; Printf.printf "%s" s; Printf.printf "\t\t"; 
  print_term p (s^"\t\t") ; Printf.printf "%s" s; Printf.printf "\t\t" ; print_term q (s^"\t\t") )
  | Atom(p,[]) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "Predicate : "; Printf.printf "%s" p; Printf.printf "\n")
  | Atom(p,q) -> (Printf.printf "%s" s; Printf.printf "\t"; Printf.printf "Predicate : "; Printf.printf "%s" p; Printf.printf "\n"; 
  Printf.printf "%s" s; Printf.printf "\t\t"; print_term_seq q (s^"\t\t"))

and print_atom_seq (h :atom_seq) (s: string)  =
  match h with
   Or(p,And(q,r)) -> (print_atom p (s^"\t");Printf.printf "%s" s; Printf.printf "   ||\n";Printf.printf "%s" s; Printf.printf "Or ||\n";Printf.printf "%s" s; Printf.printf "   ||\n";print_atom q (s^"\t");print_atom_seq r (s))
  | Or(p,Or(q,r)) -> (print_atom p (s^"\t");Printf.printf "%s" s; Printf.printf "   ||\n";Printf.printf "%s" s; Printf.printf "Or ||\n";Printf.printf "%s" s; Printf.printf "   ||\n";print_atom q (s^"\t");Printf.printf "%s" s; Printf.printf "   ||\n";Printf.printf "%s" s; Printf.printf "Or ||\n";Printf.printf "%s" s; Printf.printf "   ||\n";print_atom_seq r (s))
  | Or(p,A(q)) -> (print_atom p (s^"\t"); Printf.printf "%s" s; Printf.printf "   ||\n";Printf.printf "%s" s; Printf.printf "Or ||\n";Printf.printf "%s" s; Printf.printf "   ||\n";print_atom q (s^"\t"))
  | And(p,And(q,r)) -> (print_atom p (s^"\t");print_atom q (s^"\t");print_atom_seq r (s))
  | And(p,Or(q,r)) -> (print_atom p (s^"\t"); print_atom q (s^"\t");Printf.printf "%s" s; Printf.printf "   ||\n";Printf.printf "%s" s; Printf.printf "Or ||\n";Printf.printf "%s" s; Printf.printf "   ||\n";print_atom_seq r (s))
  | And(p,A(q)) -> (print_atom p (s^"\t"); print_atom q (s^"\t"))
  (* | And(p,q) -> (Printf.printf "%s" s; Printf.printf "And -->\n" ;print_atom p (s^"\t"); print_atom_seq q (s^"\t")) *)
  | A(a) -> print_atom a (s^"\t")

;; 

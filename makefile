make:
	ocamlc -c  ast.ml
	ocamlyacc  parser.mly
	ocamlc -c  parser.mli
	ocamlc -c  parser.ml
	ocamllex  lexer.mll
	ocamlc -c  lexer.ml
	ocamlc -c  run.ml
	ocamlc -o  run  ast.cmo  lexer.cmo  parser.cmo  run.cmo

clean:
	rm -f  lexer.ml  parser.ml  parser.mli
	rm -f *.c*
	rm -f  run
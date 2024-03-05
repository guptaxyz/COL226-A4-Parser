open Lexer;;
open Parser;;
open Ast;;

  if Array.length Sys.argv != 2 then begin
  Printf.printf "Recheck the Input command... It should be of the format:\n .\\run <prolog_file>\n";
  exit 0;
  end;;
  let fstream = open_in Sys.argv.(1);;
  let init_prog =  Parser.program  Lexer.token (Lexing.from_channel fstream);;
  Printf.printf "PROGRAM -->\n";
  print_tree init_prog;;
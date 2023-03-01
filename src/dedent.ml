open! Base
open! Import

let drop_last_line_if_empty lines =
  match List.last lines with
  | None -> []
  | Some last_line ->
    if String.is_empty last_line then List.take lines (List.length lines - 1) else lines
;;

let indentation lines =
  List.fold lines ~init:None ~f:(fun min line ->
    match String.findi line ~f:(fun _ c -> not (Char.is_whitespace c)) with
    | None -> min
    | Some (i, _) ->
      Some
        (match min with
         | None -> i
         | Some min -> Int.min i min))
;;

let drop_indentation lines =
  match indentation lines with
  | None -> lines
  | Some indentation ->
    List.map lines ~f:(fun line -> String.drop_prefix line indentation)
;;

let starts_with_line_prefix line =
  String.equal line ">" || String.is_prefix ~prefix:"> " line
;;

let drop_line_prefix line = String.drop_prefix line 2

let drop_line_prefix_if_present lines =
  if List.for_all lines ~f:starts_with_line_prefix
  then List.map lines ~f:drop_line_prefix
  else lines
;;

let lines string =
  let lines = String.split string ~on:'\n' in
  let lines = List.map lines ~f:String.rstrip in
  let lines = drop_last_line_if_empty lines in
  let lines =
    match lines with
    | [] -> []
    | "" :: rest -> drop_indentation rest
    | first :: rest -> String.lstrip first :: drop_indentation rest
  in
  drop_line_prefix_if_present lines
;;

let string input = String.concat (lines input) ~sep:"\n"

open! Base
open! Stdio
open! Import

(* We make spaces and newlines visible to make the behavior clearer, and so that changes
   in behavior cause diffs that need to be reviewed. *)
let make_whitespace_visible : string -> string =
  let module Search_pattern = String.Search_pattern in
  let replacements : (string -> string) list =
    [ "\n", "\\n"; " ", "_" ]
    |> List.map ~f:(fun (from, with_) ->
      let search_pattern = Search_pattern.create from in
      fun in_ -> Search_pattern.replace_all search_pattern ~in_ ~with_)
  in
  fun input -> List.fold replacements ~init:input ~f:(fun ac f -> f ac)
;;

let test input =
  let output = Dedent.string input in
  print_endline (output |> make_whitespace_visible)
;;

let%expect_test "single-line empty strings are empty" =
  test {||};
  [%expect {| |}];
  test {| |};
  [%expect {| |}];
  test {|  |};
  [%expect {| |}]
;;

let%expect_test "single-line strings ignore leading and trailing whitespace" =
  test {|a|};
  [%expect {| a |}];
  test {| a|};
  [%expect {| a |}];
  test {|a |};
  [%expect {| a |}];
  test {| a |};
  [%expect {| a |}];
  test {|  a  |};
  [%expect {| a |}]
;;

let%expect_test "multi-line empty strings drop the lines with the delimiters" =
  test
    {|
|};
  [%expect {| |}];
  test
    {|

|};
  [%expect {| |}];
  test
    {|


|};
  [%expect {| \n |}]
;;

let%expect_test "multi-line strings drops lines with delimiters" =
  test
    {|
a
|};
  [%expect {| a |}]
;;

let%expect_test "multi-line strings support leading and trailing blank lines" =
  test
    {|

a
|};
  [%expect {| \na |}];
  test
    {|
a

|};
  [%expect {| a\n |}];
  test
    {|

a

|};
  [%expect {| \na\n |}]
;;

let%expect_test "closing delimiter can be in any column" =
  test
    {|a
|};
  [%expect {| a |}];
  test
    {|a
 |};
  [%expect {| a |}];
  test
    {|a
  |};
  [%expect {| a |}]
;;

let%expect_test "strip trailing whitespace" =
  test "a \nb ";
  [%expect {| a\nb |}];
  test "a  \nb  ";
  [%expect {| a\nb |}]
;;

let%expect_test "drop min indentation" =
  test
    {|
a
 b
|};
  [%expect {| a\n_b |}];
  test
    {|
 a
  b
|};
  [%expect {| a\n_b |}];
  test
    {|
  a
   b
|};
  [%expect {| a\n_b |}];
  test
    {|
  a
  b
    |};
  [%expect {| a\nb |}];
  test
    {|
  a
 b
    |};
  [%expect {| _a\nb |}];
  test
    {|
  a
b
    |};
  [%expect {| __a\nb |}];
  (* This was added so [dedent] can be used to clean up doc comments, where it is not
     typical to start with a blank line. We could have instead used location information
     on the doc comment to figure out the first line's indentation, but we didn't want to
     build that behavior into the ppx. This lets us mostly achieve the same effect by
     inspecting the string contents alone. *)
  test
    {| a
          b
|};
  [%expect {| a\nb |}];
  (* Bad behavior, but also uncommon. Let's tell people to use line prefixes for that. *)
  test
    {|    deliberately indented more
         normal indentation
|};
  [%expect {| deliberately_indented_more\nnormal_indentation |}];
  (* Here's how you get the deliberate indentation of the first line. *)
  test
    {|>      deliberately indented more
         > normal indentation
|};
  [%expect {| _____deliberately_indented_more\nnormal_indentation |}]
;;

let%expect_test "drop line prefix" =
  test {| > a |};
  [%expect {| a |}];
  test
    {|
> a
|};
  [%expect {| a |}];
  test
    {|
> a
> b
|};
  [%expect {| a\nb |}]
;;

let%expect_test "line prefix must be followed by a space" =
  test {| >a |};
  [%expect {| >a |}]
;;

let%expect_test "drop line prefix after dropping indentation" =
  test
    {|
 > a
 >  b
|};
  [%expect {| a\n_b |}]
;;

let%expect_test "only drop line prefix if it is present on all lines" =
  test
    {|
> a
b
|};
  [%expect {| >_a\nb |}];
  test
    {|
> a
 > b
|};
  [%expect {| >_a\n_>_b |}]
;;

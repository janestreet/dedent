"Dedent"
========

`Dedent` is a library for improving readability of multi-line string
constants in code:

  - you can put string delimiters on their own lines
  - you can indent lines to the level of surrounding code
  - you can start each line with a line prefix, `> `

More precisely, on an input string, `Dedent` does the following:

  1. breaks the string into lines
  2. strips trailing whitespace from all lines
  3. drops the first line and the last line, if they are empty
  4. finds the line with the least indendation, and drops that indentation from all lines
  5. drops the line prefix from all lines, if it is present on all lines

For example:

```ocaml
let string =
  {|
  > a
  >  b
  >   c
  |} |> Dedent.string
```

That yields the string `"a\n b\n c"`.

Use `Dedent.lines` to dedent and return a list of lines rather than a
string.  For the above example, `Dedent.lines` yields:

    [ "a"; " b"; "  c" ]

Each of the aspects of `Dedent`'s input handling is optional.  You
don't have to use a line prefix.  This yields the same string:

```ocaml
let string =
  {|
  a
   b
    c
  |} |> Dedent.string
```

You don't have to indent.  This yields the same string:

```ocaml
let string =
  {|
a
 b
  c
|} |> Dedent.string
```

You don't have to put delimiters on their own lines.  This yields the
same string:

```ocaml
let string =
  {|a
 b
  c|} |> Dedent.string
```

There is also an extension syntax,
[`[%string_dedent]`](../../ppx/ppx_string_dedent/README.md), that is a
variant of `[%string]` that applies `[Dedent.string]` to its input
before substitution.  For example:

```ocaml
  let bar = "BAR" in
  let string =
    [%string_dedent
      {|
      > foo
      >   %{bar}
      |}]
  in
```

That yields the string `"foo\n  BAR"`.


#lang rhombus/scribble/manual
@(import:
    "common.rhm" open
    "nonterminal.rhm" open)

@(def dots = @rhombus(..., ~bind))
@(def dots_expr = @rhombus(...))

@title(~tag: "ref-operator"){Operators}

@doc(
  ~nonterminal:
    maybe_res_annot: fun ~defn

  defn.macro 'operator $op_case'
  defn.macro 'operator
              | $op_case
              | ...'
  defn.macro 'operator $op_or_id_name $maybe_res_annot:
                $option; ...
              | $op_case
              | ...'

  grammar op_case:
    $op_or_id_name $bind_term $impl_block
    $bind_term $op_or_id_name $bind_term $impl_block
    $bind_term $op_or_id_name $impl_block
    ($op_or_id_name $bind_term) $maybe_res_annot $impl_block
    ($bind_term $op_or_id_name $bind_term) $maybe_res_annot $impl_block
    ($bind_term $op_or_id_name) $maybe_res_annot $impl_block

  grammar impl_block:
    :
      $case_option; ...
      $body
      ...

  grammar case_option:
    option
    ~unsafe: $unsafe_body; ...

  grammar option:
    ~order $name
    ~order: $name
    ~stronger_than $other ...
    ~stronger_than: $other ...; ...
    ~weaker_than $other ...
    ~weaker_than: $other ...; ...
    ~same_as $other ...
    ~same_as: $other ...; ...
    ~same_on_left_as $other ...
    ~same_on_left_as: $other ...; ...
    ~same_on_right_as $other ...
    ~same_on_right_as: $other ...; ...
    ~associativity $assoc
    ~associativity: $assoc
    ~name $op_or_id_name
    ~name: $op_or_id_name
    ~who $id
    ~who: $id

  grammar other:
    $id
    $op
    ~other

  grammar assoc:
    ~left
    ~right
    ~none

  grammar bind_term:
    $bind
){

 Binds @rhombus(op_or_id_name) as a operator, either
 prefix, infix, postfix, or a combination.

 The operator is function-like in the sense that it receives argument
 values. (To bind an operator that is not function-like, see
 @rhombus(macro) or @rhombus(expr.macro, ~expr).) Each argument is specified by
 a binding that must be written as a single shrubbery term that is not an
 operator in the shrubbery sense; parentheses can be used around other
 binding forms for arguments. If two identifier terms appear within the
 parentheses that follow @rhombus(operator), a prefix operator is
 defined using the first identifier as its name. When a parenthesized
 sequence is followed by @rhombus(::, ~bind) or @rhombus(:~, ~bind), it
 is treated as starting a @rhombus(maybe_res_annot), which is the same
 as in @rhombus(fun) definitions.

 The new operator is also bound a @tech{repetition} operator, in which
 case its arguments must be repetitions. The depth of the resulting
 repetition is the maximum of the argument repetition depths.

 When multiple cases are provided via @vbar, an operator can be defined
 as both prefix and infix or prefix and postfix (but not infix and
 postfix). The prefix cases and infix/postfix cases can be mixed in any
 order, but when the operator is used as a prefix or infix/postfix
 operator, cases are tried in the relative order that they are written.
 Similar to the @rhombus(fun) form the operator name and a result
 annotation can be written before the @vbar cases to apply for all cases.

 At the start of an operator body, @rhombus(option)s can declare
 precedence, associativity (in the case of an infix operator), and/or
 naming options. Each @rhombus(option) keyword can appear at most once. The
 @rhombus(~order) option selects a @tech(~doc: meta_doc){operator order} for the operator, which
 defines precedence relationships to other operator orders and a default
 associativity, but precedence and associativity options with @rhombus(operator)
 override the ones defined with the operator order. In
 a precedence specification, a @rhombus(name) refers to another operator binding
 or to a @tech(~doc: meta_doc){operator order}, while @rhombus(~other) stands for any operator not
 otherwise mentioned. The @rhombus(~name), @rhombus(~who), and @rhombus(~unsafe) options are
 as in @rhombus(fun, ~defn). When multiple cases are provided using an immediate @vbar, then
 only the first prefix case and the first infix/postfix case can supply
 options; alternatively, when the operator name (maybe with a result annotation)
 is written before @vbar, options that apply to all cases can be supplied in
 a block before the cases. Options can appear both before the cases and in
 individual clauses, as long as all options of a particular kind are in one
 or the other.

@examples(
  ~defn:
    operator x ^^^ y:
      x +& y +& x
  ~repl:
    "a" ^^^ "b"
    1 ^^^ 2
  ~defn:
    operator x wings y:
      x +& y +& x
  ~repl:
    "a" wings "b"
  ~defn:
    operator ((x :: String) ^^^ (y :: String)) :: String:
      x +& y +& x
  ~repl:
    "a" ^^^ "b"
    ~error:
      1 ^^^ 2
  ~defn:
    operator x List.(^^^) y:
      x ++ y ++ x
  ~repl:
    block:
      import:
        .List open
      [1, 2] ^^^ [3]
  ~defn:
    operator
    | x ^^^ y:
        x +& y +& x
    | ^^^ y:
        "--" +& y +& "--"
  ~repl:
    "a" ^^^ "b"
    ^^^ "b"
  ~defn:
    operator ^^^:
      ~weaker_than: arithmetic
    | x ^^^ y:
        x +& y +& x
    | ^^^ y:
        "--" +& y +& "--"
  ~repl:
    1 ^^^ 2 + 3
    ^^^ 4 + 5
)

}

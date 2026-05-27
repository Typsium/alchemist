/* 
  // reaction syntax
  input         ::= reaction
  reaction      ::= term (OPERATOR term)*
  term          ::= COEFFICIENT? molecule
  COEFFICIENT   ::= DIGIT+

  // operator expression
  OPERATOR      ::= CONDITION? OP_SYMBOL CONDITION?
  CONDITION     ::= "[" TEXT "]"
  OP_SYMBOL     ::= "->" | "<=>" | "⇌" | "→" | "⇄" | "=>" | "-->" | "+" | MATH_TEXT // TODO: Unicode is difficult to parse

  // molecule syntax
  molecule      ::= unit (bond unit)*
  unit          ::= (node | implicit_node) branch* ring*
  node          ::= fragment | label
  implicit_node ::= ε

  fragment      ::= FRAGMENT label? options?
  bond          ::= BOND_SYMBOL bond_label? options?
  BOND_SYMBOL   ::= "-" | "=" | "#" | ">" | "<" | ":>" | "<:" | "|>" | "<|"

  branch        ::= "(" bond molecule ")"
  ring          ::= "@" DIGIT+ "(" molecule? ")" label? options?

  label         ::= ":" IDENTIFIER
  bond_label    ::= "::" IDENTIFIER
  options       ::= "(" key_value_pair ("," key_value_pair)* ")"
  key_value_pair::= IDENTIFIER ":" value

  // FRAGMENT definition
  FRAGMENT      ::= ATOMS | ABBREVIATION | MATH_TEXT
  ATOMS         ::= ATOMS_PART+ CHARGE?
  ATOMS_PART    ::= ELEMENT_GROUP | PARENTHETICAL | COMPLEX
  ELEMENT_GROUP ::= ISOTOPE? ELEMENT SUBSCRIPT?
  ISOTOPE       ::= "^" DIGIT+
  ELEMENT       ::= [A-Z][a-z]?
  SUBSCRIPT     ::= DIGIT+
  PARENTHETICAL ::= "(" ATOMS ")" SUBSCRIPT?
  COMPLEX       ::= "[" ATOMS "]"
  CHARGE        ::= "^" DIGIT? ("+" | "-")
  ABBREVIATION  ::= [a-z][A-Za-z]+

  // Basic tokens
  TEXT          ::= [^[\]]+ | [^\s\(\)\[\]:,=\-<>#]+
  IDENTIFIER    ::= [a-zA-Z_][a-zA-Z0-9_]*
  DIGIT         ::= [0-9]
*/

#import "../../utils/parser-combinator.typ": *
#import "generator.typ": process-atom, calc-main-index

// ==================== Utilities ====================

#let digit = satisfy(
  c => c >= "0" and c <= "9", name: "digit"
)
#let integer = map(some(digit), ds => int(ds.join()))
#let letter = satisfy(
  c => (c >= "a" and c <= "z") or (c >= "A" and c <= "Z"), name: "letter"
)
#let uppercase = satisfy(
  c => c >= "A" and c <= "Z", name: "uppercase"
)
#let lowercase = satisfy(
  c => c >= "a" and c <= "z", name: "lowercase"
)
#let alphanum = satisfy(
  c => (c >= "0" and c <= "9") or (c >= "a" and c <= "z") or (c >= "A" and c <= "Z"),
  name: "alphanum"
)
#let identifier = {
  seq(choice(letter, char("_")), many(choice(alphanum, char("_"))), map: r => {
    let (first, rest) = r
    first + rest.join()
  })
}
#let whitespace = one-of(" \t\n\r")
#let ws = many(whitespace)
#let space = one-of(" \t")
#let newline = choice(str("\r\n"), char("\n"))
#let lexeme(p) = seq(p, ws, map: r => r.at(0))
#let token(s) = lexeme(str(s))

// String with escapes
#let string-lit(quote: "\"") = {
  let escape = seq(char("\\"), any(), map: r => {
    let (_, c) = r
    if c == "n" { "\n" }
    else if c == "t" { "\t" }
    else if c == "r" { "\r" }
    else if c == "\\" { "\\" }
    else if c == quote { quote }
    else { c }
  })
  
  let normal = none-of(quote + "\\")
  let char-parser = choice(escape, normal)
  
  between(char(quote), char(quote), many(char-parser), map: chars => chars.join())
}

// ==================== Labels and Options ====================

#let label-parser = seq(
  char(":"), identifier,
  map: parts => {
    let (_, id) = parts
    id
  }
)

#let label-ref-parser = seq(
  char(":"), identifier,
  map: parts => {
    let (_, id) = parts
    (type: "label-ref", label: id)
  }
)

#let bond-label-parser = seq(
  str("::"), identifier,
  map: parts => {
    let (_, id) = parts
    id
  }
)

// TODO: Fix this parser to support multiple key-value pairs
// key-value pair (e.g., color: red, angle: 45)
#let key-value-pair-parser = seq(
  identifier, token(":"), some(none-of(")")),
  map: parts => {
    let (id, colon, value) = parts
    id + colon + value.join()
  }
)

#let options-parser = seq(
  char("("), key-value-pair-parser, char(")"),
  map: parts => {
    let (_, pairs, _) = parts
    (type: "options", pairs: eval("(" + pairs + ")"))
  }
)

// ==================== Fragments ====================

// element symbol (e.g., H, Ca, Fe)
#let element-parser = seq(
  uppercase, optional(lowercase),
  map: parts => {
    let (upper, lower) = parts
    if lower != none { upper + lower } else { upper }
  }
)

// isotope notation (e.g., ^14, ^235)
#let isotope-parser = seq(
  char("^"), integer,
  map: parts => {
    let (_, num) = parts
    num
  }
)

// charge notation (e.g., ^+, ^2-, ^3+)
#let charge-parser = seq(
  char("^"), optional(digit), choice(char("+"), char("-")),
  map: parts => {
    let (_, d, sign) = parts
    d + sign
  }
)

#let element-group-parser = seq(
  optional(isotope-parser), element-parser, optional(integer),
  map: parts => {
    let (isotope, element, subscript) = parts
    (
      type: "element-group",
      isotope: isotope,
      element: element,
      subscript: subscript
    )
  }
)

// abbreviation (e.g., tBu, iPr)
#let abbreviation-parser = seq(
  lowercase, some(letter),
  map: parts => {
    let (first, rest) = parts
    (type: "abbreviation", value: first + rest.join())
  }
)

// math text notation (e.g., $\\Delta$, $\\mu$)
#let math-text-parser = seq(
  char("$"), some(none-of("$")), char("$"),
  map: parts => {
    let (_, chars, _) = parts
    (type: "math-text", value: chars.join())
  }
)

#let parenthetical-parser(atoms-parser) = seq(
  char("("),
  atoms-parser,
  char(")"),
  optional(integer),
  map: parts => {
    let (_, atoms, _, subscript) = parts
    (type: "parenthetical", atoms: atoms, subscript: subscript)
  }
)

// complex notation (e.g., [Fe(CN)6]^3-, [Cu(NH3)4]^2+)
#let complex-parser(atoms-parser) = seq(
  char("["), 
  atoms-parser,
  char("]"),
  map: parts => {
    let (_, atoms, _) = parts
    (type: "complex", atoms: atoms)
  }
)

#let atoms-part-parser(atoms-parser) = choice(
  element-group-parser,
  parenthetical-parser(atoms-parser),
  complex-parser(atoms-parser)
)

#let atoms-parser() = {
  let self = lazy(() => atoms-parser())

  seq(
    some(atoms-part-parser(self)), optional(charge-parser),
    map: parts => {
      let (parts, charge) = parts
      (type: "atoms", parts: parts, charge: charge)
    }
  )
}

#let fragment-content-parser = choice(
  atoms-parser(),
  abbreviation-parser,
  math-text-parser,
)


#let fragment-parser = seq(
  fragment-content-parser, optional(label-parser), optional(options-parser),
  map: parts => {
    let (content, label, options) = parts
    (
      type: "fragment",
      atoms: process-atom(content),
      name: label,
      options: if options != none { options.pairs } else { (:) },
      main-index: calc-main-index(content),
    )
  }
)

// ==================== Bonds ====================

#let bond-symbol-parser = choice(
  str("->"),  // Arrow prevention
  str("=>"),  // Arrow prevention  
  str(":>"),
  str("<:"),
  str("|>"),
  str("<|"),
  char("="),
  char("#"),
  char("-"),
  char(">"),
  char("<")
)

#let bond-parser = seq(
  bond-symbol-parser, optional(bond-label-parser), optional(options-parser),
  map: parts => {
    let (symbol, label, options) = parts
    (
      type: "bond",
      symbol: symbol,
      name: label,
      options: if options != none { options.pairs } else { (:) }
    )
  }
)

// ==================== Rings ====================

#let ring-size-parser = map(
  validate(
    some(digit),
    digits => {
      if digits.len() == 0 {
        return (false, "Ring notation (e.g., @6, @5(C-C-C-C-C)) must have at least one digit")
      }
      let num = int(digits.join())
      (num >= 3, "Ring size must be at least 3")
    },
  ),
  parts => {
    int(parts.join())
  }
)

// ring notation (e.g., @6, @5(C-C-C-C-C))
#let ring-parser(mol-parser) = seq(
  char("@"), ring-size-parser,
  optional(seq(char("("), mol-parser, char(")"))),
  optional(label-parser),
  optional(options-parser),
  map: parts => {
    let (_, faces, mol, lbl, opts) = parts
    (
      type: "cycle",
      faces: faces,
      body: if mol != none { mol.at(1) } else { none },
      label: lbl,
      options: opts
    )
  }
)

// ==================== Molecules ====================

#let node-parser(mol-parser) = choice(
  fragment-parser,
  label-ref-parser
)

#let branch-parser(mol-parser) = seq(
  char("("), bond-parser, mol-parser, char(")"),
  map: parts => {
    let (_, bond, molecules, _) = parts
    (type: "branch", bond: bond, body: molecules)
  }
)

#let unit-parser(mol-parser) = seq(
  optional(node-parser(mol-parser)), many(branch-parser(mol-parser)), many(ring-parser(mol-parser)),
  map: parts => {
    let (node, branches, rings) = parts

    // Handle label reference as a special unit type
    if node != none and node.type == "label-ref" {
      (
        type: "unit",
        node: node,
        branches: branches,
        rings: rings,
      )
    } else {
      (
        type: "unit",
        node: if node == none { (type: "implicit") } else { node },
        branches: branches,
        rings: rings,
      )
    }
  }
)

#let molecule-parser() = {
  let self = lazy(() => molecule-parser())
  
  seq(
    unit-parser(self),
    many(seq(bond-parser, unit-parser(self))),
    map: nodes => {
      let (first, rest) = nodes
      
      (
        type: "molecule",
        first: first,
        rest: rest.map(unit => {
          let (bond, unit) = unit 
          (bond: bond, unit: unit)
        })
      )
    }
  )
}

// ==================== Reactions ====================

#let op-symbol-parser = choice(
  str("<=>"),
  str("-->"),
  str("->"),
  str("=>"),
  str("⇌"),
  str("→"),
  str("⇄"),
  char("+"),
  math-text-parser
)

// reaction condition (e.g., [heat], [catalyst])
#let condition-parser = seq(
  char("["), many(none-of("]")), char("]"),
  map: parts => {
    let (_, chars, _) = parts
    (type: "condition", text: chars.join())
  }
)

#let operator-parser = seq(
  ws, optional(condition-parser), op-symbol-parser, optional(condition-parser), ws,
  map: parts => {
    let (_, cond1, op, cond2, _) = parts
    (
      type: "operator",
      condition-before: cond1,
      op: op,
      condition-after: cond2
    )
  }
)

#let term-parser = seq(
  optional(integer), molecule-parser(),
  map: parts => {
    let (coeff, mol) = parts
    (
      type: "term",
      coefficient: coeff,
      molecule: mol
    )
  }
)

#let reaction-parser = seq(
  term-parser, many(seq(operator-parser, term-parser)),
  map: parts => {
    let (first, rest) = parts
    let terms = (first,)
    for (operator, term) in rest {
      terms.push(operator)
      terms.push(term)
    }
    (
      type: "reaction",
      terms: terms
    )
  }
)

// ==================== Parse Functions ====================

#let alchemist-parser(input) = {
  if input == "" {
    return (
      success: true,
      value: (type: "reaction", terms: ()),
      rest: input
    )
  }
  
  let reaction_result = parse(reaction-parser, input)
  
  if not reaction_result.success {
    return reaction_result
  }
  
  if reaction_result.rest != "" {
    let rest = reaction_result.rest
    let preview_len = calc.min(10, rest.len())
    let preview = rest.slice(0, preview_len)
    
    let first_char = rest.at(0)
    let error_msg = if first_char >= "0" and first_char <= "9" {
      "Unexpected number '" + preview + "' - numbers must be part of subscripts, isotopes, or ring sizes"
    } else if first_char == "&" or first_char == "!" or first_char == "%" {
      "Invalid character '" + first_char + "' - not a valid bond or atom symbol"
    } else if first_char == "^" {
      "Invalid isotope or charge notation starting with '" + preview + "'"
    } else if first_char == "-" or first_char == "=" or first_char == "#" {
      "Unexpected bond '" + first_char + "' - bonds must connect atoms"
    } else {
      "Unexpected content '" + preview + "' after valid molecule"
    }
    
    return (
      success: false,
      value: none,
      error: error_msg + " (at position " + repr(input.len() - rest.len()) + ")",
      rest: rest
    )
  }
  
  return reaction_result
}

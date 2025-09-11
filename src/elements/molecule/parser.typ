/* 
  // reaction syntax
  input         ::= reaction
  reaction      ::= term (OPERATOR term)*
  term          ::= COEFFICIENT? molecule
  COEFFICIENT   ::= DIGIT+

  // operator expression
  OPERATOR      ::= CONDITION? OP_SYMBOL CONDITION?
  CONDITION     ::= "[" TEXT "]"
  OP_SYMBOL     ::= "->" | "<=>" | "⇌" | "→" | "⇄" | "=>" | "-->" | "+" | MATH_TEXT

  // molecule syntax
  molecule      ::= unit (bond unit)*
  unit          ::= (node | implicit_node) branch*
  node          ::= fragment | ring | label
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

// ==================== Utilities ====================

#let digit = satisfy(c => c >= "0" and c <= "9", name: "digit")
#let letter = satisfy(c => (c >= "a" and c <= "z") or (c >= "A" and c <= "Z"), name: "letter")
#let uppercase = satisfy(c => c >= "A" and c <= "Z", name: "uppercase")
#let lowercase = satisfy(c => c >= "a" and c <= "z", name: "lowercase")
#let alphanum = satisfy(c => {
  (c >= "0" and c <= "9") or (c >= "a" and c <= "z") or (c >= "A" and c <= "Z")
}, name: "alphanum")
#let whitespace = one-of(" \t\n\r")
#let ws = many(whitespace)
#let space = one-of(" \t")
#let newline = choice(str("\r\n"), char("\n"))
#let lexeme(p) = map(seq(p, ws), r => r.at(0))
#let token(s) = lexeme(str(s))

// Integer
#let integer = {
  let sign = optional(one-of("+-"))
  let digits = some(digit)
  
  map(seq(sign, digits), r => {
    let (s, d) = r
    let n = int(d.join())
    if s == "-" { -n } else { n }
  })
}

// Identifier
#let identifier = {
  let first = choice(letter, char("_"))
  let rest = many(choice(alphanum, char("_")))
  
  map(seq(first, rest), r => {
    let (f, rs) = r
    f + rs.join()
  })
}

// String with escapes
#let string-lit(quote: "\"") = {
  let escape = map(seq(char("\\"), any()), r => {
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
  
  map(between(char(quote), char(quote), many(char-parser)), chars => chars.join())
}

// ==================== Fragment Components ====================

// ELEMENT ::= [A-Z][a-z]?
#let element-parser = label(
  map(
    seq(
      uppercase,
      optional(lowercase),
    ),
    parts => {
      let (upper, lower) = parts
      if lower != none { upper + lower } else { upper }
    }
  ),
  "element symbol (e.g., H, Ca, Fe)"
)

// SUBSCRIPT ::= DIGIT+
#let subscript-parser = label(
  map(
    some(digit),
    digits => int(digits.join())
  ),
  "subscript number"
)

// ISOTOPE ::= "^" DIGIT+
#let isotope-parser = label(
  map(
    seq(char("^"), some(digit)),
    parts => {
      let (_, digits) = parts
      (type: "isotope", value: int(digits.join()))
    }
  ),
  "isotope notation (e.g., ^14, ^235)"
)

// CHARGE ::= "^" DIGIT? ("+" | "-")
#let charge-parser = label(
  map(
    seq(char("^"), optional(digit), choice(char("+"), char("-"))),
    parts => {
      let (_, d, sign) = parts
      d + sign
    }
  ),
  "charge notation (e.g., ^+, ^2-, ^3+)"
)

// ELEMENT_GROUP ::= ISOTOPE? ELEMENT SUBSCRIPT?
#let element-group-parser = map(
  seq(optional(isotope-parser), element-parser, optional(subscript-parser)),
  parts => {
    let (isotope, element, subscript) = parts
    (
      type: "element-group",
      isotope: isotope,
      element: element,
      subscript: subscript
    )
  }
)

// ABBREVIATION ::= [a-z][A-Za-z]+
#let abbreviation-parser = map(
  seq(lowercase, some(letter)),
  parts => {
    let (first, rest) = parts
    (type: "abbreviation", value: first + rest.join())
  }
)

// MATH_TEXT ::= "$" [^$]+ "$"
#let math-text-parser = label(
  map(
    seq(
      char("$"),
      some(none-of("$")),
      char("$")
    ),
    parts => {
      let (_, chars, _) = parts
      (type: "math-text", value: chars.join())
    }
  ),
  "math text notation (e.g., $\\Delta$, $\\mu$)"
)

#let parenthetical-parser(atoms-parser) = {
  label(
    map(
      seq(
        char("("),
        lazy(() => atoms-parser()),
        char(")"),
        optional(subscript-parser)
      ),
      parts => {
        let (_, atoms, _, subscript) = parts
        (type: "parenthetical", atoms: atoms, subscript: subscript)
      }
    ),
    "parenthetical group (e.g., (OH)2, (NH4)2)"
  )
}

#let complex-parser(atoms-parser) = {
  label(
    map(
      seq(
        char("["), 
        lazy(() => atoms-parser()), 
        char("]")
      ),
      parts => {
        let (_, atoms, _) = parts
        (type: "complex", atoms: atoms)
      }
    ),
    "complex notation (e.g., [Fe(CN)6]^3-, [Cu(NH3)4]^2+)"
  )
}

// Forward declarations for recursive parsers
#let atoms-part-parser(atoms-parser) = choice(
  element-group-parser,
  parenthetical-parser(atoms-parser),
  complex-parser(atoms-parser)
)

#let atoms-parser() = {
  label(
    map(
      seq(some(atoms-part-parser(atoms-parser)), optional(charge-parser)),
      parts => {
        let (parts, charge) = parts
        (type: "atoms", parts: parts, charge: charge)
      }
    ),
    "atoms composition"
  )
}

// FRAGMENT ::= ATOMS | ABBREVIATION | MATH_TEXT
#let fragment-content-parser = choice(
  atoms-parser(),
  abbreviation-parser,
  math-text-parser,
  element-parser  // Fallback for simple elements
)

// IDENTIFIER ::= [a-zA-Z_][a-zA-Z0-9_]*
#let identifier-parser = map(
  seq(
    satisfy(c => (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or c == "_", name: "id-first"),
    many(alphanum)
  ),
  parts => {
    let (first, rest) = parts
    (type: "identifier", value: first + rest.join())
  }
)

// label ::= ":" IDENTIFIER
#let label-parser = map(
  seq(char(":"), identifier-parser),
  parts => {
    let (_, id) = parts
    (type: "label", name: id.value)
  }
)

// ==================== Options ====================

// Simple value parser
#let value-parser = choice(
  map(some(digit), ds => int(ds.join())),
  identifier-parser
)

// key_value_pair ::= IDENTIFIER ":" value
#let key-value-pair-parser = label(
  map(
    seq(identifier-parser, token(":"), value-parser),
    parts => {
      let (key, _, value) = parts
      (key: key.value, value: value)
    }
  ),
  "key-value pair (e.g., color: red, angle: 45)"
)

// options ::= "(" key_value_pair ("," key_value_pair)* ")"
#let options-parser = label(
  map(
    seq(char("("), sep-by(key-value-pair-parser, token(",")), char(")")),
    parts => {
      let (_, pairs, _) = parts
      (type: "options", pairs: pairs)
    }
  ),
  "options in parentheses"
)

// ==================== Fragment ====================

#let process-atom(parts) = {
  let type = parts.type

  if type == "atoms" {
    let base = parts.parts.map(process-atom).join()
    if parts.charge != none {
      math.attach(base, tr: eval("$" + parts.charge + "$"))
    } else {
      base
    }
  } else if type == "abbreviation" {
    text(parts.value)
  } else if type == "math-text" {
    eval(parts.value)
  } else if type == "element-group" {
    math.attach(parts.element, tl: [#parts.isotope], br: [#parts.subscript])
  } else if type == "parenthetical" {
    let inner = process-atom(parts.atoms)
    math.attach([(#inner)], br: [#parts.subscript])
  } else if type == "complex" {
    let inner = process-atom(parts.atoms)
    [\[#inner\]]
  } else {
    "unkown type: " + type
  }
}

// fragment ::= FRAGMENT label? options?
#let fragment-parser = label(
  map(
    seq(fragment-content-parser, optional(label-parser), optional(options-parser)),
    parts => {
      let (content, label, options) = parts
      (
        type: "fragment",
        name: process-atom(content),
        label: label,
        options: options
      )
    }
  ),
  "molecular fragment"
)

// ==================== Bonds ====================

// BOND_SYMBOL ::= "-" | "=" | "#" | ">" | "<" | ":>" | "<:" | "|>" | "<|"
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

// bond_label ::= "::" IDENTIFIER
#let bond-label-parser = map(
  seq(str("::"), identifier-parser),
  parts => {
    let (_, id) = parts
    (type: "bond-label", name: id.value)
  }
)

// bond ::= BOND_SYMBOL bond_label? options?
#let bond-parser = label(
  map(
    seq(bond-symbol-parser, optional(bond-label-parser), optional(options-parser)),
    parts => {
      let (symbol, label, options) = parts
      (
        type: "bond",
        symbol: symbol,
        label: label,
        options: options
      )
    }
  ),
  "chemical bond"
)

// ==================== Rings ====================

// ring ::= "@" DIGIT+ "(" molecule? ")" label? options?
#let ring-parser(mol-parser) = label(
  lazy(() => map(
    seq(
      char("@"),
      some(digit),
      optional(
        seq(
          char("("),
          mol-parser,
          char(")"),
        ), 
      ),
      optional(label-parser),
      optional(options-parser)
    ),
    parts => {
      let (_, digits, mol, lbl, opts) = parts
      (
        type: "cycle",
        faces: int(digits.join()),
        body: mol,
        label: lbl,
        options: opts
      )
    }
  )),
  "ring notation (e.g., @6, @5(C-C-C-C-C))"
)

// ==================== Molecules ====================

// node ::= fragment | ring | label
#let node-parser(mol-parser) = choice(
  fragment-parser,
  ring-parser(mol-parser),
  label-parser
)

// branch ::= "(" bond molecule ")"
#let branch-parser(mol-parser) = map(
  seq(
    char("("),
    bond-parser,
    mol-parser,
    char(")")
  ),
  parts => {
    let (_, bond, molecule, _) = parts
    (type: "branch", bond: bond, body: molecule)
  }
)

// unit ::= (node | implicit_node) branch*
#let unit-parser(mol-parser) = map(
  seq(optional(node-parser(mol-parser)), many(branch-parser(mol-parser))),
  parts => {
    let (node, branches) = parts
    (
      type: "unit",
      node: if node == none { (type: "implicit") } else { node },
      branches: branches
    )
  }
)

// molecule ::= unit (bond unit)*
#let molecule-parser() = {
  // Create a lazy reference to itself
  let self = lazy(() => molecule-parser())
  
  label(
    map(
      seq(
        unit-parser(self),
        many(seq(bond-parser, unit-parser(self)))
      ),
      nodes => {
        let (first, rest) = nodes
        (
          type: "molecule",
          first: first,
          rest: rest
        )
      }
    ),
    "molecule structure"
  )
}

// ==================== Reactions ====================

// COEFFICIENT ::= DIGIT+
#let coefficient-parser = label(
  map(
    some(digit),
    digits => (type: "coefficient", value: int(digits.join()))
  ),
  "stoichiometric coefficient"
)

// OP_SYMBOL ::= "->" | "<=>" | "⇌" | "→" | "⇄" | "=>" | "-->" | "+"
#let op-symbol-parser = choice(
  str("<=>"),
  str("-->"),
  str("->"),
  str("=>"),
  str("⇌"),
  str("→"),
  str("⇄"),
  char("+")
)

// CONDITION ::= "[" TEXT "]"
#let condition-parser = label(
  map(
    seq(char("["), many(none-of("]")), char("]")),
    parts => {
      let (_, chars, _) = parts
      (type: "condition", text: chars.join())
    }
  ),
  "reaction condition (e.g., [heat], [catalyst])"
)

// OPERATOR ::= CONDITION? OP_SYMBOL CONDITION?
#let operator-parser = map(
  seq(ws, optional(condition-parser), op-symbol-parser, optional(condition-parser), ws),
  parts => {
    let (_, cond1, symbol, cond2, _) = parts
    (
      type: "operator",
      condition-before: cond1,
      symbol: symbol,
      condition-after: cond2
    )
  }
)

// term ::= COEFFICIENT? molecule
#let term-parser = label(
  map(
    seq(optional(coefficient-parser), molecule-parser()),
    parts => {
      let (coeff, mol) = parts
      (
        type: "term",
        coefficient: coeff,
        molecule: mol
      )
    }
  ),
  "reaction term"
)

// reaction ::= term (OPERATOR term)*
#let reaction-parser = label(
  map(
    seq(term-parser, many(seq(operator-parser, term-parser))),
    parts => {
      let (first, rest) = parts
      let terms = (first,)
      let edges = ()
      for (operator, term) in rest {
        terms.push(term)
        edges.push((..operator, from: terms.len() - 1, to: terms.len()))
      }
      (
        type: "reaction",
        terms: terms,
        edges: edges
      )
    }
  ),
  "chemical reaction"
)

// ==================== Parse Functions ====================

#let alchemist-parser(input) = {
  let full = map(seq(reaction-parser, eof()), r => r.at(0))
  parse(full, input)
}

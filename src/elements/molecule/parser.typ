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

#let digit = satisfy(
  c => c >= "0" and c <= "9", name: "digit"
)
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
  map(seq(choice(letter, char("_")), many(choice(alphanum, char("_")))), r => {
    let (first, rest) = r
    first + rest.join()
  })
}
#let whitespace = one-of(" \t\n\r")
#let ws = many(whitespace)
#let space = one-of(" \t")
#let newline = choice(str("\r\n"), char("\n"))
#let lexeme(p) = map(seq(p, ws), r => r.at(0))
#let token(s) = lexeme(str(s))

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

// ==================== Labels and Options ====================

#let label-parser = map(
  seq(char(":"), identifier),
  parts => {
    let (_, id) = parts
    id.value
  }
)

#let bond-label-parser = map(
  seq(str("::"), identifier),
  parts => {
    let (_, id) = parts
    id.value
  }
)

#let value-parser = choice(
  map(some(digit), ds => int(ds.join())),
  identifier
)

#let key-value-pair-parser = label(
  map(
    seq(identifier, token(":"), value-parser),
    parts => {
      let (key, _, value) = parts
      (key: key, value: value)
    }
  ),
  "key-value pair (e.g., color: red, angle: 45)"
)

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

// ==================== Fragments ====================

#let element-parser = label(
  map(
    seq(uppercase, optional(lowercase)),
    parts => {
      let (upper, lower) = parts
      if lower != none { upper + lower } else { upper }
    }
  ),
  "element symbol (e.g., H, Ca, Fe)"
)

#let subscript-parser = label(
  map(
    some(digit),
    digits => int(digits.join())
  ),
  "subscript number (e.g., CH4, O2)"
)

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

#let abbreviation-parser = label(
  map(
    seq(lowercase, some(letter)),
    parts => {
      let (first, rest) = parts
      (type: "abbreviation", value: first + rest.join())
    }
  ),
  "abbreviation (e.g., tBu, iPr)"
)

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
        atoms-parser,
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
        atoms-parser,
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

#let atoms-part-parser(atoms-parser) = choice(
  element-group-parser,
  parenthetical-parser(atoms-parser),
  complex-parser(atoms-parser)
)

#let atoms-parser() = {
  let self = lazy(() => atoms-parser())

  label(
    map(
      seq(some(atoms-part-parser(self)), optional(charge-parser)),
      parts => {
        let (parts, charge) = parts
        (type: "atoms", parts: parts, charge: charge)
      }
    ),
    "atoms composition"
  )
}

#let fragment-content-parser = choice(
  atoms-parser(),
  abbreviation-parser,
  math-text-parser,
)

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

#let ring-parser(mol-parser) = label(
  lazy(() => map(
    seq(
      char("@"), some(digit),
      optional(seq(char("("), mol-parser, char(")"))),
      optional(label-parser),
      optional(options-parser)
    ),
    parts => {
      let (_, digits, mol, lbl, opts) = parts
      if type(mol) == array {
        let (_, mol, _) = mol
      } else {
        mol = none
      }
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

#let node-parser(mol-parser) = choice(
  fragment-parser,
  ring-parser(mol-parser),
  label-parser
)

#let branch-parser(mol-parser) = map(
  seq(char("("), bond-parser, mol-parser, char(")")),
  parts => {
    let (_, bond, molecule, _) = parts
    (type: "branch", bond: bond, body: molecule)
  }
)

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

#let molecule-parser() = {
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
          rest: rest.map(unit => {
            let (bond, unit) = unit 
            (bond: bond, unit: unit)
          })
        )
      }
    ),
    "molecule structure"
  )
}

// ==================== Reactions ====================

#let coefficient-parser = label(
  map(
    some(digit),
    digits => (type: "coefficient", value: int(digits.join()))
  ),
  "stoichiometric coefficient"
)

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

#let operator-parser = map(
  seq(ws, optional(condition-parser), op-symbol-parser, optional(condition-parser), ws),
  parts => {
    let (_, cond1, op, cond2, _) = parts
    (
      type: "operator",
      condition-before: cond1,
      op: op,
      condition-after: cond2
    )
  }
)

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

#let reaction-parser = label(
  map(
    seq(term-parser, many(seq(operator-parser, term-parser))),
    parts => {
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
  ),
  "chemical reaction"
)

// ==================== Parse Functions ====================

#let alchemist-parser(input) = {
  let full = map(seq(reaction-parser, eof()), r => r.at(0))
  parse(full, input)
}

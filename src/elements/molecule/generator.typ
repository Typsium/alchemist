#import "../links.typ": single, double, triple, cram-filled-right, cram-filled-left, cram-dashed-right, cram-dashed-left, cram-hollow-right, cram-hollow-left

// ============================ Atom Processing ============================

/// Convert parsed atom structure to Typst math content
#let process-atom(parts) = {
  let type = parts.type

  if type == "atoms" {
    let base = parts.parts.map(process-atom)
    if parts.charge != none {
      (math.attach(base.join(), tr: eval("$" + parts.charge + "$")),)
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
    math.attach([(#inner.join())], br: [#parts.subscript])
  } else if type == "complex" {
    let inner = process-atom(parts.atoms)
    [\[#inner.join()\]]
  } else {
    "unknown type: " + type
  }
}

/// Extract element names from parsed content and find the first non-H index
/// Returns the index of the first non-H element (0 if all are H or empty)
#let calc-main-index(parts) = {
  // Extract element names recursively
  let extract(p) = {
    if p.type == "atoms" { p.parts.map(extract).flatten() }
    else if p.type == "element-group" { (p.element,) }
    else if p.type == "parenthetical" or p.type == "complex" { extract(p.atoms) }
    else if p.type == "abbreviation" or p.type == "math-text" { (p.value,) }
    else { () }
  }
  let elements = extract(parts)

  // Find first non-H index
  for (idx, el) in elements.enumerate() {
    if el != "H" { return idx }
  }
  0
}

// ============================ Molecule ============================

#let generate_fragment(node) = (
  (
    type: "fragment",
    atoms: node.atoms,
    name: node.at("name", default: none),
    links: node.at("links", default: (:)),
    lewis: node.options.at("lewis", default: ()),
    vertical: node.options.at("vertical", default: false),
    count: node.atoms.len(),
    colors: node.options.at("colors", default: none),
    label: node.at("name", default: none),
    ..node.options,
  ),
)

#let generate_bond(bond, angle, options) = {
  let symbol = bond.symbol
  let name = bond.at("name", default: none)
  let absolute = if angle != none { angle } else { bond.at("absolute", default: none) }
  let relative = bond.at("relative", default: none)
  let options = if options != (:) { options } else { bond.options }

  let bond-fn = if symbol == "-" {
    single
  } else if symbol == "=" {
    double
  } else if symbol == "#" {
    triple
  } else if symbol == ">" {
    cram-filled-right
  } else if symbol == "<" {
    cram-filled-left
  } else if symbol == ":>" {
    cram-dashed-right
  } else if symbol == "<:" {
    cram-dashed-left
  } else if symbol == "|>" {
    cram-hollow-right
  } else if symbol == "<|" {
    cram-hollow-left
  } else {
    single
  }
  
  if absolute != none and relative != none {
    bond-fn(relative: relative, absolute: absolute, name: name, ..options)
  } else if relative != none {
    bond-fn(relative: relative, name: name, ..options)
  } else if absolute != none {
    bond-fn(absolute: absolute, name: name, ..options)
  } else {
    bond-fn(name: name, ..options)
  }
}

#let generate_branch(bond, body) = (
  (
    type: "branch",
    body: {bond; body},
    args: (:),
  ),
)

#let generate_cycle(cycle, body) = (
  type: "cycle",
  faces: cycle.faces,
  body: body,
  args: (:),
)

#let generate_molecule(molecule) = {
  if molecule == none { return () }
  if type(molecule) == array { return molecule }
  if molecule.type != "molecule" { return () }
  
  let elements = ()
  elements += generate_unit(molecule.first)
  for item in molecule.rest {
    elements += generate_bond(item.bond)
    elements += generate_unit(item.unit)
  }
  return elements
}

// ============================ Reaction ============================

#let generate_operator(operator) = {
  let op = if operator.op == "->" {
    sym.arrow.r
  } else if operator.op == "<->" {
    sym.arrow.l.r
  } else if operator.op == "<=>" {
    sym.harpoons.ltrb
  } else {
    eval("$" + operator.op + "$")
  }

  op = math.attach(
    math.stretch(op, size: 100% + 2em),
    t: [#term.condition-before], b: [#term.condition-after]
  )

  return (
    type: "operator",
    name: none,
    op: op,
    margin: 0.7em,
  )
}

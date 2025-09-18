#import "../links.typ": single, double, triple, cram-filled-right, cram-filled-left, cram-dashed-right, cram-dashed-left, cram-hollow-right, cram-hollow-left

// ============================ Molecule ============================

#let generate_fragment(node) = (
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
)

#let generate_bond(bond, angle) = {
  let symbol = bond.symbol
  let name = bond.at("name", default: none)
  let absolute = if angle != none { angle } else { bond.at("absolute", default: none) }
  let relative = bond.at("relative", default: none)
  let options = bond.options

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

#let generate_branch(bond, body) = {
  return (
    type: "branch",
    body: (..bond, ..body),
    args: (:),
  )
}

#let generate_cycle(cycle, body) = {
  return (
    type: "cycle",
    faces: cycle.faces,
    body: body,
    args: (:),
  )
}

#let generate_label_reference(label) = {
}

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

#let generate_term(ctx, molecule) = {
  if molecule.type != "molecule" {
    return molecule
  }

  let transformed = generate_molecule(molecule_with_angles)
  return generate_label_references(transformed)
}

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

#let generate_reaction(reaction) = {
  reaction.terms.map(term => {
    if term.type == "term" {
      generate_term(term.molecule)
    } else if term.type == "operator" {
      (generate_operator(term),)
    } else {
      panic("Unknown term type: " + term.type)
    }
  }).join()
}

#let generate = generate_reaction

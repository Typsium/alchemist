#import "iupac-angle.typ": calculate_angles
#import "../links.typ": single, double, triple, cram-filled-right, cram-filled-left, cram-dashed-right, cram-dashed-left

#let transform_fragment(node) = {
  let atoms = node.name
  (
    type: "fragment",
    atoms: if type(atoms) == array { atoms } else { (atoms,) },
    name: none,
    links: (:),
    lewis: (),
    vertical: false,
    count: if type(atoms) == array { atoms.len() } else { 1 },
    colors: none,
  )
}

#let transform_bond(bond) = {
  let symbol = bond.symbol
  let absolute = bond.at("absolute", default: none)
  let relative = bond.at("relative", default: none)

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
  } else {
    single
  }
  
  bond-fn(absolute: absolute, relative: relative)
}

#let transform_branch(branch, transform_molecule) = {
  let elements = ()
  elements += transform_bond(branch.bond)
  elements += transform_molecule(branch.body)
  
  return (
    type: "branch",
    body: elements,
    args: (:),
  )
}

#let transform_cycle(cycle, transform_molecule) = {
  return (
    type: "cycle",
    faces: cycle.faces,
    body: if cycle.body != none { transform_molecule(cycle.body) } else { none },
    args: (:),
  )
}

#let transform_unit(unit, transform_molecule) = {
  let elements = ()
  
  if unit.node != none {
    if unit.node.type == "fragment" {
      elements.push(transform_fragment(unit.node))
    } else if unit.node.type == "cycle" {
      elements.push(transform_cycle(unit.node, transform_molecule))
    } else if unit.node.type == "implicit" {
    } else {
      panic("Unknown node type: " + unit.node.type)
    }
  }
  
  elements += unit.branches.map(branch => transform_branch(branch, transform_molecule))
  
  return elements
}

#let transform_molecule(molecule) = {
  if molecule == none { return () }
  if type(molecule) == array { return molecule }
  if molecule.type != "molecule" { return () }
  
  let elements = ()
  elements += transform_unit(molecule.first, transform_molecule)
  for item in molecule.rest {
    elements += transform_bond(item.bond)
    elements += transform_unit(item.unit, transform_molecule)
  }
  return elements
}

#let transform_reaction(reaction) = {
  reaction.terms.map(term => {
    if term.type == "term" {
      let molecule = term.molecule
      let molecule_with_angles = calculate_angles(molecule)

      transform_molecule(molecule_with_angles)
    } else if term.type == "operator" {
      ((
        type: "operator",
        name: none,
        op: eval("$" + term.op + "$"),
        margin: 0.7em,
      ),)
    } else {
      panic("Unknown term type: " + term.type)
    }
  }).join()
}

#let transform = transform_reaction

// Simple transformer for new parser structure with angles already calculated
#import "../links.typ": single, double, triple, cram-filled-right, cram-filled-left, cram-dashed-right, cram-dashed-left

// Create fragment element
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

// Create bond element based on symbol and angle
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

#let transform_branch(branch, transform) = {
  let elements = ()
  elements += transform_bond(branch.bond)
  elements += transform(branch.body)
  
  return (
    type: "branch",
    body: elements,
    args: (:),
  )
}

#let transform_cycle(cycle, transform) = {
  return (
    type: "cycle",
    faces: cycle.faces,
    body: if cycle.body != none { transform(cycle.body) } else { none },
    args: (:),
  )
}

// Transform a single unit (node + branches)
#let transform_unit(unit, transform) = {
  let elements = ()
  
  // Add node content
  if unit.node != none {
    if unit.node.type == "fragment" {
      elements.push(transform_fragment(unit.node))
    } else if unit.node.type == "cycle" {
      elements.push(transform_cycle(unit.node, transform))
    } else if unit.node.type == "implicit" {
    } else {
      panic("Unknown node type: " + unit.node.type)
    }
  }
  
  // Add branches
  elements += unit.branches.map(branch => transform_branch(branch, transform))
  
  return elements
}

// Main transformation function
#let transform(molecule) = {
  if molecule == none or molecule.type != "molecule" {
    return ()
  }
  
  let elements = ()
  elements += transform_unit(molecule.first, transform)
  for item in molecule.rest {
    elements += transform_bond(item.bond)
    elements += transform_unit(item.unit, transform)
  }
  
  return elements
}

#import "iupac-angle.typ": calculate_angles
#import "../links.typ": single, double, triple, cram-filled-right, cram-filled-left, cram-dashed-right, cram-dashed-left, cram-hollow-right, cram-hollow-left

#let transform_fragment(node) = {
  let atoms = node.atoms
  (
    type: "fragment",
    atoms: atoms,
    name: node.at("name", default: none),
    links: node.at("links", default: (:)),
    lewis: node.options.at("lewis", default: ()),
    vertical: node.options.at("vertical", default: false),
    count: atoms.len(),
    colors: node.options.at("colors", default: none),
    label: node.at("name", default: none),
    ..node.options,
  )
}

#let transform_bond(bond) = {
  let symbol = bond.symbol
  let name = bond.at("name", default: none)
  let absolute = bond.at("absolute", default: none)
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
  
  bond-fn(absolute: absolute, relative: relative, name: name, ..options)
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

#let transform_label_reference(label) = {
  (
    type: "label-reference",
    label: label.label,
    links: (:),
  )
}

#let transform_unit(unit, transform_molecule) = {
  let elements = ()
  
  if unit.node != none {
    // Debug: log what we're getting
    if type(unit.node) == str {
      // This shouldn't happen, but if node is a raw string, treat it as a label reference
      elements.push(transform_label_reference((type: "label", label: unit.node)))
      elements += unit.at("branches", default: ()).map(branch => transform_branch(branch, transform_molecule))
      return elements
    }
    
    // Check if node has a type field (it should always have one from the parser)
    let node_type = if type(unit.node) == dictionary {
      unit.node.at("type", default: "unknown")
    } else {
      "unknown"
    }
    
    if node_type == "fragment" {
      elements.push(transform_fragment(unit.node))
    } else if node_type == "cycle" {
      elements.push(transform_cycle(unit.node, transform_molecule))
    } else if node_type == "label-ref" {
      elements.push(transform_label_reference(unit.node))
    } else if node_type == "implicit" {
      // Implicit node, no action needed
    } else {
      panic("Unknown node type: " + node_type + " for node: " + repr(unit.node))
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

// Resolve label references after transformation
#let resolve_label_references(elements) = {
  // First pass: collect all labeled atoms and their positions
  let label_positions = (:)
  let position = 0
  
  for (i, element) in elements.enumerate() {
    if element.type == "fragment" and element.at("label", default: none) != none {
      label_positions.insert(element.label, i)
    }
  }
  
  // Second pass: resolve label references
  let resolved = elements
  for (i, element) in elements.enumerate() {
    if element.type == "label-reference" {
      let label = element.label
      if label in label_positions {
        let target_pos = label_positions.at(label)
        resolved.at(i) = (
          type: "link",
          from: i,
          to: target_pos,
          bond: single(),  // Default to single bond, could be customized
        )
      } else {
        // Label not found, keep as unresolved reference or error
        resolved.at(i) = (
          type: "error",
          message: "Unresolved label reference: " + label,
        )
      }
    }
  }
  
  return resolved
}

#let transform_reaction(reaction) = {
  reaction.terms.map(term => {
    if term.type == "term" {
      let molecule = term.molecule
      let molecule_with_angles = calculate_angles(molecule)
      
      let transformed = transform_molecule(molecule_with_angles)
      // Resolve any label references in the transformed molecule
      resolve_label_references(transformed)
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

#import "iupac-angle.typ": bond-angle, IUPAC_ANGLES, unit-angles, initial-angle
#import "generator.typ": *

#let init_state() = (
  position: (),              // Position in the molecule
  parent_type: none,         // Parent structure type
  prev_bond: none,           // Previous bond information
  next_bond: none,           // Next bond information (for lookahead)
  current_angle: 0deg,       // Current absolute angle
  visited_labels: (),        // Visited labels (prevent circular references)
  label_table: (:),          // Label table for references
)

// ============================ Molecule ============================

#let transform_fragment(ctx, node) = {
  generate_fragment(node)
}

#let transform_bond(ctx, bond) = {
  let (ctx, angle) = bond-angle(ctx, bond)

  // connecting points
  if ctx.parent_type == "cycle" {
    return (ctx, generate_bond(bond, angle, (from: 0, to: 0)))
  }

  (ctx, generate_bond(bond, angle, (:)))
}

#let transform_branch(ctx, branch, transform_molecule_fn) = {
  let (ctx, bond) = transform_bond(ctx, branch.bond)
  let body = transform_molecule_fn(ctx + (parent_type: "unit", ), branch.body)
  generate_branch(bond, body)
}

#let transform_cycle(ctx, cycle, transform_molecule_fn) = {
  let body = if cycle.body == none {
    range(cycle.faces).map(i => single()).join()
  } else {
    transform_molecule_fn(
      ctx + (
        parent_type: "cycle",
        position: ctx.position + (cycle.faces, 0),
      ),
      cycle.body
    )
  }

  let hetero = none
  (hetero, body) = if body.at(0).type == "fragment" {
    (body.at(0), body.slice(1))
  } else {
    (none, body)
  }
  (hetero, body) = if body.last().type == "fragment" {
    (body.last(), body.slice(0, -1))
  } else {
    (none, body)
  }

  if hetero != none {
    (hetero, generate_cycle(cycle, body))
  } else {
    (generate_cycle(cycle, body),)
  }
}

#let transform_unit(ctx, unit, transform_molecule_fn) = {
  if unit == none { return none }
  
  // Process the node
  let node = unit.node
  let generated = if node != none {
    if node.type == "fragment" {
      transform_fragment(ctx, node)
    } else if node.type == "cycle" {
      transform_cycle(ctx, node, transform_molecule_fn)
    } else if node.type == "label-ref" {
      generate_label_reference(node)
    } else if node.type == "implicit" {
      // Implicit node, no action needed
      none
    } else {
      panic("Unknown node type: " + node.type + " for node: " + repr(node))
    }
  } else {
    none
  }
  
  // Process branches
  let angles = unit-angles(ctx, unit)
  let branches = unit.branches.enumerate().zip(angles).map((((idx, branch), angle)) => {
    transform_branch(
      ctx + (
        parent_type: "branch",
        position: ctx.position + ((unit.branches.len(), idx),),
        current_angle: ctx.current_angle + angle,
      ),
      branch,
      transform_molecule_fn
    )
  })
  
  if generated != none {
    (..generated, ..branches.join())
  } else {
    branches.join()
  }
}

#let transform_molecule(ctx, molecule) = {
  if molecule == none or molecule.type != "molecule" { return () }

  let chain_length = molecule.rest.len()
  ctx += (
    current_angle: initial-angle(ctx, molecule),
    prev_bond: none,
    next_bond: if 0 < chain_length { molecule.rest.at(0).bond } else { none },
    position: ctx.position + ((chain_length, 0),)
  )

  // Transform first unit
  let first = transform_unit(
    ctx,
    molecule.first,
    transform_molecule
  )

  // Transform rest of chain
  let rest = if molecule.rest != none and chain_length > 0 {
    for (idx, item) in molecule.rest.enumerate() {
      let rest_ctx = ctx + (
        prev_bond: ctx.next_bond,
        next_bond: if idx + 1 < chain_length { molecule.rest.at(idx + 1).bond } else { none },
        position: ctx.position + ((chain_length, idx + 1),),
      )
      
      let (rest_ctx, bond) = transform_bond(rest_ctx, item.bond)
      let unit = transform_unit(rest_ctx, item.unit, transform_molecule)
      ctx = rest_ctx

      (..bond, ..unit)
    }
  } else {
    ()
  }

  return (..first, ..rest)
}

// ============================ Reaction ============================

#let transform_term(ctx, molecule) = {
  transform_molecule(ctx + (parent_type: none), molecule)
}

#let transform_operator(ctx, operator) = {
  generate_operator(operator)
}

#let transform_reaction(ctx, reaction) = {
  reaction.terms.map(term => {
    if term.type == "term" {
      transform_term(ctx, term.molecule)
    } else if term.type == "operator" {
      (transform_operator(ctx, term),)
    } else {
      panic("Unknown term type: " + term.type)
    }
  })
}

#let transform(reaction) = {
  let ctx = init_state()

  transform_reaction(ctx, reaction).join()
}

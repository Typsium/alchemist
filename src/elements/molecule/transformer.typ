#import "iupac-angle.typ": process_bond, IUPAC_ANGLES
#import "generator.typ": *

#let init_state() = (
  // Position and angle information
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
  let (ctx, angle) = process_bond(ctx, bond)

  (ctx, generate_bond(bond, angle))
}

#let transform_branch(ctx, branch, transform_molecule_fn) = {
  let (ctx, bond) = transform_bond(ctx, branch.bond)
  let body = transform_molecule_fn(ctx, branch.body)

  generate_branch(bond, body)
}

#let transform_cycle(ctx, cycle, transform_molecule_fn) = {
  let body = if cycle.body == none {
    (single(), single())
  } else {
    transform_molecule_fn(
      ctx + (
        parent_type: "cycle",
        position: ctx.position + (cycle.faces, 0),
      ),
      cycle.body
    )
  }

  // (hetero, body) = if body.at(0).type == "fragment" {
  //   (body.at(0), body.slice(1))
  // }
  // (hetero, body) = if body.at(n-1).type == "fragment" {
  //   (body.at(n-1), body.slice(1))
  // }
  // 0, n fragment の付け替え

  generate_cycle(cycle, body)
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
  
  // Process branches with proper context
  let branches = unit.branches.enumerate().map(((idx, branch)) => {
    transform_branch(
      ctx + (
        parent_type: "branch",
        position: ctx.position + ((unit.branches.len(), idx),)
      ),
      branch,
      transform_molecule_fn
    )
  })
  
  if generated != none {
    (generated, ..branches)
  } else {
    branches
  }
}

#let transform_molecule(ctx, molecule) = {
  if molecule == none or molecule.type != "molecule" { return () }

  let chain_length = molecule.rest.len()
  ctx += (
    current_angle: (IUPAC_ANGLES.main_chain_initial)(chain_length),
    prev_bond: none,
    next_bond: if chain_length > 0 { molecule.rest.at(0).bond } else { none },
    position: ctx.position + ((chain_length, 0),)
  )

  // Transform first unit
  let first = transform_unit(
    ctx,
    molecule.first,
    transform_molecule
  )

  // Transform rest of chain
  let processed_rest = if molecule.rest != none and molecule.rest.len() > 0 {
    for (idx, item) in molecule.rest.enumerate() {
      let rest_ctx = ctx + (
        prev_bond: ctx.next_bond,
        next_bond: if chain_length < molecule.rest.len() { molecule.rest.at(idx + 1).bond } else { none },
        position: ctx.position + ((chain_length, idx + 1),),
      )
      
      let (rest_ctx, bond) = transform_bond(rest_ctx, item.bond)
      let unit = transform_unit(rest_ctx, item.unit, transform_molecule)
      ctx = rest_ctx

      (bond, unit)
    }
  } else {
    ()
  }

  return first + processed_rest.join()
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
  }).join()
}

#let transform(reaction) = {
  let ctx = init_state()

  transform_reaction(ctx, reaction)
}

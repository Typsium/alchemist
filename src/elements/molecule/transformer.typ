#import "iupac-angle.typ": bond-angle, branch-angles, initial-angle, ring-angle, is-vertical-angle
#import "generator.typ": *
#import "../links.typ": single

#let init_state() = (
  position: (),              // Position in the molecule
  parent_type: none,         // Parent structure type
  prev_bond: none,           // Previous bond information
  next_bond: none,           // Next bond information
  current_angle: 0deg,       // Current absolute angle
  visited_labels: (),        // Visited labels (prevent circular references)
  label_table: (:),          // Label table for references
)

/// Get fragment's main-index (first non-H character index) from a unit
#let get-unit-main-index(unit) = {
  if unit == none or unit.node == none or unit.node.type != "fragment" {
    return none
  }
  unit.node.at("main-index", default: 0)
}

// ============================ Molecule ============================

#let transform_fragment(ctx, node) = {
  let fragment = generate_fragment(node)
  // Register label if present
  if node.at("name", default: none) != none {
    ctx.label_table.insert(node.name, fragment)
  }
  (ctx, fragment)
}

#let transform_bond(ctx, bond, prev_unit: none, next_unit: none) = {
  let (ctx, angle) = bond-angle(ctx, bond)

  // connecting points - merge with bond.options to preserve stroke: none etc.
  if ctx.parent_type == "cycle" {
    return (ctx, generate_bond(bond, angle, (from: 0, to: 0, ..bond.options)))
  }

  // For vertical bonds, connect to main-index (first non-H character)
  let options = bond.options

  if is-vertical-angle(angle) {
    let prev_main = get-unit-main-index(prev_unit)
    let next_main = get-unit-main-index(next_unit)
    if prev_main != none {
      options = (from: prev_main, ..options)
    }
    if next_main != none {
      options = (to: next_main, ..options)
    }
  }

  (ctx, generate_bond(bond, angle, options))
}

#let transform_branch(ctx, branch, transform_molecule_fn, parent_unit: none) = {
  // Get first unit of branch body for vertical bond detection
  let first_unit = if branch.body != none and branch.body.type == "molecule" {
    branch.body.first
  } else { none }
  let (ctx, bond) = transform_bond(ctx, branch.bond, prev_unit: parent_unit, next_unit: first_unit)
  let branch_ctx = ctx + (parent_type: "unit")
  let (branch_ctx, body) = transform_molecule_fn(branch_ctx, branch.body)
  // Merge label_table back to parent context
  ctx.label_table = branch_ctx.label_table
  (ctx, generate_branch(bond, body))
}

/// Find positions of units that have inner rings
#let find-inner-ring-positions(mol) = {
  if mol.type != "molecule" { return () }
  let positions = ()
  if mol.first != none and mol.first.rings.len() > 0 {
    positions.push(0)
  }
  for (idx, item) in mol.rest.enumerate() {
    if item.unit != none and item.unit.rings.len() > 0 {
      positions.push(idx + 1)
    }
  }
  positions
}

/// Move rings from last unit to second-to-last unit (for hetero case)
#let move-rings-to-earlier-position(mol) = {
  let rest = mol.rest
  if rest.len() < 2 { return mol }

  let last_unit = rest.last().unit
  if last_unit == none or last_unit.rings.len() == 0 { return mol }

  let second_last_unit = rest.at(-2).unit
  let merged_rings = if second_last_unit != none and second_last_unit.rings != none {
    (..second_last_unit.rings, ..last_unit.rings)
  } else {
    last_unit.rings
  }

  let new_second_last_unit = if second_last_unit != none {
    (..second_last_unit, rings: merged_rings)
  } else {
    (type: "unit", node: (type: "implicit"), branches: (), rings: merged_rings)
  }

  let new_rest = rest.slice(0, -2)
  new_rest.push((..rest.at(-2), unit: new_second_last_unit))
  new_rest.push((..rest.at(-1), unit: (..last_unit, rings: ())))

  (..mol, rest: new_rest)
}

/// Insert invisible bonds at specified positions (for polycyclic case)
#let insert-invisible-bonds(mol, positions) = {
  let new_rest = mol.rest
  let invisible_entry = (
    bond: (type: "bond", symbol: "-", name: none, options: (stroke: none)),
    unit: (type: "unit", node: (type: "implicit"), branches: (), rings: ())
  )
  for idx in positions.rev() {
    new_rest = (..new_rest.slice(0, idx), invisible_entry, ..new_rest.slice(idx))
  }
  (..mol, rest: new_rest)
}

#let transform_cycle(ctx, cycle, transform_molecule_fn, angle: none, absolute: false) = {
  let (body, cycle_ctx) = if cycle.body == none {
    (range(cycle.faces).map(i => single()).join(), ctx)
  } else {
    let outer_body_len = if cycle.body.rest != none { cycle.body.rest.len() } else { 0 }
    let cycle_ctx = ctx + (
      parent_type: "cycle",
      position: ctx.position + ((cycle.faces, 0),),
      outer_cycle_body_len: outer_body_len,
      outer_cycle_faces: cycle.faces,
    )

    let inner_ring_positions = find-inner-ring-positions(cycle.body)
    let bonds_needed = cycle.faces - outer_body_len

    let modified_body = if bonds_needed == 0 and inner_ring_positions.len() > 0 {
      // Hetero: move rings earlier so drawer processes them before face-count limit
      move-rings-to-earlier-position(cycle.body)
    } else if bonds_needed > 0 and inner_ring_positions.len() > 0 {
      // Polycyclic: insert invisible bonds
      let count = calc.min(bonds_needed, inner_ring_positions.len())
      insert-invisible-bonds(cycle.body, inner_ring_positions.slice(0, count))
    } else {
      cycle.body
    }

    let (cycle_ctx, transformed) = transform_molecule_fn(cycle_ctx, modified_body)
    (transformed, cycle_ctx)
  }

  // Merge label_table back to parent context
  ctx.label_table = cycle_ctx.label_table

  let hetero = ()
  if type(body) == array and body.len() > 0 {
    if body.at(0).type == "fragment" {
      hetero.push(body.at(0))
      body = body.slice(1)
    }
    if body.len() > 0 and body.last().type == "fragment" {
      hetero.push(body.last())
      body = body.slice(0, -1)
    }
  }

  // Build cycle dict with angle in args (inline to preserve angle without changing generator.typ)
  let cycle_dict = (
    type: "cycle",
    faces: cycle.faces,
    body: body,
    args: if angle != none {
      if absolute { (absolute: angle) } else { (relative: angle) }
    } else { (:) },
  )

  // All elements stay in body - drawer handles cycles/branches after links naturally
  (ctx, (..hetero, cycle_dict))
}

#let transform_unit(ctx, unit, transform_molecule_fn) = {
  if unit == none { return (ctx, ()) }

  // Process the node
  let node = unit.node
  let (ctx, generated) = if node != none {
    if node.type == "fragment" {
      transform_fragment(ctx, node)
    } else if node.type == "label-ref" {
      (ctx, generate_label_reference(node))
    } else if node.type == "implicit" {
      // Implicit node, no action needed
      (ctx, ())
    } else {
      panic("Unknown node type: " + node.type + " for node: " + repr(node))
    }
  } else {
    (ctx, ())
  }

  // Process branches
  let angles = branch-angles(ctx, unit.branches)
  let branches = ()
  for ((idx, branch), angle) in unit.branches.enumerate().zip(angles) {
    let branch_ctx = ctx + (
      parent_type: "branch",
      position: ctx.position + ((unit.branches.len(), idx),),
      current_angle: ctx.current_angle + angle,
    )
    let (branch_ctx, branch_result) = transform_branch(
      branch_ctx,
      branch,
      transform_molecule_fn,
      parent_unit: unit
    )
    // Merge label_table back
    ctx.label_table = branch_ctx.label_table
    branches.push(branch_result)
  }

  // Process rings
  let rings = ()
  for (idx, ring) in unit.rings.enumerate() {
    let (angle, absolute) = ring-angle(ctx, ring, unit.rings.len(), idx)
    let ring_ctx = ctx + (
      parent_type: "cycle",
      position: ctx.position + ((unit.rings.len(), idx),),
      current_angle: if angle != none { angle } else { ctx.current_angle },
    )
    let (ring_ctx, ring_result) = transform_cycle(
      ring_ctx,
      ring,
      transform_molecule_fn,
      angle: angle,
      absolute: absolute,
    )
    // Merge label_table back
    ctx.label_table = ring_ctx.label_table

    rings.push(ring_result)
  }

  (ctx, (..generated, ..branches.join(), ..rings.join()))
}

#let transform_molecule(ctx, molecule) = {
  if molecule == none or molecule.type != "molecule" { return (ctx, ()) }

  let chain_length = molecule.rest.len()
  let position = ctx.position
  // Preserve current_angle when inside a branch (parent_type == "unit")
  // Reset to initial-angle for top-level and cycle body
  let base_angle = if ctx.parent_type == "unit" {
    ctx.current_angle
  } else {
    initial-angle(ctx, molecule)
  }
  ctx += (
    current_angle: base_angle,
    prev_bond: none,
    next_bond: if 0 < chain_length { molecule.rest.at(0).bond } else { none },
    position: position + ((chain_length, 0),)
  )

  // Transform first unit
  let (ctx, first) = transform_unit(
    ctx,
    molecule.first,
    transform_molecule
  )

  // Transform rest of chain
  let rest = ()
  let prev_unit = molecule.first
  if molecule.rest != none and chain_length > 0 {
    for (idx, item) in molecule.rest.enumerate() {
      let rest_ctx = ctx + (
        prev_bond: ctx.next_bond,
        next_bond: if idx + 1 < chain_length { molecule.rest.at(idx + 1).bond } else { none },
        position: position + ((chain_length, idx + 1),),
      )

      let (rest_ctx, bond) = transform_bond(rest_ctx, item.bond, prev_unit: prev_unit, next_unit: item.unit)
      let (rest_ctx, unit) = transform_unit(rest_ctx, item.unit, transform_molecule)
      ctx = rest_ctx
      prev_unit = item.unit

      rest += (..bond, ..unit)
    }
  }

  (ctx, (..first, ..rest))
}

// ============================ Reaction ============================

#let transform_term(ctx, molecule) = {
  transform_molecule(ctx + (parent_type: none), molecule)
}

#let transform_operator(ctx, operator) = {
  (ctx, generate_operator(operator))
}

#let transform_reaction(ctx, reaction) = {
  let result = ()
  for term in reaction.terms {
    if term.type == "term" {
      let (ctx_new, transformed) = transform_term(ctx, term.molecule)
      ctx = ctx_new
      result.push(transformed)
    } else if term.type == "operator" {
      let (ctx_new, transformed) = transform_operator(ctx, term)
      ctx = ctx_new
      result.push((transformed,))
    } else {
      panic("Unknown term type: " + term.type)
    }
  }
  (ctx, result)
}

#let transform(reaction) = {
  let ctx = init_state()
  let (_, result) = transform_reaction(ctx, reaction)
  result.join()
}

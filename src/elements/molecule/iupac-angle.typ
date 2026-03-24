// relative angles
#let IUPAC_ANGLES = (
  main_chain_initial: chain_length => if chain_length >= 2 { 30deg } else { 0deg } - 60deg,
  zigzag: idx => if calc.rem(idx, 2) == 1 { 60deg } else { -60deg },
  incoming: -180deg,
  straight: 0deg,
  
  sp3: (60deg, -60deg, -120deg, -180deg),
  sp2: (60deg, -60deg, -180deg),
  sp: (0deg, -180deg),

  branch_angles: (n, idx) => 180deg - (idx + 1) * 360deg / n,
  cycle_edge_angles: n => 360deg / n,
  cycle_branch_angles: n => -150deg + 180deg / n,
)

// Calculate the angles for the hybridization of the bonds
#let hybridization_angles(bonds, branches_len) = {
  let n = bonds.len()
  let triple = bonds.filter(b => b.symbol == "#").len()
  let double = bonds.filter(b => b.symbol == "=").len()
  let other = bonds.filter(b => b.symbol != "#" and b.symbol != "=").len()

  if n == 2 and (triple >= 1 or double >= 2) { IUPAC_ANGLES.sp }
  else if branches_len <= 1 and (double >= 1 or other >= 2) { IUPAC_ANGLES.sp2 }
  else if branches_len <= 2 { IUPAC_ANGLES.sp3 }
  else { range(n).map(i => (IUPAC_ANGLES.branch_angles)(n, i)) }
}

#let bond-angle(ctx, bond) = {
  let (n, idx) = ctx.position.last()

  let angle = if ctx.parent_type == "unit" or ctx.parent_type == none {
    ctx.current_angle + (IUPAC_ANGLES.zigzag)(idx)
  } else if ctx.parent_type == "cycle" {
    let (faces, _) = ctx.position.at(-2)
    ctx.current_angle + (IUPAC_ANGLES.cycle_edge_angles)(faces)
  } else if ctx.parent_type == "branch" {
    ctx.current_angle
  } else {
    panic("Unknown parent type: " + ctx.parent_type)
  }

  return (ctx + (current_angle: angle), angle)
}

// Calculate relative angle for a ring attached to a main chain unit
// Returns (angle, absolute) tuple, or (none, false) if default behavior should be used
#let ring-angle(ctx, ring, rings_count, idx) = {
  if ctx.parent_type == "cycle" {
    // Inside a cycle - use context info for polycyclic vs hetero detection
    let outer_faces = ctx.at("outer_cycle_faces", default: none)
    let outer_bonds = ctx.at("outer_cycle_body_len", default: none)

    // Also check inner ring's bonds vs faces
    let inner_faces = ring.faces
    let inner_bonds = if ring.body != none and ring.body.type == "molecule" and ring.body.rest != none {
      ring.body.rest.len()
    } else { 0 }

    // Polycyclic: outer or inner has fewer bonds than faces
    let is_polycyclic = outer_bonds < outer_faces or inner_bonds < inner_faces

    if is_polycyclic {
      (none, false)
    } else {
      // Hetero - use branch angle
      ((IUPAC_ANGLES.cycle_branch_angles)(outer_faces), false)
    }
  } else if ctx.prev_bond != none and ctx.next_bond != none {
    // MIDDLE of chain - ring goes as a branch
    let base = 0deg
    if rings_count > 1 {
      base = base + 60deg * (idx - (rings_count - 1) / 2)
    }
    (base, false)
  } else if ctx.prev_bond != none or ctx.next_bond != none {
    // START or END of chain - ring extends parallel to chain direction
    let (_, chain_idx) = ctx.position.last()
    let edge = 180deg / ring.faces
    let base = if ctx.prev_bond == none {
      // START: extend opposite to chain direction
      ctx.current_angle + 150deg + edge
    } else {
      // END: continue in chain direction
      // Uses main_chain_initial pattern for consistency
      let offset = 120deg + (IUPAC_ANGLES.main_chain_initial)(chain_idx) + (IUPAC_ANGLES.zigzag)(chain_idx) / 2
      ctx.current_angle - offset + edge
    }
    if rings_count > 1 {
      base = base + 60deg * (idx - (rings_count - 1) / 2)
    }
    (base, false)
  } else {
    (none, false)
  }
}

#let branch-angles(ctx, branches) = {
  let (n, idx) = ctx.position.last()

  if branches.len() == 0 { return () }

  if ctx.parent_type == "cycle" {
    let (faces, _) = ctx.position.at(-2)
    let base_angle = (IUPAC_ANGLES.cycle_branch_angles)(faces)

    let branch_count = branches.len()
    if branch_count == 1 {
      return (base_angle,)
    }

    // For multiple branches, spread them symmetrically
    let spread = 60deg
    return range(branch_count).map(i => {
      base_angle + spread * (i - (branch_count - 1) / 2)
    })
  }

  let bonds = branches.map(b => b.bond)
  if ctx.prev_bond != none { bonds.push(ctx.prev_bond) }
  if ctx.next_bond != none { bonds.push(ctx.next_bond) }

  let angles = hybridization_angles(bonds, branches.len()).filter(
    angle => (ctx.prev_bond == none or angle != IUPAC_ANGLES.incoming)
      and (ctx.next_bond == none or angle != (IUPAC_ANGLES.zigzag)(idx + 1))
  )

  // first branches of the main chain
  // Offset by 180deg + zigzag to face opposite to outgoing direction
  if ctx.prev_bond == none and ctx.parent_type == none {
    let outgoing = (IUPAC_ANGLES.zigzag)(idx + 1)
    angles = angles.map(angle => angle + 180deg + outgoing)
  }

  return angles
}

#let initial-angle(ctx, molecule) = {
  return (IUPAC_ANGLES.main_chain_initial)(molecule.rest.len())
}

/// Check if angle is vertical (around 90deg or 270deg)
/// Used to determine when to connect to main atom instead of H
#let is-vertical-angle(angle) = {
  let a = calc.rem(angle / 1deg, 360) * 1deg
  if a < 0deg { a += 360deg }
  (a > 60deg and a < 120deg) or (a > 240deg and a < 300deg)
}

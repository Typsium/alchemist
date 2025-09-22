#import "@preview/cetz:0.2.2"

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
  cycle_edge_angles: (n, idx) => -90deg + (idx + 1) * 360deg / n,
  cycle_branch_angles: (n, idx) => -180deg + (idx + 1/2) * 360deg / n,
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
    ctx.current_angle + (IUPAC_ANGLES.cycle_edge_angles)(n, idx)
  } else if ctx.parent_type == "branch" {
    ctx.current_angle
  } else {
    panic("Unknown parent type: " + ctx.parent_type)
  }

  return (ctx + (current_angle: angle), angle)
}

#let unit-angles(ctx, unit) = {
  let (n, idx) = ctx.position.last()
  if ctx.parent_type == "cycle" {
    return range(n).map(i => ctx.current_angle + (IUPAC_ANGLES.cycle_branch_angles)(n, i))
  }

  let branches = unit.branches
  if branches.len() == 0 { return () }

  let bonds = branches.map(b => b.bond)
  if ctx.prev_bond != none { bonds.push(ctx.prev_bond) }
  if ctx.next_bond != none { bonds.push(ctx.next_bond) }

  let angles = hybridization_angles(bonds, branches.len()).filter(
    angle => (ctx.prev_bond == none or angle != IUPAC_ANGLES.incoming)
      and (ctx.next_bond == none or angle != (IUPAC_ANGLES.zigzag)(idx + 1))
  )

  // first branches of the main chain
  if ctx.prev_bond == none and ctx.parent_type == none {
    angles = angles.map(angle => angle + 180deg)
  }
  
  return angles
}

#let initial-angle(ctx, molecule) = {
  if molecule.first.node.type == "cycle" {
    return (IUPAC_ANGLES.cycle_branch_angles)(molecule.first.node.faces, -1)
  }

  return (IUPAC_ANGLES.main_chain_initial)(molecule.rest.len())
}

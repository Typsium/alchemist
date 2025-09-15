#import "@preview/cetz:0.2.2"

// relative angles
#let IUPAC_ANGLES = (
  main_chain_initial: chain_length => if chain_length >= 2 { -30deg } else { -60deg },
  zigzag_up: 60deg,
  zigzag_down: -60deg,
  incoming: -180deg,
  
  sp3: (60deg, -40deg, -80deg, -180deg),
  sp2: (60deg, -60deg, -180deg),
  sp: (0deg, -180deg),
  angles: n => range(n).map(i => 180deg - 360deg / n * (i + 1)),

  ring: n => range(n).map(i => 180deg - 360deg / n * (i + 1)),
)

#let hybridization_angles(bonds) = {
  let n = bonds.len()
  let triple = bonds.filter(b => b.symbol == "#").len()
  let double = bonds.filter(b => b.symbol == "=").len()
  let other = bonds.filter(b => b.symbol != "#" and b.symbol != "=").len()

  if n == 2 and (triple >= 1 or double >= 2) { IUPAC_ANGLES.sp }
  else if n <= 3 and (double >= 1 or other >= 2) { IUPAC_ANGLES.sp2 }
  else if n <= 4 { IUPAC_ANGLES.sp3 }
  else { (IUPAC_ANGLES.angles)(n) }
}

#let calc_unit_angles(unit, prev_bond, next_bond, current_angle, index) = {
  let branches = unit.at("branches", default: ())
  if branches.len() == 0 { return () }

  let bonds = branches.map(b => b.bond)
  if prev_bond != none { bonds.push(prev_bond) }
  if next_bond != none { bonds.push(next_bond) }

  let angles = hybridization_angles(bonds).filter(
    angle => angle != IUPAC_ANGLES.incoming
      and (calc.rem(index, 2) == 0 or angle != IUPAC_ANGLES.zigzag_up)
      and (calc.rem(index, 2) == 1 or angle != IUPAC_ANGLES.zigzag_down)
  )
  
  return angles
}

// Process all branches of a unit with their calculated angles
#let apply_angles_to_branches(branches, branch_angles, calculate_angles_fn) = {
  if branches == none or branches.len() == 0 { return () }
  
  let new_branches = ()
  for (idx, branch) in branches.enumerate() {
    if idx < branch_angles.len() {
      new_branches.push((
        type: "branch",
        bond: branch.bond + (relative: branch_angles.at(idx)),
        body: calculate_angles_fn(branch.body)
      ))
    } else {
      new_branches.push(branch)
    }
  }
  return new_branches
}

// Create a new unit with updated branches
#let create_unit_with_branch_angles(unit, branch_angles, calculate_angles_fn) = {
  if unit == none { return unit }
  
  let branches = unit.at("branches", default: ())
  if branches == none or branches.len() == 0 { return unit }
  
  let new_branches = apply_angles_to_branches(branches, branch_angles, calculate_angles_fn)
  return unit + (branches: new_branches)
}

// Calculate angle for main chain position (zigzag pattern)
#let get_next_chain_angle(current_angle, position) = {
  let angle_delta = if calc.rem(position, 2) == 0 {
    IUPAC_ANGLES.zigzag_up
  } else {
    IUPAC_ANGLES.zigzag_down
  }
  return current_angle + angle_delta
}

// Process the first unit of the molecule
#let process_first_unit(unit, next_bond, initial_angle, calculate_angles_fn, root: false) = {
  if unit == none { return unit }
  
  let branch_angles = calc_unit_angles(unit, none, next_bond, initial_angle, 0)
  if root {
    branch_angles = branch_angles.map(angle => angle + 180deg)
  }
  return create_unit_with_branch_angles(unit, branch_angles, calculate_angles_fn)
}

// Process a single rest unit
#let process_rest_unit(item, index, rest, current_angle, calculate_angles_fn) = {
  // Calculate bond angle for this position
  let new_angle = get_next_chain_angle(current_angle, index)
  
  // Update bond with absolute angle
  let new_bond = item.bond + (absolute: new_angle)
  
  // Determine next bond for angle calculation
  let next_bond = if index + 1 < rest.len() {
    rest.at(index + 1).bond
  } else { none }
  
  // Calculate branch angles for this unit
  let branch_angles = calc_unit_angles(
    item.unit, 
    new_bond, 
    next_bond, 
    new_angle,
    index
  )
  
  // Create updated unit
  let new_unit = create_unit_with_branch_angles(item.unit, branch_angles, calculate_angles_fn)
  
  return (bond: new_bond, unit: new_unit, angle: new_angle)
}

// Process all rest units in the chain
#let process_rest_chain(rest, initial_angle, calculate_angles_fn) = {
  if rest == none or rest.len() == 0 { return () }
  
  let new_rest = ()
  let current_angle = initial_angle
  
  for (idx, item) in rest.enumerate() {
    let processed = process_rest_unit(item, idx, rest, current_angle, calculate_angles_fn)
    current_angle = processed.angle
    new_rest.push((bond: processed.bond, unit: processed.unit))
  }
  
  return new_rest
}

// Main angle calculation - orchestrates the refactored helpers
#let calculate_angles(molecule) = {
  // Validate input
  if molecule == none or molecule.type != "molecule" { 
    return molecule 
  }
  
  // Calculate initial angle based on chain length
  let chain_length = molecule.rest.len() 
  let initial_angle = (IUPAC_ANGLES.main_chain_initial)(chain_length)
  
  // Process first unit
  let next_bond = if molecule.rest.len() > 0 {
    molecule.rest.at(0).bond
  } else { none }
  
  let new_first = process_first_unit(
    molecule.first, 
    next_bond, 
    initial_angle,
    calculate_angles,
    root: true
  )
  
  // Process rest of the chain
  let new_rest = process_rest_chain(
    molecule.rest, 
    initial_angle,
    calculate_angles
  )
  
  return (
    type: "molecule",
    first: new_first,
    rest: new_rest
  )
}

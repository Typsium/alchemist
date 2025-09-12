#import "@preview/cetz:0.2.2"

// relative angles
#let IUPAC_ANGLES = (
  main_chain_initial: chain_length => if chain_length >= 2 { 30deg } else { 0deg },
  zigzag_up: 60deg,
  zigzag_down: -60deg,
  incoming: -180deg,
  
  sp3: (60deg, -60deg, -120deg, -180deg),
  sp2: (60deg, -60deg, -180deg),
  sp: (0deg, -180deg),
  angles: n => range(n).map(i => 180deg - 360deg / n * (i + 1)),

  ring: n => range(n).map(i => 180deg - 360deg / n * (i + 1)),
)

#let get_hybridization(bonds) = {
  let types = bonds.map(b => b.at("symbol", default: "-"))
  if "#" in types or types.filter(t => t == "#").len() >= 2 { "sp" }
  else if "=" in types { "sp2" }
  else { "sp3" }
}

#let calc_unit_angles(unit, prev_bond, next_bond, current_angle) = {
  let branches = unit.at("branches", default: ())
  // Count all bonds
  let n = branches.len() + if prev_bond != none { 1 } else { 0 } + if next_bond != none { 1 } else { 0 }
  
  let bonds = ()
  if prev_bond != none { bonds.push(prev_bond) }
  if next_bond != none { bonds.push(next_bond) }
  
  let hyb = get_hybridization(bonds)
  let angles = if hyb == "sp3" and n == 4 { IUPAC_ANGLES.sp3 }
    else if hyb == "sp2" and n == 3 { IUPAC_ANGLES.sp2 }
    else if hyb == "sp" and n == 2 { IUPAC_ANGLES.sp }
    else { (IUPAC_ANGLES.angles)(n) }
  
  // Calculate branch angles
  let branch_angles = ()
  let angle_idx = 0
  
  if prev_bond != none { angle_idx += 1 }  // Skip incoming angle
  if next_bond != none { angle_idx += 1 }  // Skip outgoing angle
  
  for _ in branches {
    branch_angles.push(current_angle + angles.at(calc.rem(angle_idx, angles.len())))
    angle_idx += 1
  }
  
  return branch_angles
}

// Main angle calculation
#let calculate_angles(molecule) = {
  if molecule == none or molecule.type != "molecule" { return molecule }
  
  let chain_length = if molecule.rest != none { molecule.rest.len() } else { 0 }
  let current_angle = (IUPAC_ANGLES.main_chain_initial)(chain_length)
  
  // Create new first unit with angles
  let new_first = molecule.first
  if molecule.first != none {
    let unit = molecule.first
    let next_bond = if molecule.rest != none and molecule.rest.len() > 0 {
      molecule.rest.at(0).bond
    } else { none }
    
    let branch_angles = calc_unit_angles(unit, none, next_bond, current_angle)
    
    // Create new branches with angles
    let new_branches = ()
    let branches = unit.at("branches", default: ())
    if branches != none and branches.len() > 0 {
      for (b_idx, branch) in branches.enumerate() {
        if b_idx < branch_angles.len() {
          // Create new bond with angle
          let new_bond = if branch.bond != none {
            branch.bond + (relative: branch_angles.at(b_idx))
          } else { branch.bond }
          
          // Recursively calculate angles for branch body
          let new_body = if branch.at("body", default: none) != none {
            calculate_angles(branch.body)
          } else { branch.at("body", default: none) }
          
          // Create new branch with updated bond and body
          let new_branch = (
            type: branch.type,
            bond: new_bond,
            body: new_body
          )
          new_branches.push(new_branch)
        } else {
          new_branches.push(branch)
        }
      }
    }
    new_first = unit + (branches: new_branches)
  }
  
  // Process rest and create new rest array
  let new_rest = ()
  if molecule.rest != none {
    for (r_idx, item) in molecule.rest.enumerate() {
      current_angle += if calc.rem(r_idx, 2) == 0 {
        IUPAC_ANGLES.zigzag_up
      } else {
        IUPAC_ANGLES.zigzag_down
      }
      
      // Create new bond with absolute angle for main chain
      let new_bond = item.bond + (absolute: current_angle)
      
      let unit = item.unit
      let prev_bond = new_bond
      let next_bond = if r_idx + 1 < molecule.rest.len() {
        molecule.rest.at(r_idx + 1).bond
      } else { none }
      
      let branch_angles = calc_unit_angles(unit, prev_bond, next_bond, current_angle)
      
      // Create new unit with branch angles
      let new_unit = unit
      let branches = unit.at("branches", default: ())
      if unit != none and branches != none and branches.len() > 0 {
        let new_branches = ()
        for (b_idx, branch) in branches.enumerate() {
          if b_idx < branch_angles.len() {
            // Create new bond with angle
            let new_bond = if branch.bond != none {
              branch.bond + (relative: branch_angles.at(b_idx))
            } else { branch.bond }
            
            // Recursively calculate angles for branch body
            let new_body = if branch.at("body", default: none) != none {
              calculate_angles(branch.body)
            } else { branch.at("body", default: none) }
            
            // Create new branch with updated bond and body
            let new_branch = (
              type: branch.type,
              bond: new_bond,
              body: new_body
            )
            new_branches.push(new_branch)
          } else {
            new_branches.push(branch)
          }
        }
        new_unit = unit + (branches: new_branches)
      }
      
      new_rest.push((bond: new_bond, unit: new_unit))
    }
  }
  
  // Return new molecule with angles
  return (
    type: "molecule",
    first: new_first,
    rest: new_rest
  )
}
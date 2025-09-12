// Merger logic for label continuation system

#import "parser.typ": molecule-parser, parse

// Parse multiple molecular parts separated by whitespace
#let parse-molecular-parts(input) = {
  // Split by whitespace while preserving structure
  let parts = ()
  let current = ""
  let depth = 0
  
  for char in input {
    if char == "(" { depth += 1 }
    else if char == ")" { depth -= 1 }
    
    if depth == 0 and (char == " " or char == "\t" or char == "\n") {
      if current != "" {
        parts.push(current)
        current = ""
      }
    } else {
      current += char
    }
  }
  
  if current != "" {
    parts.push(current)
  }
  
  // Parse each part
  let molecules = ()
  for part in parts {
    let result = parse(molecule-parser(), part)
    if result.success {
      molecules.push(result.value)
    }
  }
  
  return molecules
}

// Separate main molecule from continuations
#let separate-molecules(molecules) = {
  let main = none
  let continuations = ()
  
  for mol in molecules {
    if mol.at("is_continuation", default: false) {
      continuations.push(mol)
    } else if main == none {
      main = mol
    } else {
      // Multiple main molecules - merge them sequentially
      // This could be extended to handle multiple main molecules
      panic("Multiple main molecules found - only one non-continuation molecule allowed")
    }
  }
  
  if main == none {
    panic("No main molecule found - at least one non-continuation molecule required")
  }
  
  return (main: main, continuations: continuations)
}

// Build registry of labeled fragments in the molecule
#let build-label-registry(mol) = {
  let visit(mol, path, registry) = {
    if mol == none { return registry }
    
    let result = registry
    
    // Process first unit
    if mol.at("first", default: none) != none {
      let unit = mol.first
      let unit_path = path + ((type: "first"),)
      
      // Check if node has a label
      if unit.node != none and unit.node.type == "fragment" {
        if unit.node.at("name", default: none) != none {
          result.insert(unit.node.name, (unit: unit, path: unit_path))
        }
      }
      
      // Process branches of first unit
      if unit.at("branches", default: ()) != none {
        for (idx, branch) in unit.branches.enumerate() {
          if branch.at("body", default: none) != none {
            result = visit(branch.body, unit_path + ((type: "branch", idx: idx),), result)
          }
        }
      }
    }
    
    // Process rest units
    if mol.at("rest", default: ()) != none {
      for (idx, item) in mol.rest.enumerate() {
        if item.at("unit", default: none) != none {
          let unit = item.unit
          let unit_path = path + ((type: "rest", idx: idx),)
          
          // Check if node has a label
          if unit.node != none and unit.node.type == "fragment" {
            if unit.node.at("name", default: none) != none {
              result.insert(unit.node.name, (unit: unit, path: unit_path))
            }
          }
          
          // Process branches
          if unit.at("branches", default: ()) != none {
            for (b_idx, branch) in unit.branches.enumerate() {
              if branch.at("body", default: none) != none {
                result = visit(branch.body, unit_path + ((type: "branch", idx: b_idx),), result)
              }
            }
          }
        }
      }
    }
    
    return result
  }
  
  return visit(mol, (), (:))
}

// Create a molecule structure from a continuation
#let create-molecule-from-continuation(cont) = {
  // Remove the label reference from the first unit
  let new_first = if cont.rest.len() > 0 {
    cont.rest.at(0).unit
  } else {
    (type: "unit", node: (type: "implicit"), branches: ())
  }
  
  let new_rest = if cont.rest.len() > 1 {
    cont.rest.slice(1)
  } else {
    ()
  }
  
  (
    type: "molecule",
    first: new_first,
    rest: new_rest
  )
}

// Add branch to a unit at the given path in the molecule
#let add-branch-at-path(mol, path, branch) = {
  if path.len() == 0 { return mol }
  
  let step = path.at(0)
  let remaining_path = path.slice(1)
  
  if step.type == "first" {
    if remaining_path.len() == 0 {
      // We're at the target unit
      if mol.first.at("branches", default: none) == none {
        mol.first.branches = ()
      }
      mol.first.branches.push(branch)
    } else {
      // Continue deeper
      mol.first = add-branch-to-unit(mol.first, remaining_path, branch)
    }
  } else if step.type == "rest" {
    let idx = step.idx
    if remaining_path.len() == 0 {
      // We're at the target unit
      if mol.rest.at(idx).unit.at("branches", default: none) == none {
        mol.rest.at(idx).unit.branches = ()
      }
      mol.rest.at(idx).unit.branches.push(branch)
    } else {
      // Continue deeper
      mol.rest.at(idx).unit = add-branch-to-unit(mol.rest.at(idx).unit, remaining_path, branch)
    }
  }
  
  return mol
}

// Helper to add branch to a unit with nested branches
#let add-branch-to-unit(unit, path, branch) = {
  if path.len() == 0 {
    if unit.at("branches", default: none) == none {
      unit.branches = ()
    }
    unit.branches.push(branch)
    return unit
  }
  
  let step = path.at(0)
  if step.type == "branch" {
    let idx = step.idx
    let remaining_path = path.slice(1)
    unit.branches.at(idx).body = add-branch-at-path(unit.branches.at(idx).body, remaining_path, branch)
  }
  
  return unit
}

// Merge continuations into the main molecule
#let merge-continuations(main, continuations) = {
  let registry = build-label-registry(main)
  let result = main
  
  for cont in continuations {
    let target_label = cont.continuation_label
    
    if target_label not in registry {
      panic("Label '" + target_label + "' not found in main molecule")
    }
    
    let target_info = registry.at(target_label)
    let target_path = target_info.path
    
    // Get the first bond from the continuation
    let cont_bond = if cont.rest.len() > 0 {
      cont.rest.at(0).bond
    } else {
      (type: "bond", symbol: "-")  // Default to single bond
    }
    
    // Create branch from continuation
    let branch_body = create-molecule-from-continuation(cont)
    
    let branch = (
      type: "branch",
      bond: cont_bond,
      body: branch_body
    )
    
    // Add branch at the target path
    result = add-branch-at-path(result, target_path, branch)
  }
  
  return result
}

// Main entry point for parsing with continuations
#let parse-with-continuations(input) = {
  // Parse all molecular parts
  let molecules = parse-molecular-parts(input)
  
  if molecules.len() == 0 {
    panic("No valid molecules found in input")
  }
  
  if molecules.len() == 1 {
    // Single molecule, no continuations needed
    return molecules.at(0)
  }
  
  // Separate main and continuations
  let separated = separate-molecules(molecules)
  
  // Merge continuations into main structure
  return merge-continuations(separated.main, separated.continuations)
}
#import "../links.typ": single, double, triple, cram-filled-right, cram-filled-left, cram-dashed-right, cram-dashed-left
#import "iupac-angle.typ": calculate-all-angles, calculate-ring-rotation

// Inline branch function to avoid circular reference
#let create-branch(body, args: (:)) = {
  ((
    type: "branch",
    body: body,
    args: args
  ),)
}

// Inline cycle function to avoid circular reference
#let create-cycle(faces, body, args: (:)) = {
  ((
    type: "cycle",
    faces: faces,
    body: body,
    args: args
  ),)
}

#let create-fragment(mol, name: none, links: (:), lewis: (), vertical: false, colors: none) = {
  let atom-count = if mol == none or mol == "" {
    1
  } else if type(mol) == str {
    mol.len()
  } else if type(mol) == content {
    1
  } else {
    1
  }
  
  (
    (
      type: "fragment",
      name: name,
      atoms: if type(mol) == array { mol } else { (mol,) },
      colors: colors,
      links: links,
      lewis: lewis,
      vertical: vertical,
      count: atom-count,
    ),
  )
}

#let process-atom(atom) = {
  if atom == none or atom == "" { return () }
  
  // If atom is already content type, return as is
  if type(atom) == content {
    return (atom,)
  }
  
  if type(atom) == str {
    // Pattern with function name followed by parentheses
    let func-pattern = regex("^[a-z-]+\(.*\)$")
    if atom.match(func-pattern) != none {
      return (eval(atom, mode: "markup"),)
    }
    
    // Split each element separately like CH3 -> [$C$, $H_3$]
    let elements = ()
    let i = 0
    let chars = atom.clusters()
    
    while i < chars.len() {
      let char = chars.at(i)
      
      if char.match(regex("^[A-Z]$")) != none {
        let element = char
        
        if i + 1 < chars.len() and chars.at(i + 1).match(regex("^[a-z]$")) != none {
          element += " " + chars.at(i + 1)
          i += 1
        }
        
        let numbers = ""
        while i + 1 < chars.len() and chars.at(i + 1).match(regex("^[0-9]$")) != none {
          numbers += chars.at(i + 1)
          i += 1
        }
        if numbers != "" {
          element += "_" + numbers
        }
        
        elements.push(eval("$" + element + "$", mode: "markup"))
      } else {
        elements.push(eval("$" + char + "$", mode: "markup"))
      }
      
      i += 1
    }
    return elements
  }
  return (atom,)
}

// Get atom priority and find connection point
#let get-atom-connection-point(fragment, from-end: false) = {
  let position = 0
  for atom in fragment {
    if atom == "C" or atom == "N" or atom == "O" {
      return position
    }
    position += 1
  }

  return 0
}

// Determine bond connection points based on atom priority (for rings) or angle (for non-rings)
#let get-bond-connection-points(angle, from-atom, to-atom, in-ring) = {
  if angle == none {
    return (from: none, to: none)
  }
  
  let from-point = none
  let to-point = none
  
  // Outside ring: use angle to determine connection direction
  while angle > 180deg { angle -= 360deg }
  while angle < -180deg { angle += 360deg }
  
  if in-ring or angle == 90deg or angle == -90deg {
    // Inside ring: use atom priority to determine connection points
    let from-pos = get-atom-connection-point(from-atom)
    let to-pos = get-atom-connection-point(to-atom)
    
    // Use the position from the connection point info
    from-point = from-pos
    to-point = to-pos
  } else if angle > -90deg and angle < 90deg {
    // Left to right connection
    from-point = calc.max(0, from-atom.len() - 1)
    to-point = 0
  } else {
    // Right to left connection
    from-point = 0
    to-point = calc.max(0, to-atom.len() - 1)
  }
  
  return (from: from-point, to: to-point)
}

#let get-bond-with-angle(bond-type, angle: none, from-atom: none, to-atom: none, in-ring: false) = {
  let bond = if bond-type == "double" {
    double
  } else if bond-type == "triple" {
    triple
  } else if bond-type == "wedge-filled-right" {
    cram-filled-right
  } else if bond-type == "wedge-filled-left" {
    cram-filled-left
  } else if bond-type == "wedge-dashed-right" {
    cram-dashed-right
  } else if bond-type == "wedge-dashed-left" {
    cram-dashed-left
  } else {
    single
  }
  
  // Calculate connection points and create bond with appropriate parameters
  let bond-args = (:)
  
  // Add angle if specified (now absolute angle)
  if angle != none {
    bond-args.insert("absolute", angle)
  }
  
  // Add connection points if atoms are specified
  if from-atom != none and to-atom != none {
    let connection-points = get-bond-connection-points(
      angle, from-atom, to-atom, in-ring
    )
    
    // Add connection points to bond arguments
    if connection-points.from != none {
      bond-args.insert("from", connection-points.from)
    }
    if connection-points.to != none {
      bond-args.insert("to", connection-points.to)
    }
  }
  
  // Return bond with all calculated parameters
  if bond-args.len() > 0 {
    bond(..bond-args)
  } else {
    bond()
  }
}

#let build-molecule-structure(graph, node-id, visited, angles, in-ring: false) = {
  if node-id in visited { return () }
  visited.push(node-id)
  
  let elements = ()
  let node = graph.nodes.at(node-id)
  
  if node.type == "fragment" {
    let atom-raw = node.data.atom
    let atom-content = process-atom(atom-raw)
    let count = if type(atom-content) == array { atom-content.len() } else { 1 }
    
    elements += (
      (
        type: "fragment",
        name: none,
        atoms: atom-content,
        colors: none,
        links: (:),
        lewis: (),
        vertical: false,
        count: count,
      ),
    )
  } else if node.type == "implicit" {
  } else if node.type == "ring" {
    let ring-size = node.data.size
    let ring-content = node.data.at("content", default: none)
    
    let ring-rotation = calculate-ring-rotation(node-id, graph, angles)
    
    let cycle-body = ()
    
    // If ring has content, expand it
    if ring-content != none and ring-content != (:) and ring-content.at("root", default: none) != none {
      let ring-angles = calculate-all-angles(ring-content, is-ring: true)
      let ring-visited = ()
      let ring-elements = build-molecule-structure(ring-content, ring-content.root, ring-visited, ring-angles, in-ring: true)
      
      // Move leading and trailing fragments
      let number = 0
      for i in range(ring-elements.len()) {
        let element = ring-elements.at(i)
        let type = element.at("type", default: none)

        if type == "fragment" and (number == 0 or number == ring-size) {
          elements += (element, )
        } else {
          if number == ring-size { panic("bonds is too many for ring size: " + str(ring-size)) }
          if type == "link" { number += 1 }
          if type == "branch" {
            let _ = element.at("body").at(0).remove("absolute")
          }
          cycle-body += (element,)
        }
      }
    } else {
      for i in range(ring-size) {
        cycle-body += single()
      }
    }
    
    visited.push(node-id)
    
    elements += create-cycle(ring-size, cycle-body, args: (relative: ring-rotation))
  }
  
  // Process all edges from current node
  for edge in graph.edges {
    if edge.from != node-id or edge.to in visited { continue }

    let role = edge.data.at("role", default: "main")
    let edge-key = str(edge.from) + "->" + str(edge.to)
    let angle = angles.at(edge-key, default: none)
    
    // Get lengths of connecting atoms
    let from-atom = if node.type == "fragment" { process-atom(node.data.atom) } else { "" }
    let to-node = graph.nodes.at(edge.to)
    let to-atom = if to-node.type == "fragment" { process-atom(to-node.data.atom) } else { "" }

    if role == "branch" {
      in-ring = false
    }
    
    let bond = get-bond-with-angle(
      edge.data.at("bondType", default: "single"),
      angle: angle,
      from-atom: from-atom,
      to-atom: to-atom,
      in-ring: in-ring
    )
    
    let next-elements = build-molecule-structure(graph, edge.to, visited, angles, in-ring: in-ring)

    // Different handling for main vs branch
    if role == "branch" {
      let branch-body = bond + next-elements
      elements += create-branch(branch-body)
    } else {
      // Main edge
      elements += bond
      elements += next-elements
    }
  }
  
  return elements
}

#let transform(graph) = {
  let root = graph.at("root", default: none)
  if root == none and graph.nodes.len() > 0 {
    for (id, _) in graph.nodes {
      if id == "node_0" {
        root = id
        break
      }
    }
    if root == none {
      root = graph.nodes.keys().first()
    }
  }
  
  if root == none {
    return ()
  }
  
  let angles = calculate-all-angles(graph)
  let elements = build-molecule-structure(graph, root, (), angles, in-ring: false)
  
  return elements
}

#let transform-molecule(graph) = {
  transform(graph)
}
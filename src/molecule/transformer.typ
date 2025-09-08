#import "../elements/links.typ": single, double, triple, cram-filled-right, cram-filled-left, cram-dashed-right, cram-dashed-left

#import "iupac-angle.typ": *

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
  
  // String processing
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

// Determine bond connection points based on angle
#let get-bond-connection-points(angle, from-atom-length, to-atom-length) = {
  if angle == none {
    return (from: none, to: none)
  }
  
  let from-len = if from-atom-length <= 0 { 1 } else { from-atom-length }
  let to-len = if to-atom-length <= 0 { 1 } else { to-atom-length }
  
  let normalized-angle = angle
  while normalized-angle > 180deg { normalized-angle -= 360deg }
  while normalized-angle < -180deg { normalized-angle += 360deg }
  
  // -90 < angle <= 90: left to right (from right edge, to left edge)
  // Otherwise: right to left (from left edge, to right edge)
  let from-point = none
  let to-point = none
  
  if normalized-angle > -90deg and normalized-angle <= 90deg {
    from-point = from-len - 1  // Right edge (0-indexed)
    to-point = 0  // Left edge
  } else {
    from-point = 0  // Left edge
    to-point = to-len - 1  // Right edge (0-indexed)
  }
  
  return (from: from-point, to: to-point)
}

#let get-bond-with-angle(bond-type, angle: none, from-atom-length: none, to-atom-length: none) = {
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
  
  // Calculate connection points (only when from/to are specified)
  if from-atom-length != none and to-atom-length != none {
    let connection-points = get-bond-connection-points(angle, from-atom-length, to-atom-length)
    // TODO: Add processing to use connection-points
  }
  
  // Set angle and connection points
  if angle != none {
    bond(relative: angle)
  } else {
    bond()
  }
}

#let build-molecule-structure(graph, node-id, visited, angles) = {
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
    let leading-fragment = none
    
    // If ring has content, expand it
    if ring-content != none and ring-content != (:) {
      // ring-content contains complete graph structure (nodes, edges, root, etc.)
      if ring-content.at("root", default: none) != none {
        // Follow links to find first and last of linear chain
        let chain-nodes = ()
        let current = ring-content.root
        let visited-chain = ()
        
        // Follow the chain
        while current != none and current not in visited-chain {
          visited-chain.push(current)
          let node-data = ring-content.nodes.at(current)
          chain-nodes.push((id: current, node: node-data))
          
          // Find next node
          let next = none
          for edge in ring-content.edges {
            if edge.from == current and edge.to not in visited-chain {
              next = edge.to
              break
            }
          }
          current = next
        }
        
        // Check if first and last nodes are fragments
        if chain-nodes.len() > 0 {
          let first-node = chain-nodes.at(0)
          let last-node = chain-nodes.at(-1)
          
          // If first or last is a fragment, extract it
          if first-node.node.type == "fragment" or (chain-nodes.len() > 1 and last-node.node.type == "fragment") {
            // Extract one as leading-fragment (prioritize first)
            let fragment-node = if first-node.node.type == "fragment" { first-node } else { last-node }
            let atom-raw = fragment-node.node.data.atom
            let atom-content = process-atom(atom-raw)
            let count = if type(atom-content) == array { atom-content.len() } else { 1 }
            
            leading-fragment = (
              type: "fragment",
              name: none,
              atoms: atom-content,
              colors: none,
              links: (:),
              lewis: (),
              vertical: false,
              count: count,
            )
            
            // Build cycle-body with non-fragment elements
            let ring-angles = calculate-all-angles(ring-content)
            let ring-visited = (fragment-node.id,)
            
            // Start from the node after the fragment
            let found-next = false
            for edge in ring-content.edges {
              if edge.from == fragment-node.id {
                // Add bond (don't use from/to within cycle)
                let bond = get-bond-with-angle(
                  edge.data.at("bondType", default: "single"),
                  angle: ring-angles.at(str(edge.from) + "->" + str(edge.to), default: none)
                )
                cycle-body += bond
                
                // Expand from next node
                let next-elements = build-molecule-structure(ring-content, edge.to, ring-visited, ring-angles)
                cycle-body += next-elements
                found-next = true
                break
              }
            }
            
            // If fragment is at the end, no edges exist, so add default bonds
            if not found-next and cycle-body == () {
              // Add single bonds for ring size
              for i in range(ring-size) {
                cycle-body += single()
              }
            }
          } else {
            // If no fragment, proceed normally
            let ring-angles = calculate-all-angles(ring-content)
            let ring-visited = ()
            let ring-elements = build-molecule-structure(ring-content, ring-content.root, ring-visited, ring-angles)
            cycle-body = ring-elements
          }
        } else {
          // If no chain, use default
          for i in range(ring-size) {
            cycle-body += single()
          }
        }
      } else if ring-content.at("nodes", default: (:)).len() == 0 {
        // If no nodes, default to single bonds only
        for i in range(ring-size) {
          cycle-body += single()
        }
      }
    } else {
      // If no content, default to single bonds only
      for i in range(ring-size) {
        cycle-body += single()
      }
    }
    
    // Mark this ring node itself as visited
    visited.push(node-id)
    
    // If leading-fragment exists, add it first
    if leading-fragment != none {
      elements += (leading-fragment,)
    }
    
    elements += create-cycle(ring-size, cycle-body, args: (relative: ring-rotation))
  }
  
  let main-edges = ()
  let branch-edges = ()
  
  for edge in graph.edges {
    if edge.from == node-id and edge.to not in visited {
      if edge.data.at("role", default: "main") == "main" {
        main-edges.push(edge)
      } else if edge.data.role == "branch" {
        branch-edges.push(edge)
      }
    }
  }
  
  for edge in branch-edges {
    // Get edge angle
    let edge-key = str(edge.from) + "->" + str(edge.to)
    let angle = angles.at(edge-key, default: none)
    
    // Get lengths of connecting atoms
    let from-atom = if node.type == "fragment" { node.data.atom } else { "" }
    let to-node = graph.nodes.at(edge.to)
    let to-atom = if to-node.type == "fragment" { to-node.data.atom } else { "" }
    
    let from-length = if from-atom == "" { 1 } else if type(from-atom) == str { from-atom.len() } else { 1 }
    let to-length = if to-atom == "" { 1 } else if type(to-atom) == str { to-atom.len() } else { 1 }
    
    let bond = get-bond-with-angle(
      edge.data.at("bondType", default: "single"), 
      angle: angle,
      from-atom-length: from-length,
      to-atom-length: to-length
    )
    let branch-elements = build-molecule-structure(graph, edge.to, visited, angles)
    
    let branch-body = bond + branch-elements
    elements += create-branch(branch-body, args: (relative: angle))
  }
  
  for edge in main-edges {
    let edge-key = str(edge.from) + "->" + str(edge.to)
    let angle = angles.at(edge-key, default: none)
    
    // Get lengths of connecting atoms
    let from-atom = if node.type == "fragment" { node.data.atom } else { "" }
    let to-node = graph.nodes.at(edge.to)
    let to-atom = if to-node.type == "fragment" { to-node.data.atom } else { "" }
    
    let from-length = if from-atom == "" { 1 } else if type(from-atom) == str { from-atom.len() } else { 1 }
    let to-length = if to-atom == "" { 1 } else if type(to-atom) == str { to-atom.len() } else { 1 }
    
    let bond = get-bond-with-angle(
      edge.data.at("bondType", default: "single"),
      angle: angle,
      from-atom-length: from-length,
      to-atom-length: to-length
    )
    elements += bond
    
    let next-elements = build-molecule-structure(graph, edge.to, visited, angles)
    elements += next-elements
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
  
  let visited = ()
  let elements = build-molecule-structure(graph, root, visited, angles)
  
  return elements
}

#let transform-molecule(graph) = {
  transform(graph)
}
// IUPAC-compliant molecular structure angle calculation module
// Assigns appropriate angles based on vertex bonding states according to IUPAC rules

#import "@preview/cetz:0.2.2"

// Basic angle definitions (relative angles)
#let ANGLE-STRAIGHT = 0deg              // Straight line
#let ANGLE-REVERSE = 180deg             // Reverse
#let ANGLE-UP = 60deg                   // Upward (for zigzag pattern)
#let ANGLE-DOWN = -60deg                // Downward (for zigzag pattern)
#let MAIN-CHAIN-INITIAL-ANGLE = 30deg   // Main chain initial angle
#let BRANCH-ANGLE-STEP = 60deg          // Angle step between branches
#let FULL-CIRCLE = 360deg               // Full circle angle

// Determine up/down for zigzag pattern
#let get-zigzag-angle(index) = {
  if calc.rem(index, 2) == 0 { ANGLE-UP } else { ANGLE-DOWN }
}

// Determine node hybridization state
#let determine-hybridization(node-id, graph) = {
  // Use cache to avoid duplicate calculations
  let node-edges = graph.edges.filter(e => e.from == node-id or e.to == node-id)
  
  let double-bond-count = 0
  for edge in node-edges {
    // Triple bond indicates sp hybridization
    if edge.data != none and edge.data.bondType == "triple" {
      return "sp"
    }
    // Count double bonds
    if edge.data != none and edge.data.bondType == "double" {
      double-bond-count += 1
    }
  }
  
  // Determine hybridization state
  return if double-bond-count == 2 { "sp" }
  else if double-bond-count == 1 { "sp2" }
  else { "sp3" }
}

// Calculate main chain angle (relative angle)
// Zigzag pattern: up→down→up...
#let calculate-main-chain-angle(edge-index, hybridization, is-first-edge, main-chain-length) = {
  // sp hybridization means straight line
  if hybridization == "sp" {
    return ANGLE-STRAIGHT
  }
  
  // Process first edge
  if is-first-edge {
    if main-chain-length >= 2 {
      return MAIN-CHAIN-INITIAL-ANGLE
    } else {
      return ANGLE-STRAIGHT
    }
  }
  
  // Zigzag pattern (based on edge index)
  return get-zigzag-angle(edge-index)
}

// Calculate branch angles (relative angles)
// Equally spaced in appropriate range based on situation
#let calculate-branch-angles(node-id, graph, edge-index, is-root-node, main-chain-length, branch-edges, has-incoming-main, has-outgoing-main, is-in-branch: false) = {
  let branch-angles = ()
  let total-branches = branch-edges.len() + if is-in-branch { 1 } else { 0 }
  
  if total-branches == 0 { return branch-angles }
  
  // Receive connection status from upstream
  let has-incoming = has-incoming-main
  let has-outgoing = has-outgoing-main
  
  // Determine split range and direction (simplified)
  let center-angle = if not has-outgoing {
    ANGLE-STRAIGHT
  } else if not has-incoming {
    ANGLE-REVERSE
  } else {
    // Reverse direction of zigzag pattern
    - get-zigzag-angle(edge-index)
  }
  
  // Case of single branch
  if total-branches == 1 {
    branch-angles.push(center-angle)
    return branch-angles
  }
  
  // Calculate angle step for multiple branches
  let step-angle = if has-incoming and has-outgoing {
    BRANCH-ANGLE-STEP / (total-branches - 1)
  } else {
    let n = total-branches + if has-incoming { 1 } + if has-outgoing { 1 }
    FULL-CIRCLE / n
  }
  
  // Place branch angles at equal intervals
  let start-angle = center-angle - step-angle * (total-branches - 1) / 2
  for i in range(total-branches) {
    branch-angles.push(start-angle + i * step-angle)
  }
  
  return branch-angles
}

// Calculate angles for all edges from node
#let calculate-edge-angles(node-id, graph, edge-index, is-root-node, main-chain-length, node-info: none, is-in-branch: false) = {
  // Get edges and hybridization from node info (calculate defaults if not present)
  let edges = node-info.at("edges", default: graph.edges.filter(e => e.from == node-id))
  
  if edges.len() == 0 {
    return (:)
  }
  
  let hybridization = node-info.at("hybridization", default: determine-hybridization(node-id, graph))
  
  // Classify edges by role (efficiently process in single loop)
  let main-edges = ()
  let branch-edges = ()
  
  // Classify edges and check connection status simultaneously
  let has-incoming-main = false
  let has-outgoing-main = false
  
  for edge in edges {
    let role = edge.data.at("role", default: "main")
    if role == "branch" {
      branch-edges.push(edge)
    } else {
      main-edges.push(edge)
      has-outgoing-main = true
    }
  }
  
  // Check incoming edges (only needed when has-outgoing is true)
  if branch-edges.len() > 0 {
    for edge in graph.edges {
      if edge.to == node-id and edge.data.at("role", default: "main") == "main" {
        has-incoming-main = true
        break
      }
    }
  }
  
  // Dictionary to store angles
  let angles = (:)
  for (index, edge) in main-edges.enumerate() {
    let is-first-edge = is-root-node and index == 0
    let angle = calculate-main-chain-angle(edge-index + index, hybridization, is-first-edge, main-chain-length)
    let key = str(edge.from) + "->" + str(edge.to)
    angles.insert(key, angle)
  }
  
  // Calculate branch edge angles
  if branch-edges.len() > 0 {
    let branch-angles-list = calculate-branch-angles(
      node-id, graph, edge-index, is-root-node, main-chain-length, 
      branch-edges, has-incoming-main, has-outgoing-main, is-in-branch: is-in-branch
    )
    for (index, edge) in branch-edges.enumerate() {
      let angle = branch-angles-list.at(index)
      let key = str(edge.from) + "->" + str(edge.to)
      angles.insert(key, angle)
    }
  }
  
  return angles
}

// Calculate main chain length
#let count-main-chain-edges(graph, start-node) = {
  let visited = ()
  let count = 0
  let current-node = start-node
  
  while current-node != none {
    if current-node in visited { break }
    visited.push(current-node)
    
    let main-edges = graph.edges.filter(e => 
      e.from == current-node and 
      e.data.at("role", default: "main") == "main"
    )
    
    if main-edges.len() > 0 {
      count += 1
      current-node = main-edges.at(0).to
    } else {
      break
    }
  }
  
  return count
}

// Traverse graph and calculate angles
#let traverse-and-calculate(graph, node-id, visited, edge-index, angles, is-root, node-cache: none, is-in-branch: false) = {
  if node-id in visited { return (angles, edge-index) }
  visited.push(node-id)
  
  let main-chain-length = if is-root {
    count-main-chain-edges(graph, node-id)
  } else {
    0
  }
  
  // Get information from cache (empty dictionary if not present)
  let node-info = if node-cache != none { node-cache.at(node-id, default: (:)) } else { (:) }
  
  let node-angles = calculate-edge-angles(
    node-id, graph, edge-index, is-root, main-chain-length,
    node-info: node-info, is-in-branch: is-in-branch
  )
  
  // Merge angles (more efficient merging)
  angles = angles + node-angles
  
  // Get edges (from node-info, or filter if not present)
  let edges = node-info.at("edges", default: graph.edges.filter(e => e.from == node-id))
  
  let next-edge-index = edge-index
  
  for edge in edges {
    if edge.to not in visited {
      let role = edge.data.at("role", default: "main")
      if role == "main" {
        // For main chain, advance the index
        next-edge-index = next-edge-index + 1
        let (new-angles, new-index) = traverse-and-calculate(graph, edge.to, visited, next-edge-index, angles, false, node-cache: node-cache, is-in-branch: is-in-branch)
        angles = new-angles
        next-edge-index = new-index
      } else if role == "branch" {
        let (new-angles, _) = traverse-and-calculate(graph, edge.to, visited, 0, angles, false, node-cache: node-cache, is-in-branch: true)
        angles = new-angles
      }
    }
  }
  
  return (angles, next-edge-index)
}

// Convert relative angles to absolute angles
#let relative-to-absolute(angles, graph) = {
  let absolute-angles = (:)
  let node-absolute-angles = (:)  // Track cumulative angle for each node
  
  // Start from root with 0deg absolute angle
  let root = graph.at("root", default: none)
  if root == none and graph.nodes.len() > 0 {
    root = if "node_0" in graph.nodes { "node_0" } else { graph.nodes.keys().first() }
  }
  
  if root != none {
    node-absolute-angles.insert(root, 0deg)
  }
  
  // Convert each relative angle to absolute
  for (edge-key, relative-angle) in angles {
    // Parse edge key to get from and to nodes
    let parts = edge-key.split("->")
    if parts.len() == 2 {
      let from-node = parts.at(0)
      let to-node = parts.at(1)
      
      // Get the absolute angle of the from node (default to 0deg)
      let from-absolute = node-absolute-angles.at(from-node, default: 0deg)
      
      // Calculate absolute angle by adding relative to from node's absolute
      let absolute-angle = from-absolute + relative-angle
      
      // Store for this edge
      absolute-angles.insert(edge-key, absolute-angle)
      
      // Update the to-node's absolute angle for next calculations
      node-absolute-angles.insert(to-node, absolute-angle)
    }
  }
  
  return absolute-angles
}

// ===== Main Functions =====

// Calculate relative angles for entire graph
#let calculate-all-relative-angles(graph, is-ring: false) = {
  // Efficient search for root node
  let root = graph.at("root", default: none)
  if root == none and graph.nodes.len() > 0 {
    // Prioritize searching for node_0
    root = if "node_0" in graph.nodes { "node_0" } else { graph.nodes.keys().first() }
  }
  
  if root == none { return (:) }
  
  // Pre-build node info cache (performance optimization for large graphs)
  let node-cache = (:)
  if graph.edges.len() > 50 {  // Use cache only for large graphs
    for edge in graph.edges {
      let from-node = edge.from
      if from-node not in node-cache {
        node-cache.insert(from-node, (edges: (), hybridization: none))
      }
      node-cache.at(from-node).edges.push(edge)
    }
    // Pre-calculate hybridization state for each node
    for (node-id, _) in graph.nodes {
      // Create entries for all nodes when building node-cache
      if node-id not in node-cache {
        node-cache.insert(node-id, (edges: (), hybridization: none))
      }
      node-cache.at(node-id).hybridization = determine-hybridization(node-id, graph)
    }
  }
  
  let visited = ()
  let angles = (:)
  let (final-angles, _) = traverse-and-calculate(
    graph, root, visited, 0, angles, true, 
    node-cache: if node-cache.len() > 0 { node-cache } else { none },
    is-in-branch: false
  )
  
  return final-angles
}

// Calculate absolute angles for entire graph
#let calculate-all-angles(graph, is-ring: false) = {
  let relative-angles = calculate-all-relative-angles(graph, is-ring: is-ring)
  
  return relative-to-absolute(relative-angles, graph)
}

// Calculate ring rotation angle (using relative angles only)
#let calculate-ring-rotation(node-id, graph, angles) = {
  let outgoing-edges = graph.edges.filter(e => 
    e.from == node-id and e.data.at("role", default: "main") == "main"
  )
  let incoming-edges = graph.edges.filter(e => 
    e.to == node-id and e.data.at("role", default: "main") == "main"
  )
  
  let node = graph.nodes.at(node-id)
  let ring-size = node.data.size
  let has-incoming = incoming-edges.len() > 0
  let has-outgoing = outgoing-edges.len() > 0
  let base-adjustment = 180deg / ring-size - 90deg
  
  if has-incoming and not has-outgoing {
    return ANGLE-STRAIGHT + base-adjustment
  }
  
  let outgoing-angle = 0deg
  for edge in outgoing-edges {
    if edge.from == node-id {
      let edge-key = str(edge.from) + "->" + str(edge.to)
      outgoing-angle = angles.at(edge-key, default: 0deg)
      break
    }
  }

  if not has-incoming and has-outgoing {
    return ANGLE-REVERSE + outgoing-angle + base-adjustment
  }
  
  if has-incoming and has-outgoing {
    // Determine ring orientation (reverse of zigzag pattern)
    let inverse-angle = if outgoing-angle == ANGLE-UP { ANGLE-DOWN } else { ANGLE-UP }
    return inverse-angle + base-adjustment
  }
  
  return base-adjustment
}

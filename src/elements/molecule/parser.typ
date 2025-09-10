/* 
  // reaction syntax
  input         ::= reaction
  reaction      ::= term (OPERATOR term)*
  term          ::= COEFFICIENT? molecule
  COEFFICIENT   ::= DIGIT+

  // operator expression
  OPERATOR      ::= CONDITION? OP_SYMBOL CONDITION?
  CONDITION     ::= "[" TEXT "]"
  OP_SYMBOL     ::= "->" | "<=>" | "⇌" | "→" | "⇄" | "=>" | "-->" | "+" | MATH_TEXT

  // molecule syntax
  molecule      ::= unit (bond unit)*
  unit          ::= (node | implicit_node) branch*
  node          ::= fragment | ring
  implicit_node ::= ε

  fragment      ::= FRAGMENT label? options?
  bond          ::= BOND_SYMBOL bond_label? options?
  branch        ::= "(" bond molecule ")"
  ring          ::= "@" DIGIT+ "(" molecule? ")" label? options?

  label         ::= ":" IDENTIFIER
  bond_label    ::= "::" IDENTIFIER
  options       ::= "(" key_value_pair ("," key_value_pair)* ")"
  key_value_pair::= IDENTIFIER ":" value

  // FRAGMENT definition
  FRAGMENT      ::= MOLECULE | ABBREVIATION | MATH_TEXT
  MOLECULE      ::= MOLECULE_PART+ CHARGE?
  MOLECULE_PART ::= ELEMENT_GROUP | PARENTHETICAL | COMPLEX
  ELEMENT_GROUP ::= ISOTOPE? ELEMENT SUBSCRIPT?
  ISOTOPE       ::= "^" DIGIT+
  ELEMENT       ::= [A-Z][a-z]?
  SUBSCRIPT     ::= DIGIT+
  PARENTHETICAL ::= "(" MOLECULE ")" SUBSCRIPT?
  COMPLEX       ::= "[" MOLECULE "]"
  CHARGE        ::= "^" DIGIT? ("+" | "-")
  ABBREVIATION  ::= [a-z][A-Za-z]+

  // bond syntax
  BOND_SYMBOL   ::= "-" | "=" | "#" | ">" | "<" | ":>" | "<:" | "|>" | "<|"

  // remote connection syntax
  remote_connection ::= ":" IDENTIFIER "=" ":" IDENTIFIER options?

  // Basic tokens
  TEXT          ::= [^[\]]+ | [^\s\(\)\[\]:,=\-<>#]+
  IDENTIFIER    ::= [a-zA-Z_][a-zA-Z0-9_]*
  DIGIT         ::= [0-9]
*/

#let create-parser-context(input, config: (:)) = {
  let mainInput = input
  let remoteConnections = ()
  
  if type(input) == content {
    let lines = input.text.split("\n").filter(line => line.trim() != "")
    if lines.len() > 0 {
      mainInput = lines.at(0)
      remoteConnections = lines.slice(1)
    }
  } else if type(input) == str {
    mainInput = input
  } else {
    mainInput = str(input)
  }
  
  (
    input: mainInput,
    position: 0,
    length: mainInput.len(),
    graph: (
      nodes: (:),
      edges: (),
      nodeCounter: 0,
      edgeCounter: 0,
      root: none,
      labels: (:),
      bondLabels: (:),
    ),
    lastNodeId: none,
    config: config,
    remoteConnections: remoteConnections,
  )
}

// Create sub-context (for parsing ring content)
#let create-sub-context(parent-ctx) = {
  (
    input: parent-ctx.input,
    position: parent-ctx.position,
    length: parent-ctx.length,
    graph: (
      nodes: (:),
      edges: (),
      nodeCounter: 0,
      edgeCounter: 0,
      root: none,
      labels: (:),
      bondLabels: (:),
    ),
    lastNodeId: none,
    config: parent-ctx.config,
    remoteConnections: (),
  )
}

#let create-node(nodeType: "fragment", data: (:)) = {
  (
    id: none,
    type: nodeType,
    data: data,
  )
}

#let create-edge(fromId, toId, edgeType: "bond", data: (:)) = {
  (
    id: none,
    from: fromId,
    to: toId,
    type: edgeType,
    data: data,
  )
}

#let add-node-to-graph(ctx, node) = {
  let nodeId = "node_" + str(ctx.graph.nodeCounter)
  node.id = nodeId
  ctx.graph.nodeCounter += 1
  ctx.graph.nodes.insert(nodeId, node)
  
  if "label" in node.data and node.data.label != none {
    ctx.graph.labels.insert(node.data.label, nodeId)
  }
  
  if ctx.graph.root == none {
    ctx.graph.root = nodeId
  }
  
  return (nodeId, ctx)
}

#let add-edge-to-graph(ctx, edge) = {
  let edgeId = "edge_" + str(ctx.graph.edgeCounter)
  edge.id = edgeId
  ctx.graph.edgeCounter += 1
  ctx.graph.edges.push(edge)
  
  if "label" in edge.data and edge.data.label != none {
    ctx.graph.bondLabels.insert(edge.data.label, edgeId)
  }
  
  return ctx
}

#let peek-char(ctx) = {
  if ctx.position >= ctx.length { return none }
  ctx.input.at(ctx.position)
}

#let peek-string(ctx, length) = {
  let end = calc.min(ctx.position + length, ctx.length)
  ctx.input.slice(ctx.position, end)
}

#let advance(ctx, count: 1) = {
  ctx.position += count
  ctx
}

#let skip-whitespace(ctx) = {
  while ctx.position < ctx.length {
    let char = peek-char(ctx)
    if char != " " and char != "\t" { break }
    ctx = advance(ctx)
  }
  ctx
}

#let ATOM_STRING_PATTERN = regex("^([A-Z][a-z]?(\d+)?)+(_[^\s\(\)\[\]:,=\-<>#]+|\^[^\s\(\)\[\]:,=\-<>#]+)*")
#let IDENTIFIER_PATTERN = regex("^[a-zA-Z_][a-zA-Z0-9_]*")
#let DIGIT_PATTERN = regex("^\d+")

#let parse-identifier(ctx) = {
  let remaining = ctx.input.slice(ctx.position)
  let match = remaining.match(IDENTIFIER_PATTERN)
  
  if match != none and match.start == 0 {
    ctx.position += match.text.len()
    return (match.text, ctx)
  }
  
  return (none, ctx)
}

#let parse-digits(ctx) = {
  let remaining = ctx.input.slice(ctx.position)
  let match = remaining.match(DIGIT_PATTERN)
  
  if match != none and match.start == 0 {
    ctx.position += match.text.len()
    return (match.text, ctx)
  }
  
  return (none, ctx)
}

#let parse-value(ctx) = {
  ctx = skip-whitespace(ctx)
  
  if peek-char(ctx) == "\"" {
    ctx = advance(ctx)
    let start = ctx.position
    while ctx.position < ctx.length and peek-char(ctx) != "\"" {
      ctx = advance(ctx)
    }
    let value = ctx.input.slice(start, ctx.position)
    if peek-char(ctx) == "\"" {
      ctx = advance(ctx)
    }
    return (value, ctx)
  }
  
  let (ident, newCtx) = parse-identifier(ctx)
  if ident != none {
    return (ident, newCtx)
  }
  
  let start = ctx.position
  let parenDepth = 0
  while ctx.position < ctx.length {
    let char = peek-char(ctx)
    if parenDepth == 0 and (char == "," or char == ")") { break }
    if char == "(" { parenDepth += 1 }
    if char == ")" { parenDepth -= 1 }
    ctx = advance(ctx)
  }
  
  let value = ctx.input.slice(start, ctx.position).trim()
  return (value, ctx)
}

#let parse-options(ctx) = {
  if peek-char(ctx) != "(" { return (none, ctx) }
  ctx = advance(ctx)
  
  let options = (:)
  
  while ctx.position < ctx.length {
    ctx = skip-whitespace(ctx)
    
    if peek-char(ctx) == ")" {
      ctx = advance(ctx)
      break
    }
    
    let (key, newCtx) = parse-identifier(ctx)
    if key == none { break }
    ctx = newCtx
    
    ctx = skip-whitespace(ctx)
    if peek-char(ctx) != ":" { break }
    ctx = advance(ctx)
    
    let (value, newCtx2) = parse-value(ctx)
    ctx = newCtx2
    options.insert(key, value)
    
    ctx = skip-whitespace(ctx)
    if peek-char(ctx) == "," {
      ctx = advance(ctx)
    }
  }
  
  return (options, ctx)
}

#let parse-label(ctx) = {
  if peek-char(ctx) != ":" { return (none, ctx) }
  if peek-string(ctx, 2) == "::" { return (none, ctx) }
  
  ctx = advance(ctx)
  return parse-identifier(ctx)
}

#let parse-bond-label(ctx) = {
  if peek-string(ctx, 2) != "::" { return (none, ctx) }
  
  ctx = advance(ctx, count: 2)
  return parse-identifier(ctx)
}

#let parse-fragment(ctx) = {
  ctx = skip-whitespace(ctx)
  
  let remaining = ctx.input.slice(ctx.position)
  let atomMatch = remaining.match(ATOM_STRING_PATTERN)
  
  if atomMatch == none or atomMatch.start != 0 {
    return (none, ctx)
  }
  
  let atom = atomMatch.text
  ctx.position += atom.len()
  
  ctx = skip-whitespace(ctx)
  let (label, newCtx) = parse-label(ctx)
  if label != none {
    ctx = newCtx
  }
  
  ctx = skip-whitespace(ctx)
  let options = (:)
  
  let node = create-node(
    nodeType: "fragment",
    data: (atom: atom, label: label, options: options)
  )
  
  return (node, ctx)
}

// Parser functions that need mutual recursion
#let parse-ring(ctx, parse-mol-fn) = {
  ctx = skip-whitespace(ctx)
  
  if peek-char(ctx) != "@" { return (none, ctx) }
  ctx = advance(ctx)
  
  let (sizeStr, newCtx) = parse-digits(ctx)
  if sizeStr == none { return (none, ctx) }
  ctx = newCtx
  let size = int(sizeStr)
  
  // Optional content within parentheses
  let ringContent = none
  ctx = skip-whitespace(ctx)
  if peek-char(ctx) == "(" {
    ctx = advance(ctx)
    
    // Create sub-context for ring content
    let sub-ctx = create-sub-context(ctx)
    
    // Parse in sub-context (into independent graph)
    let (innerMol, newSubCtx) = parse-mol-fn(sub-ctx, parse-mol-fn: parse-mol-fn)
    if innerMol != none {
      // Save complete graph structure (not just metadata)
      ringContent = newSubCtx.graph
      // Update parent context position (up to closing parenthesis)
      ctx.position = newSubCtx.position
    }
    
    ctx = skip-whitespace(ctx)
    if peek-char(ctx) != ")" { return (none, ctx) }
    ctx = advance(ctx)  // Consume closing parenthesis
  }
  
  ctx = skip-whitespace(ctx)
  let (label, newCtx3) = parse-label(ctx)
  if label != none {
    ctx = newCtx3
  }
  
  ctx = skip-whitespace(ctx)
  let options = (:)
  if peek-char(ctx) == "(" {
    let (opts, newCtx4) = parse-options(ctx)
    if opts != none {
      options = opts
      ctx = newCtx4
    }
  }
  
  let node = create-node(
    nodeType: "ring",
    data: (size: size, content: ringContent, label: label, options: options)
  )
  
  return (node, ctx)
}

#let parse-bond(ctx) = {
  ctx = skip-whitespace(ctx)
  
  let bondType = none
  let twoChar = peek-string(ctx, 2)
  
  if twoChar == ":>" {
    bondType = "wedge-dashed-right"
    ctx = advance(ctx, count: 2)
  } else if twoChar == "<:" {
    bondType = "wedge-dashed-left"
    ctx = advance(ctx, count: 2)
  } else {
    let char = peek-char(ctx)
    if char == "-" {
      bondType = "single"
      ctx = advance(ctx)
    } else if char == "=" {
      bondType = "double"
      ctx = advance(ctx)
    } else if char == "#" {
      bondType = "triple"
      ctx = advance(ctx)
    } else if char == ">" {
      bondType = "wedge-filled-right"
      ctx = advance(ctx)
    } else if char == "<" {
      bondType = "wedge-filled-left"
      ctx = advance(ctx)
    }
  }
  
  if bondType == none { return (none, ctx) }
  
  ctx = skip-whitespace(ctx)
  let (bondLabel, newCtx) = parse-bond-label(ctx)
  if bondLabel != none {
    ctx = newCtx
  }
  
  ctx = skip-whitespace(ctx)
  let options = (:)
  if peek-char(ctx) == "(" {
    let saved = ctx.position
    ctx = advance(ctx)
    ctx = skip-whitespace(ctx)
    let char = peek-char(ctx)
    let twoChar2 = peek-string(ctx, 2)
    let isBond = char == "-" or char == "=" or char == "#" or char == ">" or char == "<" or twoChar2 == ":>" or twoChar2 == "<:"
    
    ctx.position = saved
    if not isBond {
      let (opts, newCtx2) = parse-options(ctx)
      if opts != none {
        options = opts
        ctx = newCtx2
      }
    }
  }
  
  return ((bondType: bondType, label: bondLabel, options: options), ctx)
}

#let parse-branch(ctx, parentId, parse-mol-fn) = {
  if peek-char(ctx) != "(" { return ((), ctx) }
  
  let saved = ctx.position
  ctx = advance(ctx)
  ctx = skip-whitespace(ctx)
  
  let (bond, newCtx) = parse-bond(ctx)
  if bond == none {
    ctx.position = saved
    return ((), ctx)
  }
  ctx = newCtx
  
  let savedLastNode = ctx.lastNodeId
  ctx.lastNodeId = none
  
  let (branchMol, newCtx2) = parse-mol-fn(ctx, parse-mol-fn: parse-mol-fn)
  ctx = newCtx2
  
  ctx.lastNodeId = savedLastNode
  
  ctx = skip-whitespace(ctx)
  if peek-char(ctx) != ")" {
    ctx.position = saved
    return ((), ctx)
  }
  ctx = advance(ctx)
  
  // If branch has no atoms (only bonds), create implicit node
  if (branchMol == none or branchMol.root == none) and bond != none and parentId != none {
    // Create implicit node
    let implicitNode = create-node(
      nodeType: "implicit",
      data: (atom: none, label: none, options: (:))
    )
    let (implicitId, ctx3) = add-node-to-graph(ctx, implicitNode)
    ctx = ctx3
    
    // Create edge from parent node to implicit node
    let edge = create-edge(
      parentId,
      implicitId,
      edgeType: "bond",
      data: (
        bondType: bond.bondType,
        label: bond.label,
        options: bond.options,
        role: "branch"
      )
    )
    ctx = add-edge-to-graph(ctx, edge)
  } else if branchMol != none and branchMol.root != none and parentId != none {
    // branchMol.root is the node ID
    let edge = create-edge(
      parentId,
      branchMol.root,
      edgeType: "bond",
      data: (
        bondType: bond.bondType,
        label: bond.label,
        options: bond.options,
        role: "branch"
      )
    )
    ctx = add-edge-to-graph(ctx, edge)
  }
  
  return ((bond: bond, molecule: branchMol), ctx)
}

#let parse-node(ctx, parse-mol-fn) = {
  ctx = skip-whitespace(ctx)
  
  let node = none
  let nodeId = none
  
  let (ringNode, newCtx) = parse-ring(ctx, parse-mol-fn)
  if ringNode != none {
    let (id, ctx2) = add-node-to-graph(newCtx, ringNode)
    nodeId = id
    ctx = ctx2
  } else {
    let (fragmentNode, newCtx2) = parse-fragment(ctx)
    if fragmentNode != none {
      let (id, ctx3) = add-node-to-graph(newCtx2, fragmentNode)
      nodeId = id
      ctx = ctx3
    }
  }
  
  if nodeId == none { return (none, ctx) }
  
  let branches = ()
  while true {
    let (branch, newCtx) = parse-branch(ctx, nodeId, parse-mol-fn)
    if branch == () { break }
    branches.push(branch)
    ctx = newCtx
  }
  
  return (nodeId, ctx)
}

#let parse-bond-node-pair(ctx, parse-mol-fn) = {
  ctx = skip-whitespace(ctx)
  
  let (bond, newCtx) = parse-bond(ctx)
  if bond == none { return (none, ctx) }
  ctx = newCtx
  
  let (nodeId, newCtx2) = parse-node(ctx, parse-mol-fn)
  ctx = newCtx2
  
  if nodeId == none {
    // Check if there's a branch instead of a node
    if peek-char(ctx) == "(" {
      // Create an implicit node to attach the branch to
      let implicitNode = create-node(
        nodeType: "implicit",
        data: (atom: none, label: none, options: (:))
      )
      let (id, ctx3) = add-node-to-graph(ctx, implicitNode)
      nodeId = id
      ctx = ctx3
      
      // Parse branches attached to this implicit node
      while peek-char(ctx) == "(" {
        let (branch, branchCtx) = parse-branch(ctx, nodeId, parse-mol-fn)
        if branch == () { break }
        ctx = branchCtx
      }
    } else {
      // Create a simple implicit node
      let implicitNode = create-node(
        nodeType: "implicit",
        data: (atom: none, label: none, options: (:))
      )
      let (id, ctx3) = add-node-to-graph(ctx, implicitNode)
      nodeId = id
      ctx = ctx3
    }
  }
  
  return ((bond: bond, nodeId: nodeId), ctx)
}

#let process-remote-connections(ctx) = {
  for connection in ctx.remoteConnections {
    let parts = connection.split("=")
    if parts.len() != 2 { continue }
    
    let fromPart = parts.at(0).trim()
    let toPart = parts.at(1).trim()
    
    if fromPart.starts-with(":") and toPart.starts-with(":") {
      let fromLabel = fromPart.slice(1)
      let toLabel = toPart.slice(1)
      
      let options = (:)
      let parenIdx = toLabel.position("(")
      if parenIdx != none {
        toLabel = toLabel.slice(0, parenIdx)
      }
      
      let fromId = ctx.graph.labels.at(fromLabel, default: none)
      let toId = ctx.graph.labels.at(toLabel, default: none)
      
      if fromId != none and toId != none {
        let edge = create-edge(
          fromId,
          toId,
          edgeType: "bond",
          data: (
            bondType: "double",
            role: "remote",
            options: options
          )
        )
        ctx = add-edge-to-graph(ctx, edge)
      }
    }
  }
  return ctx
}

// Unified parse-molecule function
#let parse-molecule(inputOrCtx, config: (:), parse-mol-fn: none) = {
  // Set parse-mol-fn to self if not provided
  if parse-mol-fn == none {
    parse-mol-fn = parse-molecule
  }
  
  // Determine if this is an initial call (with string input) or recursive call (with context)
  let ctx = if type(inputOrCtx) == str {
    // Initial call with string input
    create-parser-context(inputOrCtx, config: config)
  } else {
    // Recursive call with context
    inputOrCtx
  }
  
  let initialNodeCount = ctx.graph.nodeCounter
  let initialEdgeCount = ctx.graph.edgeCounter
  let localRoot = none
  
  let (firstNodeId, newCtx) = parse-node(ctx, parse-mol-fn)
  if firstNodeId != none {
    ctx = newCtx
    ctx.lastNodeId = firstNodeId
    localRoot = firstNodeId
    if ctx.graph.root == none {
      ctx.graph.root = firstNodeId
    }
  } else {
    // Check if input starts with branch (
    if peek-char(ctx) == "(" {
      // Create implicit node for branch-starting input
      let implicitNode = create-node(
        nodeType: "implicit",
        data: (atom: none, label: none, options: (:))
      )
      let (implicitId, ctx3) = add-node-to-graph(ctx, implicitNode)
      ctx = ctx3
      ctx.lastNodeId = implicitId
      localRoot = implicitId
      if ctx.graph.root == none {
        ctx.graph.root = implicitId
      }
      
      // Parse branches attached to this implicit node
      while peek-char(ctx) == "(" {
        let (branch, branchCtx) = parse-branch(ctx, implicitId, parse-mol-fn)
        if branch == () { break }
        ctx = branchCtx
      }
    } else {
      let savedPos = ctx.position
      let (testBond, testCtx) = parse-bond(ctx)
      ctx.position = savedPos
      
      if testBond != none {
        let implicitNode = create-node(
          nodeType: "implicit",
          data: (atom: none, label: none, options: (:))
        )
        let (implicitId, ctx3) = add-node-to-graph(ctx, implicitNode)
        ctx = ctx3
        ctx.lastNodeId = implicitId
        localRoot = implicitId
        if ctx.graph.root == none {
          ctx.graph.root = implicitId
        }
      }
    }
  }
  
  while ctx.position < ctx.length {
    ctx = skip-whitespace(ctx)
    
    if peek-char(ctx) == ")" { break }
    
    let (pair, newCtx2) = parse-bond-node-pair(ctx, parse-mol-fn)
    if pair == none { break }
    ctx = newCtx2
    
    if ctx.lastNodeId != none and pair.nodeId != none {
      let edge = create-edge(
        ctx.lastNodeId,
        pair.nodeId,
        edgeType: "bond",
        data: (
          bondType: pair.bond.bondType,
          label: pair.bond.label,
          options: pair.bond.options,
          role: "main"
        )
      )
      ctx = add-edge-to-graph(ctx, edge)
    }
    
    if localRoot == none {
      localRoot = pair.nodeId
    }
    
    ctx.lastNodeId = pair.nodeId
  }
  
  // Return different results based on whether this is initial or recursive call
  if type(inputOrCtx) == str {
    // Initial call - process remote connections and return the graph
    if ctx.remoteConnections.len() > 0 {
      ctx = process-remote-connections(ctx)
    }
    return ctx.graph
  } else {
    // Recursive call - return molecule info and context
    let molecule = (
      nodes: ctx.graph.nodes.pairs().filter(p => {
        let nodeNum = int(p.at(0).slice(5))
        nodeNum >= initialNodeCount
      }).len(),
      root: localRoot
    )
    return (molecule, ctx)
  }
}
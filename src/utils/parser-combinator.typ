// Parse state
#let state(input, pos: 0) = (
  input: input,
  pos: pos,
  len: input.len(),
  at: self => if self.pos < self.len { self.input.at(self.pos) } else { none },
  peek: (self, n: 1) => {
    if self.pos + n <= self.len {
      self.input.slice(self.pos, self.pos + n)
    } else {
      none
    }
  },
  advance: (self, n: 1) => state(self.input, pos: self.pos + n),
  remaining: self => self.input.slice(self.pos),
  is-eof: self => self.pos >= self.len,
)

// Result types
#let ok(value, state) = (ok: true, value: value, state: state)
#let err(msg, state) = (ok: false, error: msg, state: state)

// Parser type
#let parser(name, fn) = (name: name, run: fn)

// ==================== Basic Parsers ====================

// Match any character
#let any() = parser("any", s => {
  let c = (s.at)(s)
  if c != none {
    ok(c, (s.advance)(s))
  } else {
    err("end of input", s)
  }
})

// Match specific character
#let char(c) = parser("char(" + c + ")", s => {
  let ch = (s.at)(s)
  if ch == c {
    ok(c, (s.advance)(s))
  } else {
    err("expected " + c, s)
  }
})

// Match string
#let str(text) = parser("str(" + text + ")", s => {
  let peek = (s.peek)(s, n: text.len())
  if peek == text {
    ok(text, (s.advance)(s, n: text.len()))
  } else {
    err("expected " + text, s)
  }
})

// Match one of characters
#let one-of(chars) = parser("one-of", s => {
  let c = (s.at)(s)
  if c != none and chars.contains(c) {
    ok(c, (s.advance)(s))
  } else {
    err("expected one of " + chars, s)
  }
})

// Match none of characters
#let none-of(chars) = parser("none-of", s => {
  let c = (s.at)(s)
  if c != none and not chars.contains(c) {
    ok(c, (s.advance)(s))
  } else {
    err("unexpected " + repr(c), s)
  }
})

// Match with predicate
#let satisfy(pred, name: "satisfy") = parser(name, s => {
  let c = (s.at)(s)
  if c != none and pred(c) {
    ok(c, (s.advance)(s))
  } else {
    err(name + " failed", s)
  }
})

// Match end of input
#let eof() = parser("eof", s => {
  if (s.is-eof)(s) {
    ok(none, s)
  } else {
    err("expected end of input", s)
  }
})

// ==================== Combinators ====================

// Map result
#let map(p, f) = parser("map", s => {
  let r = (p.run)(s)
  if r.ok {
    ok(f(r.value), r.state)
  } else {
    r
  }
})

// Sequence parsers (variadic)
#let seq(..parsers) = {
  let ps = parsers.pos()
  if ps.len() == 0 { return parser("empty", s => ok((), s)) }
  if ps.len() == 1 { return ps.at(0) }
  
  parser("seq", s => {
    let results = ()
    let current = s
    
    for p in ps {
      let r = (p.run)(current)
      if not r.ok { return r }
      results.push(r.value)
      current = r.state
    }
    
    ok(results, current)
  })
}

// Choice (variadic)
#let choice(..parsers) = {
  let ps = parsers.pos()
  if ps.len() == 0 { panic("choice requires at least one parser") }
  if ps.len() == 1 { return ps.at(0) }
  
  parser("choice", s => {
    for p in ps {
      let r = (p.run)(s)
      if r.ok { return r }
    }
    err("no alternative matched", s)
  })
}

// Optional
#let optional(p) = parser("optional", s => {
  let r = (p.run)(s)
  if r.ok {
    ok(r.value, r.state)
  } else {
    ok(none, s)
  }
})

// Optional with default value
#let optional-default(p, default) = map(
  optional(p),
  v => if v != none { v } else { default }
)

// Zero or more
#let many(p) = parser("many", s => {
  let results = ()
  let current = s
  
  while true {
    let r = (p.run)(current)
    if not r.ok { break }
    results.push(r.value)
    current = r.state
  }
  
  ok(results, current)
})

// One or more
#let some(p) = parser("some", s => {
  let first = (p.run)(s)
  if not first.ok { return first }
  
  let rest = (many(p).run)(first.state)
  ok((first.value,) + rest.value, rest.state)
})

// Between delimiters
#let between(left, right, p) = parser("between", s => {
  let l = (left.run)(s)
  if not l.ok { return l }
  
  let m = (p.run)(l.state)
  if not m.ok { return m }
  
  let r = (right.run)(m.state)
  if not r.ok { return r }
  
  ok(m.value, r.state)
})

// Separated by
#let sep-by(p, separator) = parser("sep-by", s => {
  let first = (p.run)(s)
  if not first.ok { return ok((), s) }
  
  let results = (first.value,)
  let current = first.state
  
  while true {
    let sep = (separator.run)(current)
    if not sep.ok { break }
    
    let item = (p.run)(sep.state)
    if not item.ok { break }
    
    results.push(item.value)
    current = item.state
  }
  
  ok(results, current)
})

// Separated by (at least one)
#let sep-by1(p, separator) = parser("sep-by1", s => {
  let first = (p.run)(s)
  if not first.ok { return first }
  
  let rest = (sep-by(p, separator).run)(first.state)
  if rest.value.len() == 0 {
    ok((first.value,), first.state)
  } else {
    ok((first.value,) + rest.value, rest.state)
  }
})

// Count exact
#let count(n, p) = parser("count", s => {
  let results = ()
  let current = s
  
  for i in range(n) {
    let r = (p.run)(current)
    if not r.ok { return err("expected " + str(n) + " items, got " + str(i), current) }
    results.push(r.value)
    current = r.state
  }
  
  ok(results, current)
})

// Lookahead - check without consuming
#let lookahead(p) = parser("lookahead", s => {
  let r = (p.run)(s)
  if r.ok {
    ok(r.value, s)  // Don't advance
  } else {
    r
  }
})

// Negative lookahead
#let not-ahead(p) = parser("not", s => {
  let r = (p.run)(s)
  if r.ok {
    err("unexpected " + repr(r.value), s)
  } else {
    ok(none, s)
  }
})

// Attempt - backtrack on failure
#let attempt(p) = parser("attempt", s => {
  (p.run)(s)
})

// Label for better errors
#let label(p, lbl) = parser(lbl, s => {
  let r = (p.run)(s)
  if not r.ok {
    err(lbl + " failed: " + r.error, s)
  } else {
    r
  }
})

// Chain left - for left-associative operators
#let chainl(p, op, default: none) = parser("chainl", s => {
  let first = (p.run)(s)
  if not first.ok {
    if default != none {
      return ok(default, s)
    }
    return first
  }
  
  let acc = first.value
  let current = first.state
  
  while true {
    let o = (op.run)(current)
    if not o.ok { break }
    
    let next = (p.run)(o.state)
    if not next.ok { break }
    
    acc = (o.value)(acc, next.value)
    current = next.state
  }
  
  ok(acc, current)
})

// Lazy parser - defers evaluation until needed
#let lazy(thunk) = parser("lazy", s => {
  let p = thunk()
  (p.run)(s)
})


// Run parser
#let parse(p, input) = {
  let s = state(input)
  let r = (p.run)(s)
  (
    success: r.ok,
    value: if r.ok { r.value } else { none },
    error: if not r.ok { r.error } else { none },
    rest: (r.state.remaining)(r.state),
  )
}

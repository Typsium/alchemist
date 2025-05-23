#let split-equation(mol, equation: false) = {
  if equation {
    mol = mol.body
    if mol.has("children") {
      mol = mol.children
    } else {
      mol = (mol,)
    }
  }


  let result = ()
  let last-number = false
  for m in mol {
    let last-number-hold = last-number
    if m.has("text") {
      let text = m.text
      if str.match(text, regex("^[A-Z][a-z]*$")) != none {
        result.push(m)
      } else if str.match(text, regex("^[0-9]+$")) != none {
        if last-number {
          panic("Consecutive numbers in fragment fragment")
        }
        last-number = true
        result.push(m)
      } else {
        panic("Invalid fragment fragment content")
      }
    } else if m.func() == math.attach or m.func() == math.lr {
      result.push(m)
    } else if m == [ ] {
      continue
    } else {
      panic("Invalid fragment fragment content")
    }
    if last-number-hold {
      result.at(-2) = result.at(-2) + result.at(-1)
      let _ = result.pop()
      last-number = false
    }
  }
  result
}

#let fragment-cor-regex = "[0-9]*[A-Z][a-z]*'*"
#let exponent-regex = "((?:[0-9]+(?:\\+|\\-)?)|[A-Z]|\\+|\\-)"
#let exponent-base-regex = "(?:(\\^|_)" + exponent-regex + ")?(?:(\\^|_)" + exponent-regex + ")?"
#let fragment-regex = regex("^ *(" + fragment-cor-regex + ")" + exponent-base-regex)

#let split-string(mol) = {
  let aux(str) = {
    let match = str.match(fragment-regex)
    if match == none {
      panic(str + " is not a valid fragment")
    } else if match.captures.at(1) == match.captures.at(3) and match.captures.at(1) != none {
      panic("You cannot use an exponent and a subscript twice")
    }
    let eq = "\"" + match.captures.at(0) + "\""
    if match.captures.at(1) != none {
      eq += match.captures.at(1) + "(" + match.captures.at(2) + ")"
    }
		if match.captures.at(3) != none {
			eq += match.captures.at(3) + "(" + match.captures.at(4) + ")"
		}
    let eq = math.equation(eval(eq, mode: "math"))
    (eq, match.end)
  }

  while not mol.len() == 0 {
    let (eq, end) = aux(mol)
    mol = mol.slice(end)
    (eq,)
  }
}

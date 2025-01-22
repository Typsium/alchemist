#import "utils.typ" as utils
#import "@preview/cetz:0.3.1"

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
          panic("Consecutive numbers in molecule")
        }
        last-number = true
        result.push(m)
      } else {
        panic("Invalid molecule content")
      }
    } else if m.func() == math.attach or m.func() == math.lr {
      result.push(m)
    } else if m == [ ] {
      continue
    } else {
      panic("Invalid molecule content")
    }
    if last-number-hold {
      result.at(-2) = result.at(-2) + result.at(-1)
      let _ = result.pop()
      last-number = false
    }
  }
  result
}

#let split-string(mol) = {
  let aux(str) = {
    let match = str.match(regex("^ *([0-9]*[A-Z][a-z]*)(\\^[0-9]+|\\^[A-Z])?(_[0-9]+|_[A-Z])?"))
    if match == none {
      panic(str + " is not a valid atom")
    }
    let eq = "\"" + match.captures.at(0) + "\""
    if match.captures.len() >= 2 {
      eq += match.captures.at(1)
    }
		if match.captures.len() >= 3 {
			eq += match.captures.at(2)
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

#let anchor-north-east(cetz-ctx, (x, y, _), delta, molecule, id) = {
  let (cetz-ctx, (_, b, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: molecule, anchor: (id, "north")),
  )
  let (cetz-ctx, (a, _, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: molecule, anchor: (id, "east")),
  )

  let a = (a - x) + delta
  let b = (b - y) + delta
  (a, b)
}

#let anchor-north-west(cetz-ctx, (x, y, _), delta, molecule, id) = {
  let (cetz-ctx, (_, b, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: molecule, anchor: (id, "north")),
  )
  let (cetz-ctx, (a, _, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: molecule, anchor: (id, "west")),
  )
  let a = (x - a) + delta
  let b = (b - y) + delta
  (a, b)
}

#let anchor-south-west(cetz-ctx, (x, y, _), delta, molecule, id) = {
  let (cetz-ctx, (_, b, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: molecule, anchor: (id, "south")),
  )
  let (cetz-ctx, (a, _, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: molecule, anchor: (id, "west")),
  )
  let a = (x - a) + delta
  let b = (y - b) + delta
  (a, b)
}

#let anchor-south-east(cetz-ctx, (x, y, _), delta, molecule, id) = {
  let (cetz-ctx, (_, b, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: molecule, anchor: (id, "south")),
  )
  let (cetz-ctx, (a, _, _)) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: molecule, anchor: (id, "east")),
  )
  let a = (a - x) + delta
  let b = (y - b) + delta
  (a, b)
}

/// Calculate an anchor position around a molecule using an ellipse
/// at a given angle
///
/// - ctx (alchemist-ctx): the alchemist context
/// - cetz-ctx (cetz-ctx): the cetz context
/// - angle (float|int|angle): the angle of the anchor
/// - molecule (string): the molecule name
/// - id (string): the molecule subpart id
/// - margin (length|none): the margin around the molecule
/// -> anchor: the anchor position around the molecule
#let molecule-anchor(ctx, cetz-ctx, angle, molecule, id, margin: none) = {
  let molecule-margin = if margin == none {
		ctx.config.molecule-margin
	} else {
		margin
	}
	molecule-margin = utils.convert-length(cetz-ctx, molecule-margin)
  let (cetz-ctx, center) = cetz.coordinate.resolve(
    cetz-ctx,
    (name: molecule, anchor: (id, "mid")),
  )
  let (a, b) = if utils.angle-in-range(angle, 0deg, 90deg) {
    anchor-north-east(cetz-ctx, center, molecule-margin, molecule, id)
  } else if utils.angle-in-range(angle, 90deg, 180deg) {
    anchor-north-west(cetz-ctx, center, molecule-margin, molecule, id)
  } else if utils.angle-in-range(angle, 180deg, 270deg) {
    anchor-south-west(cetz-ctx, center, molecule-margin, molecule, id)
  } else {
    anchor-south-east(cetz-ctx, center, molecule-margin, molecule, id)
  }

  // https://www.petercollingridge.co.uk/tutorials/computational-geometry/finding-angle-around-ellipse/
  let angle = if utils.angle-in-range-inclusive(angle, 0deg, 90deg) or utils.angle-in-range-strict(
    angle,
    270deg,
    360deg,
  ) {
    calc.atan(calc.tan(angle) * a / b)
  } else {
    calc.atan(calc.tan(angle) * a / b) - 180deg
  }


  if a == 0 or b == 0 {
    panic("Ellipse " + ellipse + " has no width or height")
  }
  (center.at(0) + a * calc.cos(angle), center.at(1) + b * calc.sin(angle))
}

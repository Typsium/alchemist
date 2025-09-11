#import "parser.typ": alchemist-parser
#import "iupac-angle.typ": calculate_angles
#import "transformer.typ": transform

#let molecule(content, name: none, ..args) = {
  let parsed = alchemist-parser(content)
  if not parsed.success {
    panic([
      Failed to parse #content reaction: #parsed.error
      #repr(parsed)
    ])
  }

  let reaction = parsed.value
  reaction.terms.map(term => {
    if term.type == "term" {
      let molecule = term.molecule
      let molecule_with_angles = calculate_angles(molecule)
      transform(molecule_with_angles)
    } else if term.type == "operator" {
      let op = term.symbol
      ((
        type: "operator",
        symbol: eval("$" + op + "$"),
        margin: 0em,
      ),)
    } else {
      panic("Unknown term type: " + term.type)
    }
  }).join()
}

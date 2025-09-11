#import "parser.typ": alchemist-parser
#import "transformer.typ": transform

#let molecule(content, name: none, ..args) = {
  let parsed = alchemist-parser(content)
  if not parsed.success {
    // Display error inline
    return text(fill: red)[
      Failed to parse "#content": #parsed.error
    ]
  }

  let reaction = parsed.value
  transform(reaction)
}

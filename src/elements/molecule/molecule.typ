#import "parser.typ": alchemist-parser
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
  transform(reaction)
}

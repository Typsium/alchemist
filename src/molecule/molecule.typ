#import "parser.typ": parse-molecule
#import "transformer.typ": transform

#let molecule(content, name: none, ..args) = {
  let graph = parse-molecule(content)
  
  let elements = transform(graph)
  
  elements
}

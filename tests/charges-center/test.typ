/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize(debug: false, config: (debug: false, angle-increment: 30deg),{
  import cetz.draw: *
  fragment("R")
  single(angle: 1)
  branch({
    single(angle: 3)
    fragment("O^-", ignore-charge: true)
  })
  branch({
    single(angle: -2.5)
    fragment("H")
  })
  single(angle:-0.8)
  fragment("R^2")
})
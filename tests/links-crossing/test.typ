/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize(
  config: (angle-increment: 15deg),
  {
  branch({
    single(angle: 1)
    single(angle: -1)
    double(angle: -7, offset: "right")
    single(angle: 11)
    single(angle: 13)
    branch({
      single(angle: 11)
      branch({
        single(angle: 6, stroke: 0.3em, atom-sep: 2em)
        hook("1")
      })
      single(angle: -8)
      molecule("O")
      single(angle: 1)
      branch({
        single(angle: 6, stroke: 0.3em, atom-sep: 2em, links: ("1": single()))
        hook("2")
      })
      single(angle: -1)
      single(angle: 4)
      branch({
        single(angle: 6, stroke: (black + 0.3em), atom-sep: 2em, links: ("2": single()))
      })
    })
    single(angle: 5)
  })
})
#import "../../lib.typ": *

#skeletize(
  config: (angle-increment: 15deg),
  {
  branch({
    double(angle: 10)
    fragment("O")
  })
  branch({
    single(angle: -6)
    fragment("OH")
  })
  single(angle: 2)
  cycle(6, {
    double()
    branch({
      single(angle: -6)
      fragment("OH")
    })
    single()
    branch({
      single(angle: -2)
      fragment("NH", vertical: true)
      single(angle: 2)
      branch({
        double(angle: 6)
        fragment("O")
      })
      single(angle: -2)
      single(angle: 2)
      cram-dashed-right(angle: -2)
      branch({
        cram-filled-left(angle: 6)
      })
      single(angle: 1)
      branch({
        double(angle: 5)
        fragment("O")
      })
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
        fragment("O")
        single(angle: 1)
        branch({
          single(angle: -8)
        })
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
    double()
    branch({
      single(angle: 2)
      fragment("OH")
    })
    single()
    double()
    single()
  })
})
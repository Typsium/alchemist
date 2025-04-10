#import "../../lib.typ": *

#skeletize(
  config: (angle-increment: 30deg),
  {
    fragment("HO")
    single(angle: -1)
    single(angle: 1)
    branch({
      cram-filled-left(angle: 3)
      fragment("OH")
    })
    single(angle: -1)
    branch({
      cram-dashed-left(angle: -3)
      fragment("OH")
    })
    single(angle: 1)
    branch({
      cram-dashed-left(angle: 3)
      fragment("OH")
    })
    single(angle: -1)
    branch({
      cram-dashed-left(angle: -3)
      fragment("OH")
    })
    single(angle: 1)
    branch({
      double(angle: 3)
      fragment("O")
    })
    single(angle: -1)
    fragment("H")
  },
)

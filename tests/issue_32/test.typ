/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#figure(
  skeletize(config: (angle-increment: 30deg, debug: false), {
    import cetz.draw: *
    single(angle: 2)
    branch({
      single(angle: 4)
    })
    double(name: "double1")
    operator("+")
    fragment("H", name: "H1")
    single(name: "single1")
    fragment("X", name: "X1")
    operator(sym.arrow.r.long)
    single(angle: 2)
    fragment("C^+", name: "C1")
    branch({
      single(angle: 4)
    })
    single()
    operator("+")
    fragment("X^-", name: "X2")
    operator(sym.arrow.r.long)
    single(angle: 1)
    branch({
      single(angle: 3)
    })
    branch({
      single(angle: -2.5)
      fragment("Br")
    })
    single(angle: -0.8)
  })
)
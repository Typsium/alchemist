/// [ppi:100]
#import "@preview/cetz:0.3.4": *
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize(
  config: (
    angle-increment: 15deg
  ), {
    import cetz.draw: *
    fragment("C")
    branch({
      single(angle: 14)
      fragment("R")
    })
    branch({
      double(angle: 6)
      fragment("O", lewis: (
        lewis-double(),
        lewis-double(angle: 180deg),
      ))
    })
    single(angle: -2)
    fragment("O", lewis: (
      lewis-double(angle: -45deg),
      lewis-double(angle: -135deg),
    ), name: "to")
    single(angle: 2, name: "from")
    fragment("H", name: "H")
    hobby(
      stroke: (red),
      (to: "from", rel: (0, 3pt)),
      ("from.50%", 0.5, -50deg, "to.north"),
      "to.north",
      mark: (end: ">", fill: red)
    )
    single(stroke: (none), atom-sep: 4em)
    fragment("B", lewis: (
      lewis-double(angle: 180deg),
    ), name: "base")
    hobby(
      stroke: (red),
      (to: "base", rel: (-5pt, 0)),
      ("base.west", 0.5, -30deg, "H.east"),
      "H.east",
      mark: (end: ">", fill: red)
    )
    single(stroke: (none), atom-sep: 10em)
    fragment("C")
    branch({
      single(angle: 14)
      fragment("R")
    })
    branch({
      double(angle: 6, name: "double")
      fragment("O", lewis: (
        lewis-double(),
        lewis-double(angle: 180deg),
      ), name: "ketone")
    })
    branch({
      single(angle: -2)
      fragment("O", lewis: (
        lewis-double(angle: 0),
        lewis-double(angle: -90deg),
        lewis-double(angle: 90deg),
      ))
    })
    hobby(
      stroke: (red),
      (to: "double", rel: (0, 3pt)),
      (to: "ketone.east", rel: (0.4, 0)),
      ("ketone.east", 0.5, -40deg, "ketone.north"),
      "ketone.north",
      mark: (end: ">", fill: red)
    )
    single(stroke: (none), atom-sep: 10em)
    fragment("C")
    branch({
      single(angle: 14)
      fragment("R")
    })
    branch({
      single(angle: 6)
      fragment("O", lewis: (
        lewis-double(),
        lewis-double(angle: 180deg),
        lewis-double(angle: 90deg),
      ))
    })
    branch({
      single(angle: -2, name: "single")
      fragment("O", lewis: (
        lewis-double(angle: 0),
        lewis-double(angle: -90deg),
        lewis-double(angle: 90deg),
      ), name: "O2")
    })
    hobby(
      stroke: (red),
      (to: "O2.south", rel: (0, -5pt)),
      ("single.end", 0.7, 70deg, "single.start"),
      "single.50%",
      mark: (end: ">", fill: red)
    )
    single(stroke: (none), atom-sep: 10em)
    fragment("C")
    branch({
      single(angle: 14)
      fragment("R")
    })
    branch({
      single(angle: 6)
      fragment("O", lewis: (
        lewis-double(angle: 0),
        lewis-double(angle: -180deg),
        lewis-double(angle: 90deg),
      ))
    })
    branch({
      double(angle: -2)
      fragment("O", lewis: (
        lewis-double(angle: -135deg),
        lewis-double(angle: 45deg),
      ))
    })
    single(stroke: (none), atom-sep: 10em)
    fragment("BH")
    content((2.8, 0), {
      $+$
    })
    content((5, 0), {
      math.stretch(sym.harpoons.rtlb, size: 2em)
    })
    content((6, 0), {
      $stretch(\[, size: #800%)$
    })
    content((9.5, 0), {
      math.stretch(sym.arrow.r.l, size: 2em)
    })
    content((13.7, 0), {
      math.stretch(sym.arrow.r.l, size: 2em)
    })
    content((17.5, 0), {
      $stretch(\], size: #800%)$
    })
    content((18.4, 0), {
      $+$
    })
  }
)
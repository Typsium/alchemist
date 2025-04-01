/// [ppi:100]
#import "../../lib.typ" : *
#import "@preview/cetz:0.3.4"

#set page(width: auto, height: auto, margin: 0.5em)

#grid(
  columns: 3,
  column-gutter:1em,
  align: horizon + center,
  skeletize({
    import cetz.draw: *
    double(absolute: 45deg, name: "l1")
    single(absolute: -80deg, name: "l2")
    molecule("X", name: "X")
    hobby(
      "l1.50%",
      ("l1.start", 0.5, 90deg, "l1.end"),
      "l1.start",
      stroke: (paint: red, dash: "dashed"),
      mark: (end: ">"),
    )
    hobby(
      (to: "X.north", rel: (0, 1pt)),
      ("l2.end", 0.4, -90deg, "l2.start"),
      "l2.50%",
      mark: (end: ">"),
    )
  }),
  skeletize({
    import cetz.draw: *
    double(absolute: 30deg, name: "l1")
    single(absolute: 30deg, name: "l2")
    molecule("X", name: "X")
    hobby(
      "l1.50%",
      ("l1.start", 0.5, 90deg, "l1.end"),
      "l1.start",
      stroke: (paint: red, dash: "dashed"),
      mark: (end: ">"),
    )
    hobby(
      (to: "X.north", rel: (0, 1pt)),
      ("l2.end", 0.4, -90deg, "l2.start"),
      "l2.50%",
      mark: (end: ">"),
    )
  }),
  skeletize({
    import cetz.draw: *
    double(absolute: 90deg, name: "l1")
    single(absolute: 0deg, name: "l2")
    molecule("X", name: "X")
    hobby(
      "l1.50%",
      ("l1.start", 0.5, 90deg, "l1.end"),
      "l1.start",
      stroke: (paint: red, dash: "dashed"),
      mark: (end: ">"),
    )
    hobby(
      (to: "X.north", rel: (0, 1pt)),
      ("l2.end", 0.4, -90deg, "l2.start"),
      "l2.50%",
      mark: (end: ">"),
    )
  }),
)
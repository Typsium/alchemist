/// [ppi:100]
#import "@preview/touying:0.7.4": *
#import themes.simple: *
#show: simple-theme

#import "../../lib.typ" : *

#let alch-canvas = touying-reducer.with(reduce: skeletize, cover:hide)

== alchemist

#alch-canvas({
  import cetz.draw: *
  
  double(absolute: 30deg, name: "l1")
  (pause,)
  single(absolute: -30deg, name: "l2")
  (pause,)
  fragment("X", name: "X")
  (pause,)
  hobby(
    "l1.50%",
    ("l1.start", 0.5, 90deg, "l1.end"),
    "l1.start",
    stroke: (paint: red, dash: "dashed"),
    mark: (end: ">"),
  )
 // l2.start breaks it, comment out for it to work
  hobby(
    (to: "X.north", rel: (0, 1pt)),
    ("l2.end", 0.4, -90deg, "l2.start"),
    "l2.50%",
    mark: (end: ">"),
  )
})
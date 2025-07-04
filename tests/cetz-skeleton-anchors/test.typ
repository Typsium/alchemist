/// [ppi:100]
#import "../../lib.typ": *
#import "@preview/cetz:0.4.0": *

#set page(width: auto, height: auto, margin: 0.5em)

#let molecule-R1 = draw-skeleton(name: "mol1", mol-anchor: "east", {
  molecule(name: "A", "H_2N")
  single()
  molecule(name: "B", "CH")
  branch({
    single(angle: 6)
    molecule(
      "R_1",
    )
  })
  single()
  molecule(name: "cooh", "COOH")
})

#canvas({
  import draw: *
  molecule-R1
  hobby(
    (to: "mol1.cooh.0.south", rel: (0, 1pt)),
    ("mol1.cooh.0.south", 1, 30deg, "mol1.A.1.south"),
    (to: "mol1.A.1.south", rel: (0, 1pt)),
    mark: (end: ">", start: ">"),
    stroke: red,
  )
})

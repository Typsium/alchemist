#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
  fragment(name: "A", "A")
  single()
  fragment("B")
  branch({
    single(angle: 1)
    fragment(
      "W",
      links: (
        "A": double(stroke: red),
      ),
    )
    single()
    fragment(name: "X", "X")
  })
  branch({
    single(angle: -1)
    molecule("Y")
    single()
    molecule(
      name: "Z",
      "Z",
      links: (
        "X": single(stroke: black + 3pt),
      ),
    )
  })
  single()
  fragment(
    "C",
    links: (
      "X": cram-filled-left(fill: blue),
      "Z": single(),
    ),
  )
})
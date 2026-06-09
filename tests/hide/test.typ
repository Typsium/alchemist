/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)
#import "@preview/cetz:0.5.2": *

#skeletize({
  import cetz.draw: circle
  fragment("A", name: "A")
  single()
  fragment("B", name: "B")
  hide({
    single()
    fragment("C", name: "C")
    circle("A")
    circle("B")
    circle("C")
  }, bounds: true)
})

#skeletize({
  import cetz.draw: circle
  fragment("A", name: "A")
  single()
  fragment("B", name: "B")
  hide({
    single()
    fragment("C", name: "C")
    circle("A")
    circle("B")
    circle("C")
  }, bounds: false)
})

#skeletize({
  import cetz.draw: hobby
  
  double(absolute: 30deg, name: "l1")
  single(absolute: -30deg, name: "l2")
  fragment("X", name: "X")
  hide({
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
})

#skeletize({
  import cetz.draw: hobby
  
  double(absolute: 30deg, name: "l1")
  hide({
    single(absolute: -30deg, name: "l2")
    fragment("X", name: "X")
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
})

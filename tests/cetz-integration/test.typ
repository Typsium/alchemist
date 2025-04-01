/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
    import cetz.draw: *
    molecule("ABCD", name: "A")
    single()
    molecule("EFGH", name: "E")
    line(
      "A.0.south",
      (rel: (0, -0.5)),
      (to: "E.0.south", rel: (0, -0.5)),
      "E.0.south",
      stroke: red,
      mark: (end: ">"),
    )
    for i in range(0, 4) {
      content((-2 + i, 2), $#i$, name: "label-" + str(i))
      line(
        (name: "label-" + str(i), anchor: "south"),
        (name: "A", anchor: (str(i), "north")),
        mark: (end: "<>"),
      )
    }
  })
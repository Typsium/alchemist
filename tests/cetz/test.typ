#import "../../lib.typ": *
#import "@preview/cetz:0.3.4"

#skeletize({
  import cetz.draw: *
  molecule("ABCD", name: "A")
  single()
  molecule("EFGH", name: "B")
  line(
    "A.0.south",
    (rel: (0, -0.5)),
    (to: "B.0.south", rel: (0, -0.5)),
    "B.0.south",
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

#skeletize({
  import cetz.draw: *
  double(absolute: 30deg, name: "l1")
  single(absolute: -30deg, name: "l2")
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
})

#grid(
  columns: (1fr, 1fr, 1fr),
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

#skeletize({
  import cetz.draw: *
  molecule("A")
  cycle(
    5,
    name: "cycle",
    {
      single()
      molecule("B")
      single()
      molecule("C")
      single()
      molecule("D")
      single()
      molecule("E")
      single()
    },
  )
  content(
    (to: "cycle", rel: (angle: 30deg, radius: 2)),
    "Center",
    name: "label",
  )
  line(
    "cycle",
    (to: "label.west", rel: (-1pt, -.5em)),
    (to: "label.east", rel: (1pt, -.5em)),
    stroke: red,
  )
  circle(
    "cycle",
    radius: .1em,
    fill: red,
    stroke: red,
  )
})

#skeletize({
  import cetz.draw: *
  cycle(
    5,
    name: "c1",
    {
      single()
      single()
      single()
      branch({
        single()
        cycle(
          3,
          name: "c2",
          {
            single()
            single()
            single()
          },
        )
      })
      single()
      single()
    },
  )
  hobby(
    "c1",
    ("c1", 0.5, -60deg, "c2"),
    "c2",
    stroke: red,
    mark: (end: ">"),
  )
})


#cetz.canvas({
  import cetz.draw: *
  draw-skeleton(
    name: "mol1",
    {
      cycle(
        6,
        {
          single()
          double()
          single()
          double()
          single()
          double()
        },
      )
    },
  )
  line((to: "mol1.east", rel: (1em, 0)), (rel: (1, 0)), mark: (end: ">"))
  set-origin((rel: (1em, 0)))
  draw-skeleton(
    name: "mol2",
    mol-anchor: "west",
    {
      molecule("X")
      double(angle: 1)
      molecule("Y")
    },
  )
  line((to: "mol2.east", rel: (1em, 0)), (rel: (1, 0)), mark: (end: ">"))
  set-origin((rel: (1em, 0)))
  draw-skeleton(
    name: "mol3",
    {
      molecule("S")
      cram-filled-right()
      molecule("T")
    },
  )
})

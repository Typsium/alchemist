/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)
#grid(
    columns:5,
    align: center + horizon,
    // branches
    skeletize({
        cycle(5,{
            branch({
                single()
                molecule("A")
                double()
                molecule("B")
                single()
                molecule("C")
            })
            single()
            branch({
                single()
                molecule("D")
                single()
                molecule("E")
            })
            single()
            branch({
                double()
            })
            single()
            branch({
                single()
                molecule("F")
            })
            single()
            branch({
                single()
                molecule("G")
                double()
            })
            single()
            single()
            single()
            single()
        })
    }),
    //combining cycles
    skeletize({
        molecule("A")
        cycle(7,{
            single()
            molecule("B")
            cycle(5,{
                single()
                single()
                single()
                single()
            })
            double()
            single()
            double()
            cycle(4,{
                single()
                single()
                single()
            })
            single()
            double()
            single()
        })
    }),
    [
        // cycles with groups
        #skeletize({
            molecule("AB")
            cycle(5,{
                single()
                molecule("CDE")
                single()
                molecule("F")
                single()
                molecule("GH")
                single()
                molecule("I")
                single()
            })
        })
        //cycles with manually corrected groups
        #skeletize({
            molecule("AB")
            cycle(5,{
                single(from: 1, to: 0)
                molecule("CDE")
                single(from: 0)
                molecule("F")
                single(to: 0)
                molecule("GH")
                single(from: 0)
                molecule("I")
                single(to: 1)
            })
        })
    ],
    skeletize({
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
      }),
      skeletize({
      	import cetz.draw: *
      	cycle(5, name: "c1", {
      		single()
      		single()
      		single()
      		branch({
      			single()
      			cycle(3, name: "c2", {
      				single()
      				single()
      				single()
      			})
      		})
      		single()
      		single()
      	})
      	hobby(
      		"c1",
      		("c1", 0.5, -60deg, "c2"),
      		"c2",
      		stroke: red,
      		mark: (end: ">"),
      	)
      }),
)
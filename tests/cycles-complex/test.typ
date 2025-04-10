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
                fragment("A")
                double()
                fragment("B")
                single()
                fragment("C")
            })
            single()
            branch({
                single()
                fragment("D")
                single()
                fragment("E")
            })
            single()
            branch({
                double()
            })
            single()
            branch({
                single()
                fragment("F")
            })
            single()
            branch({
                single()
                fragment("G")
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
        fragment("A")
        cycle(7,{
            single()
            fragment("B")
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
            fragment("AB")
            cycle(5,{
                single()
                fragment("CDE")
                single()
                fragment("F")
                single()
                fragment("GH")
                single()
                fragment("I")
                single()
            })
        })
        //cycles with manually corrected groups
        #skeletize({
            fragment("AB")
            cycle(5,{
                single(from: 1, to: 0)
                fragment("CDE")
                single(from: 0)
                fragment("F")
                single(to: 0)
                fragment("GH")
                single(from: 0)
                fragment("I")
                single(to: 1)
            })
        })
    ],
    skeletize({
        import cetz.draw: *
        fragment("A")
        cycle(
          5,
          name: "cycle",
          {
            single()
            fragment("B")
            single()
            fragment("C")
            single()
            fragment("D")
            single()
            fragment("E")
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
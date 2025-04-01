/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)
#cetz.canvas({
  	import cetz.draw: *
  	draw-skeleton(name: "mol1", {
  		cycle(6, {
  			single()
  			double()
  			single()
  			double()
  			single()
  			double()
  		})
  	})
  	line((to: "mol1.east", rel: (1em, 0)), (rel: (1, 0)), mark: (end: ">"))
  	set-origin((rel: (1em, 0)))
  	draw-skeleton(name: "mol2", mol-anchor: "west", {
  			molecule("X")
  			double(angle: 1)
  			molecule("Y")
  		})
  	line((to: "mol2.east", rel: (1em, 0)), (rel: (1, 0)), mark: (end: ">"))
    set-origin((rel: (1em, 0)))
  	draw-skeleton(name: "mol3", {
  		molecule("S")
  		cram-filled-right()
  		molecule("T")
  	})
  })
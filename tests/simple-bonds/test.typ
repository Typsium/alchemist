#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
  import cetz.draw: *
  molecule("C", name: "C1")
  branch({
      single(angle:1)
      molecule("H")
  })
  branch({
      single(angle:2)
      molecule("H")
  })
  branch({
      single(angle:3)
      molecule("H")
  })
  single(absolute: -45deg)
  molecule("C", name: "C2")
  double(absolute: 0deg)
  molecule("C")
  double(offset: "right")
  molecule("C")
  
  branch({
    single(absolute:45deg)
    molecule("C", name: "C3")
    
    branch({
          single(angle:1, stroke: red + 5pt)
          molecule("H")
      })
      branch({
          single(angle:2)
          molecule("H")
      })
      branch({
          single(angle:3)
          molecule("H")
      })
  })  
})
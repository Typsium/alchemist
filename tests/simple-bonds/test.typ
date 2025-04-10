#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
  import cetz.draw: *
  fragment("C", name: "C1")
  branch({
      single(angle:1)
      fragment("H")
  })
  branch({
      single(angle:2)
      fragment("H")
  })
  branch({
      single(angle:3)
      fragment("H")
  })
  single(absolute: -45deg)
  fragment("C", name: "C2")
  double(absolute: 0deg)
  fragment("C")
  double(offset: "right")
  fragment("C")
  
  branch({
    single(absolute:45deg)
    fragment("C", name: "C3")
    
    branch({
          single(angle:1, stroke: red + 5pt)
          fragment("H")
      })
      branch({
          single(angle:2)
          fragment("H")
      })
      branch({
          single(angle:3)
          fragment("H")
      })
  })  
})
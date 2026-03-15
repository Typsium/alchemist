#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
  fragment("A", lewis: (
    lewis-single(),
  ))
})

#skeletize({
  fragment("B", lewis: (
    lewis-single(offset: "bottom"),
  ))
})

#skeletize({
  fragment("C", lewis: (
    lewis-single(offset: "center"),
  ))
})

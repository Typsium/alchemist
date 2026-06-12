/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize(config: (debug: false), {
  single(angle:1)
  fragment("", lewis: (
    lewis-double(angle: 90deg),
  ))
  single(angle: -1)
  fragment("", lewis: (
    lewis-double(angle: -90deg),
  ))
  single(angle:1)
  fragment("E")
})


#skeletize({
  single(angle:1)
  fragment("", lewis: (
    lewis-double(angle: 112deg),
  ), name: "A")
  single(angle: -1)
  fragment("", lewis: (
    lewis-double(angle: -90deg),
  ))
  single(angle:1, links: (
    "A": single()
  ))
})


#skeletize({
  single(angle:1)
  fragment("", lewis: (
    lewis-double(angle: 112deg),
  ), name: "A", links: (
    "B": single()
  ))
  single(angle: -1)
  fragment("", lewis: (
    lewis-double(angle: -90deg),
  ))
  single()
  fragment("B", name: "B")
})

#skeletize({
  single(angle:1)
  fragment("", lewis: (
    lewis-double(angle: 112deg),
  ), name: "A", links: (
    "B": single()
  ))
  branch({
    single()
    fragment("", name: "C")
  })
  single(angle: -1)
  fragment("", lewis: (
    lewis-double(angle: -90deg),
  ))
  single()
  fragment("B", name: "B", links: (
    "C": single()
  ))
})

#skeletize({
  single(angle:1)
  fragment("", lewis: (
    lewis-double(angle: 112deg),
  ), name: "A", links: (
    "B": single()
  ))
  branch({
    single()
    fragment("", name: "C")
  })
  single(angle: -1)
  fragment("", lewis: (
    lewis-double(angle: -90deg),
  ))
  single()
  fragment("", name: "B", links: (
    "C": single()
  ))
})

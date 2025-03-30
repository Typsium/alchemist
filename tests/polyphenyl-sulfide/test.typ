#import "../../lib.typ": *

#skeletize({
  single()
  parenthesis(
    br: $n$,
    right: "end",
    {
      molecule("S")
      single()
      cycle(
        6,
        align: true,
        arc: (:),
        {
          for i in range(3) {
            single()
          }
          branch(single(name: "end"))
          for i in range(3) {
            single()
          }
        },
      )
    },
  )
})
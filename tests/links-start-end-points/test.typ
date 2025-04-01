/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#grid(
  columns: (10em,)*4,
  align: center + horizon,
  row-gutter: 1em,
  ..for i in range(0, 8) {
    (
      skeletize({
        molecule("ABCD")
        single(angle: i)
        molecule("EFGH")
      }),
    )
  }
)
#grid(
  columns: (10em,)*4,
  align: center + horizon,
  row-gutter: 1em,
  ..for i in range(0, 4) {
    (
      skeletize({
        molecule("ABCD")
        single(from: i, to: 3 - i, absolute: 27.563deg*(5-i))
        molecule("EFGH")
      }),
    )
  }
)
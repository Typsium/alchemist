#import "../../lib.typ": *

#skeletize(
  config: (
    atom-sep: 2em,
  ),
  {
    parenthesis(
      l: "[",
      r: "]",
      tr: $2-$,
      xoffset: .05,
      {
        molecule(
          "O",
          lewis: (
            lewis-double(angle: 135),
            lewis-double(angle: -45),
            lewis-double(angle: -135),
          ),
        )

        single(relative: 30deg)
        molecule("C")
        branch(
          angle: 2,
          {
            double()
            molecule(
              "O",
              lewis: (
                lewis-double(angle: 45),
                lewis-double(angle: 135),
              ),
            )
          },
        )
        single(absolute: -30deg)
        molecule(
          "O",
          lewis: (
            lewis-double(angle: 45),
            lewis-double(angle: -45),
            lewis-double(angle: -135),
          ),
        )
      },
    )
  },
)
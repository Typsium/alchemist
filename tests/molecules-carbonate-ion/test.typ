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
        fragment(
          "O",
          lewis: (
            lewis-double(angle: 135),
            lewis-double(angle: -45),
            lewis-double(angle: -135),
          ),
        )

        single(relative: 30deg)
        fragment("C")
        branch(
          angle: 2,
          {
            double()
            fragment(
              "O",
              lewis: (
                lewis-double(angle: 45),
                lewis-double(angle: 135),
              ),
            )
          },
        )
        single(absolute: -30deg)
        fragment(
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
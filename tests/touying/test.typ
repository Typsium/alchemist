/// [ppi:50]
#import "../../lib.typ": *
#import "@preview/touying:0.6.3": *

#import themes.metropolis: *

#let skeletize = touying-reducer.with(reduce: skeletize, cover: hide)


#show: metropolis-theme.with(aspect-ratio: "16-9")

= Pause
==
#skeletize({
  fragment("A")
  (pause,)
  single()
  fragment("B")
})


#slide(repeat: 3, self => {
  skeletize({
    let self = utils.merge-dicts(self, config-methods(cover: utils.method-wrapper(hide)))
    let (uncover, only, alternatives) = utils.methods(self)
    fragment("D")
    single()
    (only(2, {
      fragment("E")
      single()
      fragment("F")
    }),)
    (only(3, {
      fragment("G")
    }),)
  })
})
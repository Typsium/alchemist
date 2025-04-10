#import "../../lib.typ": *

#skeletize({
	single()
	single(angle:1)
	single(angle:3)
	single()
	single(angle:7)
	single(angle:6)
})

#skeletize(config:(angle-increment:20deg),{
	single()
	single(angle:1)
	single(angle:3)
	single()
	single(angle:7)
	single(angle:6)
})

#skeletize({
	single()
	single(relative:20deg)
	single(relative:20deg)
	single(relative:20deg)
	single(relative:20deg)
})

#skeletize({
	single()
	single(absolute:-20deg)
	single(absolute:10deg)
	single(absolute:40deg)
	single(absolute:-90deg)
})

#skeletize({
  fragment("A")
  single(stroke: red + 5pt)
  fragment("B")
})

 #skeletize({
  fragment("A")
  double(
    stroke: orange + 2pt,
    gap: .8em
  )
  fragment("B")
})

#skeletize({
  fragment("A")
  double(offset: "right")
  fragment("B")
  double(offset: "left")
  fragment("C")
  double(offset: "center")
  fragment("D")
})

 #skeletize({
  fragment("A")
  triple(
    stroke: blue + .5pt,
    gap: .15em
  )
  fragment("B")
})

 #skeletize({
  fragment("A")
  cram-filled-right(
    stroke: red + 2pt,
    fill: green,
    base-length: 2em
  )
  fragment("B")
})

 #skeletize({
  fragment("A")
  cram-filled-left(
    stroke: red + 2pt,
    fill: green,
    base-length: 2em
  )
  fragment("B")
})

 #skeletize({
  fragment("A")
  cram-dashed-right(
    stroke: red + 2pt,
    base-length: 2em,
    tip-length: 1em,
    dash-gap: .5em
  )
  fragment("B")
})

#skeletize({
  fragment("A")
  cram-dashed-left(
    stroke: red + 2pt,
    base-length: 2em,
    dash-gap: .5em
  )
  fragment("B")
})

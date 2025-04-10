/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

// simple branch
#skeletize({
	fragment("A")
	single()
	fragment("B")
	branch({
		single(angle:1)
		fragment("W")
		single()
		fragment("X")
	})
	single()
	fragment("C")
})
// branch with same starting point
#skeletize({
	fragment("A")
	branch({
		single(angle:1)
		fragment("B")
		branch({
			single(angle:1)
			fragment("W")
			single()
			fragment("X")
		})
		single()
		fragment("C")
	})
	branch({
		single(angle:-2)
		fragment("Y")
		single(angle:-1)
		fragment("Z")
	})
	single()
	fragment("D")
})
#v(-5em)
//branch with specified link angles
#skeletize({
	fragment("A")
	single()
	fragment("B")
	branch(relative:60deg,{
		single()
		fragment("D")
		single()
		fragment("E")
  })
	branch(relative:-30deg,{
		single()
		fragment("F")
		single()
		fragment("G")
	})
	single()
	fragment("C")
})

	#skeletize({
  fragment(name: "A", "A")
  single()
  fragment("B")
  branch({
    single(angle: 1)
    fragment(
      "W",
      links: (
        "A": single(),
      ),
    )
    single()
    fragment(name: "X", "X")
  })
  branch({
    single(angle: -1)
    fragment("Y")
    single()
    fragment(
      name: "Z",
      "Z",
      links: (
        "X": single(),
      ),
    )
  })
  single()
  fragment(
    "C",
    links: (
      "X": single(),
      "Z": single(),
    ),
  )
})

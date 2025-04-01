/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

// simple branch
#skeletize({
	molecule("A")
	single()
	molecule("B")
	branch({
		single(angle:1)
		molecule("W")
		single()
		molecule("X")
	})
	single()
	molecule("C")
})
// branch with same starting point
#skeletize({
	molecule("A")
	branch({
		single(angle:1)
		molecule("B")
		branch({
			single(angle:1)
			molecule("W")
			single()
			molecule("X")
		})
		single()
		molecule("C")
	})
	branch({
		single(angle:-2)
		molecule("Y")
		single(angle:-1)
		molecule("Z")
	})
	single()
	molecule("D")
})
#v(-5em)
//branch with specified link angles
#skeletize({
	molecule("A")
	single()
	molecule("B")
	branch(relative:60deg,{
		single()
		molecule("D")
		single()
		molecule("E")
  })
	branch(relative:-30deg,{
		single()
		molecule("F")
		single()
		molecule("G")
	})
	single()
	molecule("C")
})

	#skeletize({
  molecule(name: "A", "A")
  single()
  molecule("B")
  branch({
    single(angle: 1)
    molecule(
      "W",
      links: (
        "A": single(),
      ),
    )
    single()
    molecule(name: "X", "X")
  })
  branch({
    single(angle: -1)
    molecule("Y")
    single()
    molecule(
      name: "Z",
      "Z",
      links: (
        "X": single(),
      ),
    )
  })
  single()
  molecule(
    "C",
    links: (
      "X": single(),
      "Z": single(),
    ),
  )
})

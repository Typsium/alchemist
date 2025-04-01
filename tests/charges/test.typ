/// [ppi:100]
#import "../../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
	molecule("A'")
})

#skeletize({
	molecule("A'B")
})

#skeletize({
	molecule("A'B'''")
})

#skeletize({
	molecule("A^+")
})

#skeletize({
	molecule("A^-B")
})

#skeletize({
	molecule("A^5+")
})

#skeletize({
	molecule("A^5-")
})

#skeletize({
	molecule("A^5+_1")
})

#skeletize({
	molecule("A^5+_1E''^5")
})

#skeletize({
	molecule("A_B")
})

#skeletize({
	molecule("A_10")
})
/// [ppi:100]
#import "../../lib.typ": *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
	fragment("A'")
})

#skeletize({
	fragment("A'B")
})

#skeletize({
	fragment("A'B'''")
})

#skeletize({
	fragment("A^+")
})

#skeletize({
	fragment("A^-B")
})

#skeletize({
	fragment("A^5+")
})

#skeletize({
	fragment("A^5-")
})

#skeletize({
	fragment("A^5+_1")
})

#skeletize({
	fragment("A^5+_1E''^5")
})

#skeletize({
	fragment("A_B")
})

#skeletize({
	fragment("A_10")
})
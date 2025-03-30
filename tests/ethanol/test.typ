#import "../../lib.typ": *

#skeletize({
	molecule("H")
	single()
	molecule("C")
	branch({
		single(angle:2)
		molecule("H")
	})
	branch({
		single(angle:-2)
		molecule("H")
	})
	single()
	molecule("C")
	branch({
		single(angle:-1)
		molecule("H")
	})
	branch({
		double(angle:1)
		molecule("O")
	})
})
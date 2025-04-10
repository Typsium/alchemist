#import "../../lib.typ": *

#skeletize({
	fragment("H")
	single()
	fragment("C")
	branch({
		single(angle:2)
		fragment("H")
	})
	branch({
		single(angle:-2)
		fragment("H")
	})
	single()
	fragment("C")
	branch({
		single(angle:-1)
		fragment("H")
	})
	branch({
		double(angle:1)
		fragment("O")
	})
})
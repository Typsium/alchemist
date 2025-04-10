/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize(
	config: (angle-increment: 30deg),
	{
	single(angle:1)
	single(angle:-1)
	branch({
		double(angle:-3)
		fragment("O")
	})
	single(angle:1)
	single(angle:-1)
	branch({
		single(angle:-3)
		fragment("NH_2")
	})
	single(angle:1)
	branch({
		double(angle:3)
		fragment("O")
	})
	single(angle:-1)
	fragment("OH")
})
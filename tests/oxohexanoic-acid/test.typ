#import "../../lib.typ": *

#skeletize(
	config: (angle-increment: 30deg),
	{
	single(angle:1)
	single(angle:-1)
	branch({
		double(angle:-3)
		molecule("O")
	})
	single(angle:1)
	single(angle:-1)
	branch({
		single(angle:-3)
		molecule("NH_2")
	})
	single(angle:1)
	branch({
		double(angle:3)
		molecule("O")
	})
	single(angle:-1)
	molecule("OH")
})
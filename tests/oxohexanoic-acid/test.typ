#import "../../lib.typ": *

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
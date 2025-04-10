#import "../../lib.typ": *

#let fish-left = {
	single()
	branch({
		single(angle:4)
		fragment("H")
	})
	branch({
		single(angle:0)
		fragment("OH")
	})
}
#let fish-right = {
	single()
	branch({
		single(angle:4)
		fragment("OH")
	})
	branch({
		single(angle:0)
		fragment("H")
	})
}
#skeletize(
	config: (base-angle: 90deg),
	{
	fragment("OH")
	single(angle:3)
	fish-right
	fish-right
	fish-left
	fish-right
	single()
	double(angle: 1)
	fragment("O")
})
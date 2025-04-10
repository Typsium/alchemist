#import "../../lib.typ": *

#skeletize({
	fragment("H")
	single()
	fragment("O", lewis: (
		lewis-line(angle: 90deg),
		lewis-line(angle: -90deg)
	))
	single()
	fragment("S")
	let do(sign) = {
		double()
		fragment("O", lewis: (
			lewis-line(angle: sign * 45deg),
			lewis-line(angle: sign * 135deg)
		))
	}
	branch(angle: 2, do(1))
	branch(angle: -2, do(-1))
	single()
	fragment("O", lewis: (
		lewis-line(angle: 90deg),
		lewis-line(angle: -90deg)
	))
	single()
	fragment("H")
})
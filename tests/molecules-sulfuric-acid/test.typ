/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
	molecule("H")
	single()
	molecule("O", lewis: (
		lewis-line(angle: 90deg),
		lewis-line(angle: -90deg)
	))
	single()
	molecule("S")
	let do(sign) = {
		double()
		molecule("O", lewis: (
			lewis-line(angle: sign * 45deg),
			lewis-line(angle: sign * 135deg)
		))
	}
	branch(angle: 2, do(1))
	branch(angle: -2, do(-1))
	single()
	molecule("O", lewis: (
		lewis-line(angle: 90deg),
		lewis-line(angle: -90deg)
	))
	single()
	molecule("H")
})
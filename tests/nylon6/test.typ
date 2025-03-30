#import "../../lib.typ": *

#skeletize({
	parenthesis(xoffset: (.4, -.15), {
		single()
		molecule("N")
		branch(angle: 2, {
			single()
			molecule("H")
		})
		single()
		molecule("C")
		branch(angle: 2, {
			double()
			molecule("O")
		})
		single()
		molecule($(C H_2)_5$)
		single()
	})
})
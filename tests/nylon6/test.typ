#import "../../lib.typ": *

#skeletize({
	parenthesis(xoffset: (.4, -.15), {
		single()
		fragment("N")
		branch(angle: 2, {
			single()
			fragment("H")
		})
		single()
		fragment("C")
		branch(angle: 2, {
			double()
			fragment("O")
		})
		single()
		fragment($(C H_2)_5$)
		single()
	})
})
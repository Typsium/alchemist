#import "../../lib.typ": *

#skeletize({
	cycle(6, {
		branch({
			single()
			fragment("HO")
		})
		single()
		double()
		cycle(6,{
			single(stroke:transparent)
			single(
				stroke:transparent,
				to: 1
			)
			fragment("HN")
			branch({
				single(angle:-1)
				fragment("CH_3")
			})
			single(from:1)
			single()
			branch({
				cram-filled-left(angle: 2)
				fragment("OH")
			})
			single()
		})
		single()
		double()
		single()
		branch({
			single()
			fragment("HO")
		})
		double()
	})
})

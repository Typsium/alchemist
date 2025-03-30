#import "../../lib.typ": *

#skeletize({
	cycle(6, {
		branch({
			single()
			molecule("H_2N")
		})
		double()
		molecule("N")
		single()
		cycle(6, {
			single()
			molecule("NH", vertical: true)
			single()
			double()
			molecule("N", links: (
				"N-horizon": single()
			))
		})
		single()
		hook("N-horizon")
		single()
		single()
		molecule("NH")
		single(from: 1)
	})
})
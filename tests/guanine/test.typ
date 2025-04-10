#import "../../lib.typ": *

#skeletize({
	cycle(6, {
		branch({
			single()
			fragment("H_2N")
		})
		double()
		fragment("N")
		single()
		cycle(6, {
			single()
			fragment("NH", vertical: true)
			single()
			double()
			fragment("N", links: (
				"N-horizon": single()
			))
		})
		single()
		hook("N-horizon")
		single()
		single()
		fragment("NH")
		single(from: 1)
	})
})
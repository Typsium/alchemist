/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
	cycle(6, {
		branch({
			single()
			molecule("HO")
		})
		single()
		double()
		cycle(6,{
			single(stroke:transparent)
			single(
				stroke:transparent,
				to: 1
			)
			molecule("HN")
			branch({
				single(angle:-1)
				molecule("CH_3")
			})
			single(from:1)
			single()
			branch({
				cram-filled-left(angle: 2)
				molecule("OH")
			})
			single()
		})
		single()
		double()
		single()
		branch({
			single()
			molecule("HO")
		})
		double()
	})
})

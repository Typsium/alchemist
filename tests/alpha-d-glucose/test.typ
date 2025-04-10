#import "../../lib.typ": *

#skeletize({
	hook("start")
	branch({
		single(absolute: 190deg)
		fragment("OH")
	})
	single(absolute: -50deg)
	branch({
		single(absolute: 170deg)
		fragment("OH")
	})
	single(absolute: 10deg)
	branch({
		single(
			absolute: -55deg,
			atom-sep: 0.7
		)
		fragment("OH")
	})
	single(absolute: -10deg)
	branch({
		single(angle: -2, atom-sep: 0.7)
		fragment("OH")
	})
	single(absolute: 130deg)
	fragment("O")
	single(absolute: 190deg, links: ("start": single()))
	branch({
		single(
			absolute: 150deg,
			atom-sep: 0.7
		)
		single(angle: 2, atom-sep: 0.7)
		fragment("OH")
	})
})

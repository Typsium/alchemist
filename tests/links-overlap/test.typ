/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize(config:(debug: false),{
	single(name:"C", links:(
		"1": single(over: "B", name: "D")
	))
	single(name: "A")
	single(angle: 1)
	hook("1")
	single(angle: 4)
	single(angle: 6, over: "A", name: "B")
})

#skeletize(config: (debug: false),{
	hook("1")
	single(name: "A")
	single(angle: 1, name: "B")
	single(angle: -1, name: "C")
	single(angle: 1, links: (
		"1": single(over: ((name: "B", radius: .2, length: .5), "C"))
	))
})

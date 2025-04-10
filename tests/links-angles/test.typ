/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
	single()
	single(angle:1)
	single(angle:3)
	single()
	single(angle:7)
	single(angle:6)
})
#skeletize(config:(angle-increment:20deg),{
	single()
	single(angle:1)
	single(angle:3)
	single()
	single(angle:7)
	single(angle:6)
})
#skeletize({
	single()
	single(relative:20deg)
	single(relative:20deg)
	single(relative:20deg)
	single(relative:20deg)
})
#skeletize({
	single()
	single(absolute:-20deg)
	single(absolute:10deg)
	single(absolute:40deg)
	single(absolute:-90deg)
})
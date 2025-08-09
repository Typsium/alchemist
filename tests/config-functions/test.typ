/// [ppi:100]
#import "../../lib.typ": *
#set page(width: auto, height: auto, margin: 0.5em)


#let molecule = {
	fragment("A")
	single(angle: 1)
	fragment("B")
	single(angle: -1)
	fragment("C")
}

#let custom-skeletize = skeletize-config((
	angle-increment: 30deg
))

#custom-skeletize(molecule, config:(atom-sep: 5em))
#skeletize(molecule)
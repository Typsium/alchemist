/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
    molecule("H")
    single()
    molecule("C")
    branch({
        single(angle:2)
        molecule("H")
    })
    branch({
        single(angle:-2)
        molecule("H")
    })
    single()
    molecule("C")
    branch({
        single(angle:-2)
        molecule("H")
    })
    branch({
        single(angle:2)
        molecule("H")
    })
    branch({
        single()
        molecule("O")
        single(angle: 1)
        molecule("H")
    })
})
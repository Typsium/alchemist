/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
    fragment("H")
    single()
    fragment("C")
    branch({
        single(angle:2)
        fragment("H")
    })
    branch({
        single(angle:-2)
        fragment("H")
    })
    single()
    fragment("C")
    branch({
        single(angle:-2)
        fragment("H")
    })
    branch({
        single(angle:2)
        fragment("H")
    })
    branch({
        single()
        fragment("O")
        single(angle: 1)
        fragment("H")
    })
})
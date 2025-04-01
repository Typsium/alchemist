
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
    molecule("A")
    cycle(5, {
        single()
        molecule("B")
        double()
        molecule("C")
        single()
        molecule("D")
        single()
        molecule("E")
        double()
    })
})
#v(-2em)
#skeletize({
    single()
    molecule("A")
    cycle(5, align: true, {
        single()
        molecule("B")
        double()
        molecule("C")
        single()
        molecule("D")
        single()
        molecule("E")
        double()
    })
})
#v(-2em)
#skeletize({
    cycle(4,{
        single()
        molecule("A")
        single()
        molecule("B")
        single()
        molecule("C")
        single()
        molecule("D")
    })
})

#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
    fragment("A")
    cycle(5, {
        single()
        fragment("B")
        double()
        fragment("C")
        single()
        fragment("D")
        single()
        fragment("E")
        double()
    })
})
#v(-2em)
#skeletize({
    single()
    fragment("A")
    cycle(5, align: true, {
        single()
        fragment("B")
        double()
        fragment("C")
        single()
        fragment("D")
        single()
        fragment("E")
        double()
    })
})
#v(-2em)
#skeletize({
    cycle(4,{
        single()
        fragment("A")
        single()
        fragment("B")
        single()
        fragment("C")
        single()
        fragment("D")
    })
})
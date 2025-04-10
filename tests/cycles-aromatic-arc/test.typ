/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)
#grid(
    columns:3,
    align: center + horizon,
    skeletize({
        cycle(6, arc:(:), {
            single()
            single()
            single()
            single()
            single()
            single()
        })
    }),
    skeletize({
        cycle(5, arc:(start: 30deg, end: 330deg), {
            single()
            single()
            single()
            single()
            single()
        })
    }),
    skeletize({
        cycle(4, arc:(start: 0deg, delta: 270deg, stroke: (paint: black, dash: "dashed")), {
            single()
            single()
            single()
            single()
        })
    }),
)
/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#grid(
    columns:3,
    [
        === Ethanol
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
    ],
    [
        === 2-Amino-4-oxohexanoic acid
        #skeletize(
            config: (angle-increment: 30deg),
            {
            single(angle:1)
            single(angle:-1)
            branch({
                double(angle:-3)
                molecule("O")
            })
            single(angle:1)
            single(angle:-1)
            branch({
                single(angle:-3)
                molecule("NH_2")
            })
            single(angle:1)
            branch({
                double(angle:3)
                molecule("O")
            })
            single(angle:-1)
            molecule("OH")
        })
    ],
    [
        === #smallcaps[d]-Glucose
        #skeletize(
            config: (angle-increment: 30deg),
            {
            molecule("HO")
            single(angle:-1)
            single(angle:1)
            branch({
                cram-filled-left(angle: 3)
                molecule("OH")
            })
            single(angle:-1)
            branch({
                cram-dashed-left(angle: -3)
                molecule("OH")
            })
            single(angle:1)
            branch({
                cram-dashed-left(angle: 3)
                molecule("OH")
            })
            single(angle:-1)
            branch({
                cram-dashed-left(angle: -3)
                molecule("OH")
            })
            single(angle:1)
            branch({
                double(angle: -1)
                molecule("O")
            })
          })
    ],
)

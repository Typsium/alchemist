/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#grid(
    columns:3,
    [
        === Ethanol
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
                fragment("O")
            })
            single(angle:1)
            single(angle:-1)
            branch({
                single(angle:-3)
                fragment("NH_2")
            })
            single(angle:1)
            branch({
                double(angle:3)
                fragment("O")
            })
            single(angle:-1)
            fragment("OH")
        })
    ],
    [
        === #smallcaps[d]-Glucose
        #skeletize(
            config: (angle-increment: 30deg),
            {
            fragment("HO")
            single(angle:-1)
            single(angle:1)
            branch({
                cram-filled-left(angle: 3)
                fragment("OH")
            })
            single(angle:-1)
            branch({
                cram-dashed-left(angle: -3)
                fragment("OH")
            })
            single(angle:1)
            branch({
                cram-dashed-left(angle: 3)
                fragment("OH")
            })
            single(angle:-1)
            branch({
                cram-dashed-left(angle: -3)
                fragment("OH")
            })
            single(angle:1)
            branch({
                double(angle: -1)
                fragment("O")
            })
          })
    ],
)

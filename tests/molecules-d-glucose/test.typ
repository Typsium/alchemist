/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

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

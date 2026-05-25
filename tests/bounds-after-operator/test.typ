/// [ppi:100]
#import "../../lib.typ" : *

#set page(width: auto, height: auto, margin: 0.5em)

#skeletize({
  import cetz.draw: *
  fragment("R")
  single()
  triple()
  single()
  fragment("H")
  operator("+")
  fragment("H_3C")
  single(angle: 1)
  single(angle:-1)
  fragment("MgBr")
  operator(sym.arrow.r.long)
  fragment("R")
  single()
  triple()
  single()
  fragment("MgBr")
  operator("+")
  fragment("C_2H_6")
})



#skeletize(debug: false, config: (debug: false), {
  import cetz.draw: *
  fragment("R")
  single()
  triple()
  single()
  fragment("H")
  
  operator("+")

  single(angle: 1)
  single(angle:-1)
  fragment("MgBr")
  
  operator(sym.arrow.r.long)
  
  fragment("R")
  single()
  triple()
  single()
  fragment("MgBr")
  
  operator("+")
  
  fragment("C_2H_6")
})
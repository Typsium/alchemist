#import "../../lib.typ": *
#import "../../src/elements/molecule/parser.typ": alchemist-parser
#import "../../src/elements/molecule/transformer.typ": transform
#import "../../src/elements/molecule/molecule.typ": molecule

// Error handling and edge cases test
= Molecule Edge Cases and Error Handling Tests

#let test-parse(input, description) = {
  let parsed = alchemist-parser(input)
  if not parsed.success {
    return [
      == #description
      #text(fill: red)[
        Failed to parse "#input": #parsed.error
      ]
    ]
  }

  let reaction = parsed.value
  let result = transform(reaction)

  [
    == #description
    ✓ Input: #input
    #skeletize(result)
    #linebreak()
    Parsed successfully with #parsed.value.terms.len() nodes
    // #repr(reaction)
    #linebreak()
    // #repr(result)
    // #linebreak()
  ]
}

= Parser edge cases
#test-parse("@6((-)-(-)-(-)-(-)-(-)-(-)-)", "ring")
#test-parse("@6((-(-)-)-(-(-)-)-(-(-)-)-(-(-)-)-(-(-)-)-(-(-)-)-)", "ring")
#test-parse("@6(-(-CH3)(-CH3)-----)", "ring")
#test-parse("@6(-(-CH3)-----)", "ring")
#test-parse("CH3-@6-CH3", "ring")
#test-parse("@6-CH3", "ring")
#test-parse("CH3-@6", "ring")
#test-parse("@6(-----@6(-----))", "fused ring (5+5)")
#test-parse("@6(------@6(-----))", "fused ring (6+5)")
#test-parse("@6(-----@6(------))", "fused ring (5+6)")
#test-parse("@6(------@6(------))", "hetero ring (6+6)")

  
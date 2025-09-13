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
      text(fill: red)[
        Failed to parse "#input": #parsed.error
      ]
    ]
  }

  let reaction = parsed.value
  let result = transform(reaction)

  [
    == #description
    ✓ Input: #input
    // #skeletize(result)
    #linebreak()
    Parsed successfully with #parsed.value.terms.len() nodes
    // #repr(parsed.value)
    #linebreak()
    #repr(result)
    // #linebreak()
  ]
}

= Parser edge cases
// Empty input
#test-parse("", "Empty input")

// Whitespace only
#test-parse("   ", "Whitespace only")

// Single atom
#test-parse("C", "Single atom")
#test-parse("H", "Single hydrogen")
#test-parse("Cl", "Single chlorine")

// Bond only (no atom)
#test-parse("-", "Bond only")
#test-parse("=", "Double bond only")
#test-parse("#", "Triple bond only")

// Incomplete bond
#test-parse("CH3-", "Trailing bond")
#test-parse("-CH3", "Leading bond")
#test-parse("CH3--CH3", "Double dash")
#test-parse("CH3-A(-CH3)(-CH3)-CH3", "Multiple branches")

// Invalid parenthesis
#test-parse("CH3(", "Unclosed parenthesis")
#test-parse("CH3)", "Extra closing parenthesis")
#test-parse("CH3(-OH", "Unclosed branch")
#test-parse("CH3-OH)", "Extra closing in chain")

// Deeply nested structure
#test-parse("-(-(-(-OH)))", "Deeply nested (3 levels)")
#test-parse("-(-(-(-(-OH))))", "Deeply nested (4 levels)")
#test-parse("-(-(-(-(-(-OH)))))", "Deeply nested (5 levels)")
#test-parse("-(-(-(-(-(-(-OH))))))", "Deeply nested (6 levels)")
#test-parse("-(-(-(-(-(-(-(-OH)))))))", "Deeply nested (7 levels)")
#test-parse("-(-(-(-(-(-(-(-(-OH))))))))", "Deeply nested (8 levels)")
#test-parse("-(-(-(-(-(-(-(-(-(-OH)))))))))", "Deeply nested (9 levels)")
#test-parse("-(-(-(-(-(-(-(-(-(-(-OH))))))))))", "Deeply nested (10 levels)")
#test-parse("-(-(-(-(-(-(-(-(-(-(-(-OH)))))))))))", "Deeply nested (11 levels)")
// #test-parse("-(-(-(-(-(-(-(-(-(-(-(-(-OH))))))))))))", "Deeply nested (12 levels)")
// #test-parse("-(-(-(-(-(-(-(-(-(-(-(-(-(-OH)))))))))))))", "Deeply nested (13 levels)")
// #test-parse("-(-(-(-(-(-(-(-(-(-(-(-(-(-(-OH))))))))))))))", "Deeply nested (14 levels)")
// #test-parse("-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-OH)))))))))))))))", "Deeply nested (15 levels)")
// #test-parse("-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-OH))))))))))))))))", "Deeply nested (16 levels)")
// #test-parse("-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-OH)))))))))))))))))", "Deeply nested (17 levels)")
// #test-parse("-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-OH))))))))))))))))))", "Deeply nested (18 levels)")
// #test-parse("-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-OH)))))))))))))))))))", "Deeply nested (19 levels)")
// #test-parse("-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-(-OH))))))))))))))))))))", "Deeply nested (20 levels)")

// Complex branching patterns
#test-parse("C()()()()", "Empty branches")
#test-parse("C(-CH3)()(-OH)", "Mixed empty and filled branches")
#test-parse("C(-)(-)(=)", "Branches with only bonds")

// #test-parse("$CH_3$-CH2-OH", "Typst math notation")

// Long chain
#let long-chain = "CH3-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-CH2-OH"
#test-parse(long-chain, "Very long chain (50 CH2 units)")

= Ring structure edge cases

// Basic rings
#test-parse("@6", "Simple 6-membered ring")
#test-parse("@5", "5-membered ring")
#test-parse("@4", "4-membered ring")
#test-parse("@3", "3-membered ring")
#test-parse("@7", "7-membered ring")
#test-parse("@8", "8-membered ring")

// Ring size boundary values
#test-parse("@2", "2-membered ring (chemically impossible)")
#test-parse("@1", "1-membered ring (invalid)")
#test-parse("@10", "10-membered ring")
#test-parse("@15", "15-membered ring (macrocycle)")
#test-parse("@20", "20-membered ring (large macrocycle)")

// Ring bond patterns
#test-parse("@6(------)", "Ring with explicit single bonds")
#test-parse("@6(=-=-=-)", "Benzene with alternating bonds")
#test-parse("@6(======)", "Ring with all double bonds (impossible)")
#test-parse("@6(#-----)", "Ring with triple bond (strained)")

// Ring substituents
#test-parse("@6(------CH3)", "Ring with one substituent")
#test-parse("@6(------CH3)(-OH)", "Ring with adjacent substituents")
#test-parse("@6(------CH3)-OH", "Ring with separated substituents")
#test-parse("---(-OH)", "Ring with 1,3-substituents")
#test-parse("@6(------CH3)--(-OH)", "Ring with 1,3-substituents")
#test-parse("@6(------CH3)---(-OH)", "Ring with 1,4-substituents")

// Ring with complex substituents
#test-parse("@6(--CH2-CH3---)", "Ring with ethyl group")
#test-parse("@6(------CH(-CH3)2)", "Ring with isopropyl group")
#test-parse("@6(-----(-C(=O)-OH)-)", "Ring with carboxyl group")
#test-parse("@6(----CH2-CH2-CH3)(-OH)", "Ring with propyl and hydroxyl")

// Ring with nested branches
#test-parse("@6(-CH2(-OH))", "Ring with branched substituent")
#test-parse("@6(-CH(-CH3)(-OH))", "Ring with multi-branched substituent")

// Ring connected to chain
#test-parse("CH3-@6", "Methyl attached to ring")
#test-parse("@6-CH3", "Ring attached to methyl")
#test-parse("CH3-@6-CH3", "Ring in middle of chain")
#test-parse("CH3-CH2-@6-CH2-CH3", "Ring embedded in chain")

// Multiple rings
#test-parse("@6-@6", "Two connected rings (biphenyl)")
#test-parse("@6-A", "Two connected rings (biphenyl)")
#test-parse("@6-CH2-@6", "Rings connected by methylene")
#test-parse("@6=@6", "Rings connected by double bond")
#test-parse("@6-@5", "Different sized rings connected")

// Invalid ring notation (expected parse error)
// #test-parse("@", "Asterisk without size")
// #test-parse("@0", "Zero-sized ring")
// #test-parse("@-1", "Negative ring size")
// #test-parse("@a", "Non-numeric ring size")
// #test-parse("@6.5", "Decimal ring size")

// Ring with empty parentheses
#test-parse("@6()", "Ring with empty parentheses")
#test-parse("@6(())", "Ring with nested empty parentheses")
#test-parse("@6(CH3)", "Ring with atom in parentheses (invalid)")
#test-parse("@6(-)", "Ring with only bond")
#test-parse("@6((-))", "Ring with parenthesized bond")
#test-parse("@6(-=-=-(-O-CH3)=)", "Ring with carboxyl group")

// Label special cases
#test-parse("CH3:", "Label without name")
#test-parse("CH3::", "Double colon")
#test-parse("CH3:label1:label2", "Multiple labels")
#test-parse(":labelonly", "Label without atom")

// Consecutive bonds
#test-parse("CH3=-CH3", "Mixed bond types")
// Multiple different bonds are grammar errors so omitted
#test-parse("CH3<>CH3", "Consecutive wedge bonds")

// Number processing
#test-parse("C2H6", "Molecular formula style")
#test-parse("CH23", "Large subscript")
#test-parse("C123H456", "Very large numbers")

= Conversion edge cases


// Circular reference possibility
// Ring structure nested test is omitted

// Very many branches
#let many-branches = "C(-CH3)(-CH3)(-CH3)(-CH3)(-CH3)(-CH3)(-CH3)(-CH3)(-CH3)(-CH3)"
#test-parse(many-branches, "10 branches on single carbon")

// Interchangeable bond patterns
// Complex bond patterns are omitted

// All bond types
// Complex bond types are omitted

= Actually chemically invalid structures

== Chemically impossible but syntactically valid

// Pentavalent carbon
#test-parse("C(-H)(-H)(-H)(-H)(-H)", "Pentavalent carbon")

// 2-membered ring
// 2-membered ring test is omitted

// Triple nested
#test-parse("CH3(-CH2(-CH(-CH2(-OH))))", "Quadruple nested")

= Boundary value test

== Minimum case
#test-parse("H", "Single hydrogen")
#test-parse("C", "Single carbon")

== Maximum case
// Very long atom name
#test-parse("CH3CH2CH2CH2CH2CH2CH2CH2CH2CH2OH", "Long atom string")

// Very long label
#test-parse("CH3:verylonglabelnamethatshouldstillwork", "Long label name")

= Unicode and special characters

// #test-parse("CH₃-CH₂-OH", "Unicode subscripts")
// #test-parse("CH³⁺", "Unicode superscript charge")
// #test-parse("CH3–CH2–OH", "En dash bonds")
// #test-parse("CH3−CH2−OH", "Minus sign bonds")

= Performance test input

// Huge linear structure
// 100 CH2 is too long so omitted

// Huge branching structure
// 20 branches are omitted

// Deep nested
// 10 levels of nesting are omitted

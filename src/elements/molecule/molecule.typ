// Molecule parser and transformer module
//
// This module provides a high-level declarative syntax for chemical structures.
//
// Example usage:
//   #skeletize(molecule("CH3-CH2-OH"))  // Ethanol
//   #skeletize(molecule("@6(-=-=-=)"))  // Benzene
//
// Supported syntax:
//   - Atoms: C, H, O, N, Cl, etc.
//   - Bonds: - (single), = (double), # (triple), > < (wedge), :> <: (dashed wedge)
//   - Branches: (bond content) e.g., CH3-CH(-OH)-CH3
//   - Rings: @n e.g., @6 for hexagon, @5 for pentagon
//   - Labels: :name e.g., CH3:start
//   - Charges: ^+ ^- ^2+ ^3- e.g., NH4^+
//   - Isotopes: ^14C, ^235U
//
// Limitations:
//   - Maximum nesting depth: ~11 levels due to Typst's recursion limit
//     Deeply nested structures like "-(-(-(-(...)))) " beyond 11 levels will fail
//   - This is a limitation of the parser combinator approach in Typst
//
#import "parser.typ": alchemist-parser
#import "transformer.typ": transform

/// Parse and transform a molecule string into alchemist elements.
///
/// - content (string): The molecule string to parse
/// - name (string): Optional name for the molecule group
/// - ..args: Additional arguments (reserved for future use)
///
/// Returns: Array of alchemist elements or error content
#let molecule(content, name: none, ..args) = {
  let parsed = alchemist-parser(content)
  if not parsed.success {
    // Display error inline
    return text(fill: red)[
      Failed to parse "#content": #parsed.error
    ]
  }

  let reaction = parsed.value
  transform(reaction)
}

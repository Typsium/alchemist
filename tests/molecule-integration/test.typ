#import "../../lib.typ": *
#import "../../src/elements/molecule/molecule.typ": molecule

= Molecule Integration Tests

== Organic Compounds

=== Ethanol
#skeletize(molecule("CH3-CH2-OH"))

=== Isopropanol
#skeletize(molecule("CH3-CH(-OH)-CH3"))

=== Acetone
#skeletize(molecule("CH3-C(=O)-CH3"))

=== Acetic Acid
#skeletize(molecule("CH3-C(=O)-OH"))

=== Benzene Ring Structure
#skeletize(molecule("@6(-=-=-=)"))

== Amino Acids

=== Glycine
#skeletize(molecule("NH2-CH2-C(=O)-OH"))

=== Alanine
#skeletize(molecule("NH2-CH(-CH3)-C(=O)-OH"))

=== Serine
#skeletize(molecule("NH2-CH(-CH2(-OH))-C(=O)-OH"))

== Sugars

=== Linear Glucose
#skeletize(molecule("CHO-CH(-OH)-CH(-OH)-CH(-OH)-CH(-OH)-CH2OH"))

=== Linear Fructose
#skeletize(molecule("CH2OH-C(=O)-CH(-OH)-CH(-OH)-CH(-OH)-CH2OH"))

== Fatty Acids

=== Butyric Acid
#skeletize(molecule("CH3-CH2-CH2-C(=O)-OH"))

=== Palmitic Acid
#skeletize(molecule("CH3-(CH2)14-C(=O)-OH"))

== Complex Branching Structures

=== tert-Butyl Alcohol
#skeletize(molecule("C(-CH3)(-CH3)(-CH3)-OH"))

=== Neopentane
#skeletize(molecule("C(-CH3)(-CH3)(-CH3)-CH3"))

=== Complex Branching Alcohol
#skeletize(molecule("CH3-C(-CH3)(-CH2(-OH))-CH2-CH3"))

== Unsaturated Compounds

=== Ethylene
#skeletize(molecule("CH2=CH2"))

=== Acetylene
#skeletize(molecule("HC#CH"))

=== Butadiene
#skeletize(molecule("CH2=CH-CH=CH2"))

=== Acrylic Acid
#skeletize(molecule("CH2=CH-C(=O)-OH"))

== Cyclic Compounds

=== Cyclohexane
#skeletize(molecule("@6(------)"))

=== Cyclohexanol
#skeletize(molecule("@6(-----(-OH)-)"))

=== Methylcyclohexane
#skeletize(molecule("@6(------)-CH3"))

=== 1,4-Dimethylcyclohexane
#skeletize(molecule("@6((-CH3)---(-CH3)---)"))

== Labeled Structures

=== Reaction Site Marking
#skeletize(molecule("CH3:start-CH2-CH2-OH:end"))

=== Substituent Identification
#skeletize(molecule("CH3-CH:carbon(-OH:hydroxyl)-CH3"))

== Stereochemistry

=== Wedge Bond (Stereochemistry)
#skeletize(molecule("CH3<CH(-OH)>CH3"))

=== Dashed Wedge Bond
#skeletize(molecule("CH3<|CH(-OH)|>CH3"))

== Polymers

=== Polyethylene Unit
// #skeletize(molecule("(-CH2-CH2-)n"))

=== Polystyrene Unit
// #skeletize(molecule("(-CH2-CH(-@6)-)n"))

== Complex Natural Compounds (Simplified)

=== Caffeine Skeleton (Simplified)
#skeletize(molecule("@6((=O)-N(-)-@5(-N=-N(-)-)=-(=O)-N(-)-)"))
#skeletize(molecule("@6((=O)-N(-)-@5(-N=-N(-)-=)-(=O)-N(-)-)"))

== Pharmaceutical Skeleton (Simplified)

=== Aspirin
#skeletize(molecule("@6(-=-(-O-(=O)-CH3)=(-(=O)-OH)-=)"))

=== Paracetamol
#skeletize(molecule("@6((-OH)-=-(-NH-(=O)-CH3)=-=)"))

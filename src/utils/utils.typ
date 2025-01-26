#import "@preview/cetz:0.3.1"

#let convert-length(ctx, num) = {
  // This function come from the cetz module
  return if type(num) == length {
    float(num.to-absolute() / ctx.length)
  } else if type(num) == ratio {
    num
  } else {
    float(num)
  }
}

/// get the distance between two anchors
#let distance-between(ctx, from, to) = {
  let (ctx, (from-x, from-y, _)) = cetz.coordinate.resolve(ctx, from)
  let (ctx, (to-x, to-y, _)) = cetz.coordinate.resolve(ctx, to)
  let distance = calc.sqrt(calc.pow(to-x - from-x, 2) + calc.pow(
    to-y - from-y,
    2,
  ))
  distance
}

/// merge two imbricated dictionaries together
/// The second dictionary is the default value if the key is not present in the first dictionary
#let merge-dictionaries(dict1, default) = {
	let result = default
	for (key, value) in dict1 {
		if type(value) == dictionary {
			result.at(key) = merge-dictionaries(value, default.at(key))
		} else {
			result.at(key) = value
		}
	}
	result
}
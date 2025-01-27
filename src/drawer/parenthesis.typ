#import "../utils/utils.typ"
#import "@preview/cetz:0.3.2"

#let bounding-box-height(bounds) = {
	calc.abs(bounds.high.at(1) - bounds.low.at(1))
}

#let bounding-box-width(bounds) = {
	calc.abs(bounds.high.at(0) - bounds.low.at(0))
}

#let draw-parenthesis(parenthesis, ctx, draw-molecules-and-link) = {
	let auto-align-left = false
  let left-anchor = if parenthesis.body.at(0).type == "molecule" {
		auto-align-left = true
    let name = parenthesis.body.at(0).name
    if name == none {
      name = "molecule" + str(ctx.group-id)
    }
    ctx.group-id += 1
    parenthesis.body.at(0).name = name
    (name: name, anchor: "west")
  } else if parenthesis.body.at(0).type == "link" {
    let name = parenthesis.body.at(0).at("name", default: "link" + str(ctx.link-id))
    ctx.link-id += 1
    parenthesis.body.at(0).name = name
    (name: name, anchor: 50%)
  } else {
    panic("The first element of a parenthesis must be a molecule or a link")
  }
	let auto-right-align = false
	let right-anchor = if parenthesis.body.at(-1).type == "molecule" {
		auto-right-align = true
		let name = parenthesis.body.at(-1).name
		if name == none {
			name = "molecule" + str(ctx.group-id)
		}
		ctx.group-id += 1
		parenthesis.body.at(-1).name = name
		(name: name, anchor: "east")
	} else if parenthesis.body.at(-1).type == "link" {
		let name = parenthesis.body.at(-1).at("name", default: "link" + str(ctx.link-id))
		ctx.link-id += 1
		parenthesis.body.at(-1).name = name
		(name: name, anchor: 50%)
	} else {
		panic("The last element of a parenthesis must be a molecule or a link")
	}

  let (parenthesis-ctx, drawing, parenthesis-rec, cetz-rec) = draw-molecules-and-link(
    ctx,
    parenthesis.body,
  )
  ctx = parenthesis-ctx
	parenthesis-rec += {
		import cetz.draw: *
		get-ctx(cetz-ctx => {
			let sub-bounds = cetz.process.many(cetz-ctx, drawing).bounds
			let sub-height = bounding-box-height(sub-bounds)
			let sub-v-mid = sub-bounds.low.at(1) + sub-height / 2

			let sub-width = bounding-box-width(sub-bounds)

			let height = parenthesis.at("height")
			if height == none {
				if not parenthesis.align {
					panic("You must specify the height of the parenthesis if they are not aligned")
				}
				height = sub-height
			} else {
				height = utils.convert-length(cetz-ctx, height)
			}
			let block = block(height: height * cetz-ctx.length * 1.2, width: 0pt)
			let left-parenthesis = {
				set text(top-edge: "bounds", bottom-edge: "bounds")
				math.lr($parenthesis.l block$, size: 100%)
			}
			let right-parenthesis = {
				set text(top-edge: "bounds", bottom-edge: "bounds")
				math.lr($block parenthesis.r$, size: 100%)
			}

			let right-parenthesis-with-attach = {
				set text(top-edge: "bounds", bottom-edge: "bounds")
				math.attach(right-parenthesis, br: parenthesis.br, tr: parenthesis.tr)
			}

			let (_, (lx, ly, _)) = cetz.coordinate.resolve(cetz-ctx, update: false, left-anchor)
			let (_, (rx, ry, _)) = cetz.coordinate.resolve(cetz-ctx, update: false, right-anchor)
			
			let hoffset = calc.abs(sub-width - calc.abs(rx - lx))

			if auto-align-left {
				ly += (ly - sub-v-mid)
			}
			if auto-right-align {
				ry += (ry - sub-v-mid)
			}
			if parenthesis.align {
				ry = ly
			}

			let right-bounds = cetz.process.many(cetz-ctx, content((0,0),right-parenthesis)).bounds
			let right-with-attach-bounds = cetz.process.many(cetz-ctx, content((0,0),right-parenthesis-with-attach)).bounds
			let right-hoffset = calc.abs(right-bounds.low.at(0) - right-with-attach-bounds.low.at(0))
			let right-voffset = calc.abs(right-bounds.low.at(1) - right-with-attach-bounds.low.at(1))
			if (parenthesis.tr != none and parenthesis.br != none) {
				right-voffset /= 2
			} else if (parenthesis.tr != none) {
				right-voffset *= -1
			}
			content((lx - hoffset , ly), anchor: "mid", left-parenthesis)
			content((rx + hoffset + right-hoffset, ry - right-voffset), anchor: "mid", right-parenthesis-with-attach)
			
		})
	}
  (ctx, drawing, parenthesis-rec, cetz-rec)
}

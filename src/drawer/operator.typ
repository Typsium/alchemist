#import "@preview/cetz:0.3.4": draw, process, util

#let draw-operator(operator, fragment-drawing, ctx) = {
  import draw: *

  let op-name = operator.name
  ctx.last-anchor = (type: "coord", anchor: (rel: (operator.margin, 0), to: (name: op-name, anchor: "east")))

  (
    ctx,
    get-ctx(cetz-ctx => {
      let bounds = util.revert-transform(cetz-ctx.transform, process.many(cetz-ctx, fragment-drawing).bounds)

      let v-middle = bounds.low.at(1) + (bounds.high.at(1) - bounds.low.at(1)) / 2

      let west-previous-mol-anchor = (bounds.high.at(0), v-middle)

      let east-op-anchor = (rel: (operator.margin, 0), to: west-previous-mol-anchor)

      let op = if (operator.op == none) {
        ""
      } else {
        operator.op
      }

      content(
        name: op-name,
        anchor: "west",
        east-op-anchor,
        op,
      )

			if (ctx.config.debug) {
				circle(west-previous-mol-anchor, radius: 0.05, fill: yellow, stroke: none)
				circle(ctx.last-anchor.anchor, radius: 0.05, fill: yellow, stroke: none)
			}
    }),
  )
}

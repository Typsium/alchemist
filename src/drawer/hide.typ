#import "@preview/cetz:0.5.2"

#let draw-hide(hide, ctx, draw-fragment-and-link) = {
  let hold-hide = ctx.hide
  let hold-hide-bounds = ctx.hide-bounds
  ctx.hide = true
  ctx.hide-bounds = hide.bounds
  let (hide-ctx, drawing, cetz-rec) = draw-fragment-and-link(
    ctx,
    hide.body,
  )
  hide-ctx.hide = hold-hide
  hide-ctx.hide-bounds = hold-hide-bounds
  drawing = cetz.draw.hide(drawing, bounds: hide.bounds)
  (hide-ctx, drawing, cetz-rec)
}
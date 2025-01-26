
#let draw-parenthesis(parenthesis, ctx, draw-molecules-and-link) = {
  let anchor = if element.body.at(0).type == "molecule" {
    let name = element.body.at(0).name
    if name == none {
      name = "molecule" + str(ctx.group-id)
    }
    ctx.group-id += 1
    element.body.at(0).name = name
    (name: name, anchor: "west")
  } else if element.body.at(0).type == "link" {
    let name = element.body.at(0).at("name", default: "link" + str(ctx.link-id))
    ctx.link-id += 1
    element.body.at(0).name = name
    (name: name, anchor: 100%)
  } else {
    panic("The first element of a parenthesis must be a molecule or a link")
  }
  let (parenthesis-ctx, drawing, cetz-rec) = draw-molecules-and-link(
    ctx,
    element.body,
  )
  ctx = parenthesis-ctx
  cetz-drawing += cetz-rec
  get-ctx(cetz-ctx => {
    let (ctx: cetz-ctx, bounds, drawables) = cetz.process.many(cetz-ctx, drawing)
    let height = calc.abs(bounds.high.at(1) - bounds.low.at(1)) * cetz-ctx.length
    let width = calc.abs(bounds.high.at(0) - bounds.low.at(0)) * cetz-ctx.length
    let parenthesis = math.attach(math.lr($element.l #block(height: height, width: width) element.r$))
    let parenthesis-bounds = cetz.process.element(cetz-ctx, content((0, 0), parenthesis).at(0)).bounds
    let offset = (
      calc.abs(
        calc.abs(parenthesis-bounds.high.at(0) - parenthesis-bounds.low.at(0))
          - calc.abs(bounds.high.at(0) - bounds.low.at(0)),
      )
        / 2
    )
    let parenthesis = math.attach(
      math.lr($element.l #block(height: height, width: width) element.r$),
      tr: element.tr,
      br: element.br,
    )
    content(anchor: "base-west", (rel: (-offset, 0), to: anchor), { parenthesis })
  })
  drawing
}

// general set rules
#set text(font: "Avenir")
#set par(
  first-line-indent: 0.5cm,
  spacing: 9pt,
)
#set page(
  margin: 0.5cm,
  numbering: (..n) => [*#numbering("1", n.at(0))*],
  number-align: center,
  footer-descent: -10pt,
  width: 450pt * 1.2,
  height: 550pt * 1.2,
  columns: 2,
)

// small content functions and variables
#let mult = super[‡]
#let group-num = "A"
#let group-divide-color = maroon
#let u(txt) = text(weight: "black", txt)
#let i(txt) = text(eastern, weight: "black", txt)
#let gg(num, p: true) = [#if p [(];g  roup *#text(group-divide-color, numbering(group-num, num))*#if p [)]]
#let g(num) = gg(num, p: false)
#let status(txt, supp: "") = text(luma(70%))[#v(0cm) #align(right)[_#supp #txt;_]]
#let colors = (
  "#D88C9A",
  "#F2D0A9",
  "#F1E3D3",
  "#99C1B9",
  "#8E7DBE",
)
#let frac(num1, num2, inch: false) = [#h(0.15cm)#box[
    #place(
      top + left,
      dx: -4pt,
      dy: 0pt,
      text(8pt)[#num1],
    )\/#place(
      bottom + right,
      dx: 4pt,
      text(8pt)[#num2],
    )#if inch {
      place(
        top + right,
        dx: 9pt,
        text(8pt)["],
      )
    }]#h(if inch { 0.3cm } else { 0.15cm })
]
#let half = frac(1, 2)
#let half-in = frac(1, 2, inch: true)
#let dietary-symbol(dietary-type) = {
  if dietary-type in ("gf",) {
    rotate(-45deg, square(
      fill: blue.desaturate(30%),
      size: 12pt,
      inset: 0pt,
      [#set align(center + horizon); #rotate(45deg, text(7pt, white)[#upper(
          dietary-type,
        )])],
    ))
  }
  if dietary-type in ("nf",) {
    circle(
      fill: green.darken(10%).desaturate(50%),
      radius: 7pt,
      inset: 0pt,
      [#set align(center + horizon); #rotate(0deg, text(7pt, white)[#upper(
          dietary-type,
        )])],
    )
  }
}

// ingredients list functions
#let group-counter = counter("ingredients-group")
#let ingredient-entry(elems) = if type(elems) == array {
  (
    u(elems.at(0)),
    [#set par(hanging-indent: 15pt);#i(elems.at(1)) #elems.at(2, default: []) #parbreak()],
  )
} else if type(elems) == int {
  (
    table.hline(stroke: (paint: group-divide-color, dash: "dotted")),
    table.cell(
      colspan: 2,
      inset: (bottom: -5pt),
      place(top + right, dx: 1pt, dy: -2pt)[#group-counter.step()#context text(
          7pt,
          group-divide-color,
        )[#group-counter.display(group-num) ↓]],
    ),
  )
} else {
  (
    table.hline(stroke: (paint: group-divide-color, dash: "dotted")),
  )
}
#let ingredient-table(ingredients-array) = {
  if ingredients-array.len() == 0 { return }
  group-counter.update(0)
  block(
    inset: (left: 25pt, right: 5pt),
    table(
      columns: 2,
      inset: (x, y) => (left: 5pt * int(x == 1), top: 5pt, right: 1pt + 10pt * int(x == 1), bottom: 5pt),
      stroke: none,
      align: (x, y) => if x == 0 { right } else { left },
      ..for ing in ingredients-array { ingredient-entry(ing) }
    ),
  )
}

// recipe function
#let recipe-types = ("outline", "breakfast", "side", "main", "treat")
#let recipe-type-symbols = (
  "icons/hat.svg",
  "icons/shakers.svg",
  "icons/pin.svg",
  "icons/dish.svg",
  "icons/toaster.svg",
)
#let recipe(
  recipe-type,
  title,
  ingredients,
  description,
  is-nf: false,
  is-gf: false,
  is-colbreak: true,
  adapted-from: none,
  bon-appetit: false,
  image-path: none,
  image-above: false,
  image-below: false,
) = {
  assert(recipe-type in recipe-types, message: "bad recipe type >:(")
  let gluten-freeable = if is-gf { "gf" } else { none }
  let nut-freeable = if is-nf { "nf" } else { none }
  // standard image size: 390x975
  let recipe-image = if image-path != none {
    image(image-path, width: 100%, height: if image-above or image-below { 1fr } else { 100% })
  } else { none }
  return (
    recipe-type: recipe-type,
    content: [
      #if recipe-image != none and not image-below {
        recipe-image
        if image-above { v(0.3cm) }
      }
      #block(width: 100%)[
        #show heading: title => align(center, underline(text(15pt, title), offset: 7pt, extent: -9pt))
        == #title
        #if nut-freeable != none {
          place(
            top + right,
            dietary-symbol(nut-freeable),
          )
        }
        #if gluten-freeable != none {
          place(
            top + left,
            dietary-symbol(gluten-freeable),
          )
        }
      ] #label(title)
      #v(0.2cm)
      #if adapted-from != none { status(adapted-from, supp: "adapted from" + if bon-appetit { " Bon Appétit" }) }
      #v(0.2cm)
      #align(center, ingredient-table(ingredients))
      #v(0.3cm)
      #description
      #v(0.5cm)
      #if recipe-image != none and image-below { recipe-image }
      #if is-colbreak { colbreak() } else {
        line(length: 100%)
        v(0.3cm)
      }
    ],
  )
}

// heading styling
#let category-counter = counter("category")
#show heading.where(level: 1): it => context {
  let next-section-location = query(heading.where(level: 1).after(here(), inclusive: false))
    .at(0, default: query(<end>).first())
    .location()
  let child-heading-selector = selector(heading.where(level: 2))
    .after(here())
    .before(next-section-location, inclusive: false)
  let heading-count = category-counter.get().first()
  let style-indx = calc.rem(heading-count, colors.len())
  let page-color = rgb(colors.at(style-indx))
  let icon = read(recipe-type-symbols.at(style-indx))
  set page(
    fill: page-color.lighten(30%),
    background: {
      rect(width: 100% - 20pt, height: 100% - 20pt, stroke: page-color.saturate(20%) + 5pt)
      place(center + horizon, dy: -80pt - 140pt * int(heading-count == 0), image(
        bytes(icon.replace("#4d4d4d", page-color.saturate(20%).to-hex())),
        width: 50% - 30% * int(heading-count == 0),
      ))
    },
    numbering: none,
    margin: 10%,
    columns: 1,
  )
  category-counter.step()
  if heading-count == 0 {
    let heading-color = rgb("#2E1F27")
    v(4cm)
    align(center, box(stroke: (paint: heading-color, thickness: 2pt), radius: 45pt, inset: 10pt, box(
      stroke: (paint: heading-color, thickness: 8pt),
      radius: 40pt,
      inset: 20pt,
    )[
      #text(heading-color, 50pt)[Favorite \ Recipes]
      #line(stroke: heading-color, length: 30%)
      #v(0.3cm)
      #text(heading-color)[_compiled by Vivian and her lover_]
    ]))
    v(1fr)
  }
  set text(page-color.saturate(50%).darken(20%))
  pad(top: 1.5cm, bottom: 0.7cm, align(center, heading(level: 10, text(22pt)[\- #h(0.5cm) #it.body #h(0.5cm) \-])))
  outline(
    title: none,
    target: if heading-count == 0 {
      selector(heading.where(level: 1)).after(here())
    } else {
      child-heading-selector
    },
    indent: 0pt,
  )
}

// all recipes
#let all-recipes = (
  recipe(
    "side",
    "sushi rice",
    is-gf: true,
    is-colbreak: false,
    (
      ([2 cup], [dry white rice]),
      ([3 cup], [water]),
      2,
      ([#half cup], [rice vinegar]),
      ([1 Tbsp], [cooking oil]),
      ([#frac(1, 4) cup], [white sugar]),
      ([1 tsp], [salt]),
    ),
    [
      Rinse #i[rice] under cold water in colander until it runs clear. Add to pan with #i[water], set to #u[medium-high]. Bring to boil, then reduce heat to #u[low]. Cover until water is absorbed, #u[\~20 mins].

      Add #g(1) to sauce pan over #u[medium] heat until sugar dissolved. Add to cooked rice, mix until liquid is absorbed.
    ],
  ),
  recipe(
    "side",
    "fried onions",
    is-gf: true,
    image-path: "imgs/fried-onions.jpg",
    image-above: true,
    (
      ([3], [yellow onions], [cut into strips]),
      ([2 Tbsp], [corn starch]),
      ([1 cup], [frying oil]),
    ),
    [
      Heat #i[oil]. Mix #i[onions] in #i[corn starch] until well-coated. Fry in pot until golden and crispy.
    ],
  ),
  recipe(
    "side",
    "tomato balsamic cheese bites",
    is-colbreak: false,
    (
      ([1], [french bread loaf], [sliced and toasted]),
      ([1], [onion], [sliced and caramelized]),
      ([3], [tomatoes], [#frac(1, 4, inch: true) slices]),
      1,
      ([#half cup], [cream cheese]),
      ([#half cup], [sour cream]),
      ([1 tsp], [pepper]),
      ([1], [garlic clove], [finely chopped]),
      ([2], [green onions], [for chives]),
      2,
      ([1 Tbsp], [balsamic vinegar]),
      ([1 Tbsp], [olive oil]),
    ),
    [
      Whip #g(1) till light and fluffy.
      Drizzle #i[tomato] slices with #g(2) and #u[broil] until tomatoes start to shrivel. Top #i[french bread] slices with prepared components.
    ],
  ),
  recipe(
    "side",
    "boullion-baked tofu",
    is-nf: true,
    is-gf: true,
    image-path: "imgs/bouillon-baked-tofu.png",
    image-above: true,
    adapted-from: "Nov 24 p32",
    (
      ([1], [firm tofu package], [(\~14oz) pressed, cubed, patted dry]),
      1,
      ([2 tsp], [vegetable boullion paste]),
      ([#half tsp], [pepper]),
      ([#half tsp], [garlic powder]),
      ([#half tsp], [sugar]),
      ([2 Tbsp], [olive oil]),
      none,
      ([1 Tbsp], [corn starch]),
    ),
    [
      Mix #g(1) and toss with #i[tofu]. Cover and let sit at least #u[15 mins]. Prepare oven (middle rack, #u[400°F]). Lightly oil parchment paper on rimmed baking sheet.

      Uncover #i[tofu] and sprinkle on #i[corn starch]. Toss to coat. Arrange tofu on prepared sheet, not touching each other. Bake until golden brown and crispy, #u[30-35 mins].
    ],
  ),
  recipe(
    "main",
    "miso-tahini & tofu grain bowls",
    adapted-from: "Apr 25 p20",
    image-path: "imgs/tofu-grain-bowl.png",
    (
      ([1], [firm tofu package], [(\~14oz) pressed, cubed, patted dry]),
      1,
      ([1#half cup], [dry brown rice], [rinsed until water runs clear]),
      ([#half cup], [dry quinoa]),
      2,
      ([8 oz], [red cabbage], [thinly sliced]),
      ([3 Tbsp], [rice vinegar#mult]),
      ([2 tsp], [honey#mult]),
      ([#half tsp], [salt]),
      none,
      ([1 Tbsp], [soy sauce]),
      3,
      ([2], [broccoli bunches], [cut into florets with long stems]),
      ([1 tsp], [red pepper flakes]),
      4,
      ([3 cup], [miso]),
      ([2 Tbsp], [tahini]),
      ([#frac(3, 4) tsp], [turmeric]),
      ([2 tsp], [honey#mult]),
      ([2 Tbsp], [rice vinegar#mult]),
      none,
      ([1], [avocado], [thinly sliced]),
    ),
    [
      Preheat oven to #u[450°F]. Bring grains #gg(1) and #u[2#half cup] #i[water] to a boil in medium saucepan. Cover tightly with lid, reduce heat to #u[low]. Cook until grains are tender and liquid is absorbed, #u[40 mins]. Meanwhile, combine #g(2) in large bowl and vigorously massage with hands. Set aside for serving.

      Arrange #i[tofu] on rimmed baking sheet, drizzle with #i[soy sauce] and #u[3 Tbsp] #i[olive oil]. Roast until lightly browned, #u[9-11 mins]. Combine #g(3) and roast alongside tofu until starting to char, #u[15-20 mins].

      Whisk #g(4) to make sauce for serving.

      Assemble bowls with components and serve.
    ],
  ),
  recipe(
    "main",
    "gado gado",
    image-path: "imgs/gado-gado.jpg",
    adapted-from: "Apr 24",
    (
      ([14 oz], [extra-firm tofu], [pressed, cut into #half-in cubes, patted dry]),
      ([16 oz], [white rice noodles], [wide like linguine]),
      1,
      ([#frac(3, 4) cup], [creamy peanut butter]),
      ([3 Tbsp], [lime juice]),
      ([1#half Tbsp], [garlic chili sauce]),
      ([3], [cloves garlic], [finely chopped]),
      ([#half cup], [water]),
      2,
      ([#frac(3, 4) cup], [brown sugar]),
      ([#half cup], [soy sauce]),
      3,
      ([1], [red onion], [finely chopped]),
      ([3], [carrots], [cut into matchsticks]),
      ([1], [bundle cilantro], [tough stems removed]),
      ([1], [cucumber], [thinly sliced]),
      ([1 cup], [peanuts], [halves or chopped]),
    ),
    [
      Combine #g(1) in a bowl to make sauce. Mix until mostly homogeneous. Set aside.

      In a skillet on #u[low], mix #g(2), stirring constantly until brown sugar is desolved. Take half of mixture and add to sauce, mixing well. Increasing skillet heat to #u[medium], add #i[tofu cubes] to the remaining half of the mixture, cooking until liquid is absorbed.

      Meanwhile, cook the #i[rice noodles] in boiling water until al dente, #u[\~5 mins]. Soon after draining and lightly rinsing the noodles, add sauce.

      Serve noodles with cooked tofu and #g(3).
    ],
  ),
  // recipe(
  //   "treat",
  //   "title",
  //   adapted-from: "May 25 p38",
  //   (
  //     ([1 lb], [tofu], [wow]),
  //   ),
  //   [
  //     description
  //   ],
  // ),
  recipe(
    "breakfast",
    "Chia Seed Pudding",
    is-gf: true,
    is-nf: true,
    image-path: "imgs/chia-seed-pudding.jpg",
    image-above: true,
    adapted-from: "PlantYou",
    (
      ([½ cup], [], [fruit of choice (mango for yellow, raspberries for pink, blueberries for purple)]),
      ([¾ cup], [], [unsweetened plant-based milk (soy, almond, cashew, or oat)]),
      ([¼ cup], [], [coconut milk]),
      ([1 teaspoon], [], [pure maple syrup]),
      ([1 teaspoon], [], [vanilla extract]),
      ([3 tablespoons], [], [chia seeds]),
      ([1 cup], [], [unsweetened Vegan Yogurt]),
    ),
    [
      In a blender, combine the fruit, plant-based milk, coconut milk, maple syrup, and vanilla. Transfer the mixture to a sealable container and stir in the chia seeds until evenly dispersed.
      Cover and allow to set in the fridge for at least 2 hours. Once thickened, transfer to jars with your vegan yogurt of choice on top.
    ],
  ),
)

#for i in recipe-types.map(recipe-type => [
  = #recipe-type;s
  #for j in all-recipes.filter(recipe => recipe.recipe-type == recipe-type) { j.content }
]) { i }

#box()<end>

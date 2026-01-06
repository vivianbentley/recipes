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
#let gg(num, p: true) = [#if p [(];group *#text(group-divide-color, numbering(group-num, num))*#if p [)]]
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
      [#set align(center + horizon); #rotate(45deg, text(if dietary-type == "gf" {7pt} else {5pt}, white)[#upper(dietary-type)])],
    ))
  } else {
    circle(
      radius: 7pt,
      inset: 0pt,
      fill: green.darken(10%).desaturate(50%),
      text(7pt, white)[#set align(center + horizon); #if dietary-type == "vegan" [V#h(1pt);V] else [V] ],
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
  if ingredients-array.len() == 0 {return}
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
#let recipe-types = ("outline", "note", "side", "main", "treat")
#let recipe-type-symbols = ("icons/hat.svg", "icons/shakers.svg", "icons/pin.svg", "icons/dish.svg", "icons/toaster.svg")
#let recipe(
  recipe-type,
  title,
  ingredients,
  description,
  is-vegan: false,
  is-vegetarian: false,
  is-gf: false,
  is-colbreak: true,
  adapted-from: none,
  bon-appetit: true,
  image-path: none,
  image-above: false,
  image-below: false,
) = {
  assert(recipe-type in recipe-types, message: "bad recipe type >:(")
  let meat-dietary-type = if is-vegan { "vegan" } else if is-vegetarian { "vegetarian" } else { none }
  let gluten-freeable = if is-gf {"gf"} else {none}
  // standard image size: 390x975
  let recipe-image = if image-path != none {image(image-path, width: 100%, height: if image-above or image-below {1fr} else {100%})} else {none}
  return (
    recipe-type: recipe-type,
    content: [
      #if recipe-image != none and not image-below {
        recipe-image
        if image-above {v(0.3cm)}
      }
      #block(width:100%)[
        #show heading: title => align(center, underline(text(15pt, title), offset: 7pt, extent: -9pt))
        == #title
        #if meat-dietary-type != none {
          place(
            top + right,
            dietary-symbol(meat-dietary-type),
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
      #if adapted-from != none {status(adapted-from, supp: "adapted from" + if bon-appetit { " Bon Appétit" })}
      #v(0.2cm)
      #align(center,ingredient-table(ingredients))
      #v(0.3cm)
      #description
      #v(0.5cm)
      #if recipe-image != none and image-below {recipe-image}
      #if is-colbreak {colbreak()} else {line(length: 100%); v(0.3cm)}
    ],
  )
}

// heading styling
#let category-counter = counter("category")
#show heading.where(level: 1): it => context {
  let next-section-location = query(selector(heading.where(level: 1)).after(here(), inclusive: false))
    .at(0, default: query(<end>).at(0))
    .location()
  let child-heading-selector = selector(heading).after(here()).before(next-section-location, inclusive: false)
  let heading-count = category-counter.get().first()
  let style-indx = calc.rem(heading-count, colors.len())
  let page-color = rgb(colors.at(style-indx))
  let icon = read(recipe-type-symbols.at(style-indx))
  {
    set page(
      fill: page-color.lighten(30%),
      background: {
        rect(width: 100% - 20pt, height: 100% - 20pt, stroke: page-color.saturate(20%) + 5pt)
        place(center + horizon, dy: -80pt - 140pt * int(heading-count == 0), image(bytes(icon.replace("#4d4d4d", page-color.saturate(20%).to-hex())), width: 50% - 30% * int(heading-count == 0)))
      },
      numbering: none,
      margin: 10%,
      columns: 1,
    )
    category-counter.step()
    if heading-count == 0 {
      let heading-color = rgb("#2E1F27")
      v(4cm)
      align(center, box(stroke: (paint: heading-color, thickness: 2pt), radius: 45pt, inset: 10pt, box(stroke: (paint: heading-color, thickness: 8pt), radius: 40pt, inset: 20pt)[
        #text(heading-color, 50pt)[some recipes \ i like]
        #line(stroke: heading-color, length: 30%)
        #v(0.3cm)
        #text(heading-color)[_compiled by miles_]
      ]))
      v(1fr)
    }
    set text(page-color.saturate(50%).darken(20%))
    v(2cm)
    text(22pt, align(center, [\- #h(0.5cm) #it.body #h(0.5cm) \-]))
    v(0.7cm)
    outline(
      title: none,
      target: if heading-count == 0 { selector(heading.where(level: 1)).after(here()) } else { child-heading-selector },
      indent: 0pt,
    )
  }
}

// all recipes
#let all-recipes = (
  recipe(
    "note",
    "how to use this book",
    (),
    [
      This cookbook is a compilation of recipes I have enjoyed from various sources, but mostly the Bon Appétit magazine. Many are modified to my liking, since the folks at Bon Appétit get ratios off sometimes (e.g., no recipe in this world needs a fourth cup of dill, not even pot pie [pg. #context locate(label("popover-topped pot pie")).page()]).
      
      Since many recipes are largely about ingredient preparation and assembly, most of the instructions are described in the ingredient list itself. Note the *instructions next to each ingredient* and the *labeled groups* that some ingredients are ordered in. To prioritize the cooking experience over ingredient collection, some ingredients are *listed multiple times* (indicated by a #mult symbol).

      Different recipe dietary types are marked next to recipe titles as follows:

      #align(center, table(
        columns:2,
        align: (x,y) => if x==0 {center + horizon} else {left + horizon},
        stroke: none,
        dietary-symbol("gf"), [gluten-free],
        dietary-symbol("vegetarian"), [vegetarian],
        dietary-symbol("vegan"), [vegan]
      ))

      I assume you have basic ingredients handy (e.g., common spices, flour, cooking oils, and other American cooking staples). You might also benefit from having a few other frequently-used ingredients on hand: #i[rice vinegar], #i[hoisin sauce], #i[miso], #i[tahini], and #i[dry white wine].

      Hope you enjoy!
      
      Love you (probably, idk who you are),

      #align(right)[_Miles_#h(1cm)]
    ],
  ),
  recipe(
    "note",
    "taking care of cast iron",
    (),
    [
      Cast iron cookware has a few unique benefits: it (1) is stovetop- and oven-safe, (2) heats more evenly, (3) lasts a really long time, and (4) resists sticking. A few important notes:

      - *Buy real cast iron*. Some cheap cast iron cookware is not made of iron, and cannot be maintained well. There are many reliable companies to keep an eye out for, including Lodge, Field Company, and Lancaster.

      - *Monitor the seasoning*. Seasoning is just several thin layers of polymerized oil (i.e., long, durable chains formed with oil molecules), which gives cast iron its dark color and stick resistance. Cast iron generally comes seasoned when purchased, but it can wear off over time.
        - Cooking with oil in cast iron will build up some seasoning on its own.
        - You might notice while scraping your cast iron that a brown substance seems to surface. It looks like surprise rust, but it is actually seasoning, which is dark brown.
        - While scraping off food waste you may reveal a silver-looking patch, which is the iron. In this case, you should vigorously scrape the whole pan, removing protrusions and loose bits of seasoning, then reseason.
        - *To season the pan*, drizzle #u[\<1 Tbsp] of oil and wipe with a paper towel to leave a thin layer on the business surfaces of the cookware. Cook in an oven at #u[\~400˚F] for one hour, upside down to prevent oil pooling. Repeat this once or twice more.
      
      - *Clean and dry it after each use*. Letting water or food waste sit on cast iron can make it rust, which is difficult to correct. Unlike what they might teach you in school, I assure you that cast iron definitely can be cleaned with #i[soap] as the layers of seasoning are very protective.
    ],
  ),
  // recipe(
  //   "note",
  //   "title",
  //   (),
  //   [
  //     description
  //   ],
  // ),
  recipe(
    "side",
    "sushi rice",
    is-vegan: true,
    is-gf: true,
    is-colbreak: false,
    (
      ([2 cup], [dry white rice]),
      ([3 cup], [water]),
      2,
      ([#half cup], [rice vinegar]),
      ([1 Tbsp], [cooking oil]),
      ([#frac(1,4) cup], [white sugar]),
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
    is-vegan: true,
    is-gf: true,
    image-path: "imgs/fried-onions.jpg",
    image-above: true,
    (
      ([3], [yellow onions], [cut into strips]),
      ([2 Tbsp], [corn starch]),
      ([1 cup], [frying oil])
    ),
    [
      Heat #i[oil]. Mix #i[onions] in #i[corn starch] until well-coated. Fry in pot until golden and crispy.
    ],
  ),
  recipe(
    "side",
    "tomato balsamic cheese bites",
    is-colbreak: false,
    is-vegetarian: true,
    (
      ([1], [french bread loaf], [sliced and toasted]),
      ([1], [onion], [sliced and caramelized]),
      ([3], [tomatoes], [#frac(1,4,inch:true) slices]),
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
      Drizzle #i[tomato] slices with #g(2) and broil until tomatoes start to shrivel. Top #i[french bread] slices with prepared components.
    ],
  ),
  recipe(
    "side",
    "eggnog",
    is-vegetarian: true,
    is-gf: true,
    (
      1,
      ([2 cup], [milk]),
      ([1 cup], [heavy cream]),
      2,
      ([6], [egg yolks]),
      ([#half cup], [sugar]),
      ([#half tsp], [salt]),
      3,
      ([1 tsp], [vanilla]),
      ([#frac(1,4) tsp], [cinnamon]),
      ([#frac(1,4) tsp], [nutmeg]),
      ([#frac(1,4) tsp], [cloves]),
    ),
    [
      Scald #g(1). Whisk #g(2) until whitened. Mix in scalded milk bit by bit. Reheat this mixture at a very low temperature, no boiling, until thickened. Mix in #g(3). Chill and serve.
    ],
  ),
  recipe(
    "side",
    "boullion-baked tofu",
    is-vegan: true,
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
  // recipe(
  //   "side",
  //   "title",
  //   adapted-from: "May 25 p38",
  //   (
  //     ([1 lb], [ground pork], [wow]),
  //   ),
  //   [
  //     description
  //   ],
  // ),
  recipe(
    "main",
    "pork and cucumber stir-fry",
    adapted-from: "May 25 p38",
    image-path: "imgs/pork-and-cucumber-stir-fry.png",
    (
      ([1 lb], [ground pork]),
      ([2 cup], [dry rice], [cooked]),
      1,
      ([3], [cucumbers], [zebra-peeled, halved lengthwise, seeds removed, sliced diagonally #u[#half-in] thick]),
      ([1 tsp], [salt]),
      2,
      ([3 Tbsp], [oyster sauce]),
      ([3 Tbsp], [soy sauce]),
      ([3 Tbsp], [dry white wine]),
      3,
      ([2-3], [jalapeños], [no seeds, thinly sliced]),
      ([1 Tbsp], [ginger powder]),
      ([2], [garlic cloves], [grated]),
      ([1 tsp], [pepper]),
    ),
    [
      Form #i[pork] into several patties, season lightly with salt. Set aside.

      Toss #i[cucumber] with #i[salt] #gg(1) in medium bowl. Let sit until cucumber starts releasing its water, about #u[10 mins]. While waiting, mix wets #gg(2) to make sauce, set aside\*.

      Rinse, drain and pat dry #i[cucumber]. Heat #u[1 Tbsp] oil in large skillet at #u[medium-high] and cook, tossing frequently, until lightly browned. Remove and set aside.

      Cook #i[pork] patties in skillet until deeply browned on both sides, about #u[5 mins] per side. Break up into bite-sized pieces and add seasonings #gg(3), cook another #u[1-2 mins].

      Add #i[cucumber] and \*reserved sauce to skillet, cook #u[\~1 min]. Add cooked #i[rice] on top.
    ],
  ),
  recipe(
    "main",
    "popover-topped pot pie",
    is-vegetarian: true,
    adapted-from: "May 25 p14",
    image-path: "imgs/popover-topped-pot-pie.png",
    (
      ([12 oz], [golden potatoes], [#u(half-in) cubes]),
      1,
      ([1 bunch], [asparagus], [#u(half-in) pieces]),
      ([1-2 cup], [carrots], [#u[#frac(1, 4, inch: true)] sliced pieces]),
      ([2 stalks], [celery], [thinly sliced]),
      ([2], [yellow onions], [chopped]),
      ([1 cup], [frozen peas]),
      2,
      ([6], [garlic cloves], [grated]),
      ([#frac(1, 4) cup], [flour#mult]),
      3,
      ([2 cup], [vegetable broth]),
      ([#half cup], [dry white wine]),
      ([#frac(2, 3) cup], [heavy cream]),
      ([1 Tbsp], [Dijon mustard]),
      ([3 Tbsp], [dill], [(save some for topping)]),
      ([1 tsp], [pepper]),
      ([1#half tsp], [lemon zest]),
      ([1#half tsp], [salt#mult]),
      4,
      ([5], [eggs], [blended till fluffy]),
      ([#half tsp], [salt#mult]),
      ([1#frac(1, 4) cup], [flour#mult]),
      ([1 oz], [Parmesan], [grated]),
      ([1#frac(1, 3) cup], [whole milk]),
      ([#half tsp], [baking powder]),
    ),
    [
      Heat #u[#frac(1, 4) cup] #i[olive oil] in Dutch oven on #u[medium]. Cook #i[potatoes] for #u[2 mins], stirring often. Add veggies #gg(1) and cook #u[15-18 mins]. Add #g(2), stirring until homogenous. Add #g(3) to pot while stirring. Simmer #u[\~1 min]. Take off heat, let sit withough stirring #u[20-60 mins].

      Prepare oven: middle rack, #u[425°F]. Mix and briefly blend #g(4) till smooth. Gently pour into pot. Bake until deep golden brown and puffed, #u[45-55 mins].
    ],
  ),
  recipe(
    "main",
    "oyakodon (parent and child)",
    adapted-from: "May 25 p18",
    image-path: "imgs/oyakodon.png",
    (
      ([1#frac(1, 4) lb], [chicken], [(preferrably thighs, but breast ok)]),
      ([1#half], [dry rice], [cooked]),
      ([2 tsp], [Hondashi powder]),
      1,
      ([1], [yellow onion], [thinly sliced]),
      ([#frac(1, 4) cup], [soy sauce]),
      ([#frac(1, 4) cup], [sake]),
      ([1 Tbsp], [sugar]),
      none,
      ([3], [green onions], [pale and dark parts separated, thinly sliced]),
      ([5], [eggs], [blended]),
    ),
    [
      Mix #i[dashi] and #u[1#half cup] hot water in a skillet until dissolved. Add #g(1) and immmer on #u[medium-high] until onion is slightly softened and liquid slightly reduced, #u[6-8 mins].

      Add #i[chicken] and #i[pale green onion] to pan. Cook until chicken is not pink on the outside, for #u[2-3 mins].

      Reduce heat to #u[medium], evenly drizzle half of #i[eggs]. Cover and simmer until eggs almost set, #u[\~2 mins]. Repeat with other half of eggs.

      Top with #i[dark green onion], serve over #i[rice].
    ],
  ),
  recipe(
    "main",
    "cauliflower chowder",
    is-vegetarian: true,
    adapted-from: "May 25 p22",
    image-path: "imgs/cauliflower-chowder.png",
    (
      ([3 Tbsp], [butter#mult]),
      1,
      ([1], [yellow onion], [finely chopped]),
      ([4], [celery stocks], [thinly sliced]),
      ([6], [garlic cloves], [finely chopped]),
      ([2 tsp], [thyme], [chopped]),
      ([1#half cup], [salt]),
      none,
      ([#frac(1, 4) cup], [flower]),
      2,
      ([1], [cauliflower head], [trimmed and cut into small florets]),
      ([10 oz], [golden potatoes], [cut into #u[#half-in] pieces]),
      ([1#half cup], [heavy cream], [chopped]),
      3,
      ([2 Tbsp], [butter#mult], [melted]),
      ([3 cup], [crackers], [like oyster or Ritz, break up into smaller pieces if necessary]),
      ([2 tsp], [Old Bay seasoning]),
      none,
      ([2 Tbsp], [miso]),
      ([1], [green onion], [for chives]),
    ),
    [
      Heat #u[3 Tbsp] #i[butter] in Dutch oven over #u[medium]. Add #g(1) and cook until onion is translucent, #u[6-8 mins]. Sprinkle in #i[flower] and stir #u[1 min]. Add #g(2) and #u[4 cup] water. Simmer until veggies are tender and liquid is slightly thickened, stirring occasionally, #u[20-25 mins].

      Toss #g(3) in a bowl. Set aside.

      Stir a few spoonfuls of soup in with #i[miso] separately, then stir into the pot.

      Serve with prepared crackers and #i[chives].
    ],
  ),
  recipe(
    "main",
    "miso-mayo chicken",
    image-path: "imgs/miso-mayo-chicken.png",
    adapted-from: "Nov 24 p12",
    (
      ([2 lb], [chicken breast], [patted dry]),
      ([2 cup], [dry jasmine rice], [cooked]),
      1,
      ([1 Tbsp], [soy sauce]),
      ([#half cup], [mayo#mult]),
      ([3 Tbsp], [white miso#mult]),
      2,
      ([2], [leeks], [white and pale green parts only, sliced #frac(1,4,inch:true) thick]),
      ([1 lb], [brussel sprouts], [trimmed, quartered lengthwise]),
      3,
      ([1 Tbsp], [rice vinegar#mult]),
      ([1 Tbsp], [white miso#mult]),
      ([#frac(1,4) cup], [mayo#mult]),
      none,
      ([2 Tbsp], [rice vinegar#mult]),
      ([2 tsp], [sesame seeds]),
    ),
    [
      Preheat oven to #u[425°F], rack in middle. Whisk #g(1), use to coat #i[chicken]. Arrange veggies #gg(2) on baking sheet with parchment paper, salt and drizzle #u[\~1 Tbsp] #i[oil]. Place #i[chicken] on top of veggies, roast #u[13-16 mins]. Meanwhile, mix #g(3) to create sauce for serving\*.

      Leaving chicken in oven, turn on broil. Cook till veggies are tender with some charring and chicken is cooked through and well-browned, #u[9-12 mins].
      
      Cut chicken into strips, and add #u[2 Tbsp] #i[rice vinegar] to veggies if desired. Top rice with veggies, chicken, \*prepared sauce, and sesame seeds.
    ],
  ),
  recipe(
    "main",
    "garlic coconut shrimp",
    is-gf: true,
    image-path: "imgs/garlic-coconut-shrimp.png",
    adapted-from: "Sep 24 p18",
    (
      ([1 lb], [shrimp]),
      ([1 cup], [dry rice], [cooked]),
      1,
      ([1 tsp], [turmeric]),
      ([#half tsp], [salt#mult]),
      2,
      ([6], [garlic cloves], [chopped]),
      ([#frac(1,4) cup], [olive oil]),
      none,
      ([#half cup], [unsweetened coconut flakes]),
      3,
      ([#half tsp], [salt#mult]),
      ([1 tsp], [sugar]),
      4,
      ([#half lb], [green beans]),
      ([#half Tbsp], [pepper flakes]),
      none,
      ([2 Tbsp], [rice vinegar]),
      ([#half], [red onion]),
    ),
    [
      Prepare #i[shrimp], removing tails unlike the barbarians that took the included picture. Pat dry and toss with #g(1). Set aside.

      Cook #g(2) in pan #u[\~4 mins], until garlic is golden. Add #i[coconut], cook #u[\~2 mins]. Strain, separating oil and coconut. Add #g(3) to coconut.

      Heat separated oil in large skillet at #u[medium]. Cook #g(4) with #i[shrimp] #u[\~2 mins]. Add #i[vinegar] and #u[3 Tbsp] water. Cook #u[\~2 mins], till shrimp done.

      Top #i[rice] with #i[shrimp] and #i[green beans], #i[onion], and #i[coconut].
    ],
  ),
  recipe(
    "main",
    "pho",
    image-path: "imgs/pho.png",
    adapted-from: "Feb 25 p24",
    (
      ([8 oz], [thin rice noodles], [soaked in water to soften, drained]),
      ([1 Tbsp], [veggie oil]),
      ([1], [yellow onion], [thinly sliced]),
      ([1 lb], [ground beef]),
      ([#half tsp], [salt]),
      ([2 tsp], [Chinese five-spice powder]),
      1,
      ([5], [garlic cloves], [grated]),
      ([2"], [ginger], [grated]),
      ([1 Tbsp], [fish sauce]),
      none,
      ([32 oz], [low-sodium chicken broth]),
      2,
      ([1], [bean sprout package]),
      ([1], [cilantro bunch]),
      ([2], [jalapeño], [sliced]),
      ([], [hoisin sauce]),
      ([], [sriracha]),
      ([], [lime]),
    ),
    [
      Heat #u[1 Tbsp] cooking oil in Dutch oven at #u[medium-high]. Cook #i[onion] until it starts to soften, #u[2 mins]. Add #i[beef] and #i[salt] and cook until beef is partially browned, #u[2 mins]. Add #i[five-spice powder] and some #i[pepper], cook until beef is just cooked through, #i[3 mins]. Pour off and discard excess fat.

      Add #g(1), cook #u[\~1 min]. Add #i[broth] and #u[4 cup] #i[water]. Increase heat to #u[high], bring to a boil. Add #i[noodles] until tender (might refer to package instructions). 
      
      Serve with items from #g(2).
    ],
  ),
  recipe(
    "main",
    "pork and tomatillo udon",
    image-path: "imgs/pork-and-tomatillo-udon.png",
    adapted-from: "Feb 25 p84",
    (
      ([1 lb], [ground pork]),
      ([#half], [cabbage head], [cut into strips]),
      ([1 lb], [cooked udon], [prepared per package instructions]),
      1,
      ([3 Tbsp], [hoisin sauce]),
      ([1#frac(1,4) cup], [tomatillo salsa]),
      ([2 Tbsp], [butter]),
      none,
      ([#frac(2,3) cup], [chopped cilantro]),
      ([1], [radish], [thinly sliced]),
    ),
    [
      Heat #u[1 Tbsp] #i[cooking oil] over #u[medium high] in large skillet.
      
      Add #i[pork] and #i[cabbage] and cover. Cook, stirring occasionally, until few pink spots remain in pork and cabbage has softened, #u[\~10 mins].
      
      Add #g(1), cook until warmed and well-mixed, #u[3 mins].

      Remove from heat and mix in #i[cilantro]. Decorate with #i[radish].
    ],
  ),
  recipe(
    "main",
    "baked pasta and sausage",
    adapted-from: "Feb 25 p48",
    image-path: "imgs/baked-pasta-with-sausage.png",
    (
      ([12 oz], [spicy sausage], [cooked or uncooked]),
      1,
      ([10], [garlic cloves], [finely grated]),
      ([4], [large basil sprigs], [chopped]),
      ([56 oz], [canned crushed tomatoes]),
      ([#half cup], [butter], [cut into pieces]),
      ([#half Tbsp], [salt]),
      ([1 tsp], [sugar]),
      ([1 tsp], [red pepper flakes]),
      none,
      ([1 lb], [pasta], [like rigatoni]),
      ([1 lb], [low-moisture mozzarella], [coarsely grated])
    ),
    [
      Prepare oven: middle rack, #u[350°F]. In a 9$times$13" pan, combine #g(1) and bake uncovered for #u[45 mins]. If #i[sausage] is uncooked, add now, otherwise add after #u[30 mins].

      Add #i[pasta], uncooked, with #u[1 cup] #i[water]. Lightly mix contents. Cover pan tightly with foil. Bake #u[23-27 mins].

      Remove pan from oven, turn oven to broil. Remove foil, lightly mix contents. Top pasta with #i[mozzarella] and broil until cheese is golden brown in spots, #u[5-8 mins]. Keep a close eye as it can turn quickly.
    ],
  ),
  recipe(
    "main",
    "baked sweet potato chaat",
    adapted-from: "Nov 24 p14",
    image-path: "imgs/sweet-potato-chaat.png",
    is-vegetarian: true,
    (
      ([2-3 lb], [sweet potatoes]),
      1,
      ([1 lb], [dry chickpeas], [soaked, cooked, and patted dry]),
      ([1#half Tbsp], [cumin]),
      ([1#half Tbsp], [chaat masala]),
      ([#frac(1,4) cup], [olive oil#mult]),
      2,
      ([1], [cilantro bunch]),
      ([2], [jalapeño], [stem cut off]),
      ([4-6], [green onions]),
      ([#frac(1,4) cup], [lime juice]),
      ([#frac(1,4) cup], [olive oil#mult]),
      3,
      ([1-2], [serves fried onion], [_(see pg. #context locate(label("fried onions")).page())_]),
      ([], [plain whole milk yogurt], [or sour cream]),
      ([1], [red onion], [finely chopped]),
      ([1], [pomegranate], [for seeds])

    ),
    [
      Preheat oven to #u[450°F]. Cut #i[potatoes] in half if large. Prick all over with a fork. Run under water to dampen skin. Place on rimmed baking sheet with parchment paper. Drizzle olive oil and sprinkle salt, spread with hands to coat. Roast #u[30-35 mins].

      In a bowl, mix #g(1). Add to potato sheet. Cook all for another #u[15-20 mins].

      In a food processor, blend #g(2) till well mixed, but not puréed.

      Serve in bowls by mixing and lightly mashing potatoes and chickpeas (or do it like the picture, I'm not your mom), then topping with blended sauce and elements of #g(3).
    ],
  ),
  recipe(
    "main",
    "miso-tahini & tofu grain bowls",
    adapted-from: "Apr 25 p20",
    image-path: "imgs/tofu-grain-bowl.png",
    is-vegan: true,
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
      ([#frac(3,4) tsp], [turmeric]),
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
    "french onion pasta",
    adapted-from: "Apr 25 p18",
    is-vegetarian: true,
    image-path: "imgs/french-onion-pasta.png",
    (
      1,
      ([4], [yellow onions], [thinly sliced]),
      ([1 tsp], [salt]),
      ([1 tsp], [pepper]),
      2,
      ([6], [garlic cloves]),
      ([4 tsp], [chopped thyme]),
      none,
      ([#frac(3,4) cup], [dry white wine]),
      ([1 lb], [shell pasta], [like lumache]),
      3,
      ([2 oz], [Parmesan], [finely grated]),
      ([3 Tbsp], [butter]),
      ([1 Tbsp], [Dijon mustard]),
      ([2 tsp], [sugar]),
      ([2 tsp], [Worcesterchire sauce]),
      none,
      ([8-12 oz], [Gruyère or White Cheddar], [coarsely grated]),
    ),
    [
      Heat #u[3 Tbsp] #i[olive oil] in Dutch oven over #u[medium-high]. Add #g(1) and cook, stirring occasionally and adding #u[1 Tbsp] #i[water] at a time if onions are sticking and burning. Continue until onions are deep brown and jammy, #u[30-35 mins].

      Add #g(2) to pan, stirring often, cooking #u[1 min]. Add #i[wine] and cook, stirring occasionally, until reduced by half, #u[\~3 mins]. Add #u[5#half cup] #i[water] and bring to a simmer. Add #i[pasta] and cook, stirring often to prevent pasta from sticking, until pasta is al dente, almost all liquid is absorbed besides a thick sauce, #u[10-14 mins].

      Remove pan from heat and add #g(3), stirring until Parmesan is melted.

      Place rack in upper third of oven and turn on broil. Scatter #i[cheese] over pasta and broil until melted and golden brown, #u[2-5 mins], watching closely. Add #i[chives] for serving if desired.
    ],
  ),
  recipe(
    "main",
    "salmon and shiitake rice",
    image-path: "imgs/salmon-shiitake-rice.png",
    adapted-from: "Aug 24 p14",
    (
      1,
      ([1#half cup], [dry white or brown rice], [rinsed until water runs clear]),
      ([#frac(1,3) cup], [quinoa]),
      ([1 Tbsp], [sake]),
      ([2 tsp], [soy sauce#mult]),
      none,
      ([5 oz], [shiitake mushrooms], [thinly sliced]),
      ([1 lb], [skinless salmon fillets]),
      2,
      ([4 Tbsp], [rice vinegar]),
      ([2 Tbsp], [sesame oil], [(preferrably toasted)]),
      ([5 Tbsp], [soy sauce#mult]),
      ([5], [green onions], [sliced])
    ),
    [
      Gently stir #g(1) and #u[2 cups] #i[water] in a large pot with a lid. Gently place #i[mushrooms] then #i[salmon] in respective layers on top of rice. Lightly season with salt. Put pot over #u[medium-high], lid askew, until small bubbles start to form, then reduce to #u[medium] and cover tightly with lid. Cook undisturbed for #u[15 mins], then move off heat (do not remove lid) and let sit #u[20 mins].

      Meanwhile, mix #g(2) to make a sauce.

      Uncover rice lid, letting water from lid drip into pot. Gently fold contents, breaking up salmon. Transfer into bowls and serve with sauce.
    ],
  ),
  recipe(
    "main",
    "samosa-dilla",
    is-vegetarian: true,
    image-path: "imgs/samosa-dilla.png",
    adapted-from: "Aug 24 p18",
    (
      ([3 Tbsp], [veggie oil]),
      1,
      ([1 tsp], [cumin seeds], [or half as much powder]),
      ([1 Tbsp], [curry powder]),
      ([#half Tbsp], [ground ginger]),
      ([2], [garlic cloves], [minced]),
      2,
      ([1], [small red onion], [diced]),
      ([1], [jalapeño], [diced]),
      none,
      ([1 lb], [russet or golden potatoes], [peeled, cut into #half-in pieces]),
      3,
      ([1 cup], [cilantro], [leaves and soft stems only, coarsely chopped]),
      ([1 cup], [frozen peas], [thawed a bit]),
      ([1 Tbsp], [lime juice]),
      none,
      ([4], [8"-10" wheat tortillas]),
      ([8 oz], [sharp white cheddar], [or pepper jack]),
    ),
    [
      Add #i[veggie oil] to large pot with a lid over #u[medium] heat. Add #g(1) and stir about #u[1 min].

      Add #g(2) and cook until onion is softened, #u[\~3 mins]. Add #i[potatoes] and #u[2#half cups] #i[water], bring to a simmer and cover. Continue until water is mostly absorbed by potatoes, #u[20-25 mins].

      Remove from heat and stir in #g(3).

      Cover half of each #i[tortilla] in #i[cheese], add a layer of filling, and another layer of cheese. Fold the tortilla over. Fry at #u[low-medium] heat on both sides with a thin layer of oil in pan until golden.
    ],
  ),
  recipe(
    "main",
    "gado gado",
    is-vegetarian: true,
    image-path: "imgs/gado-gado.jpg",
    adapted-from: "Apr 24",
    (
      ([14 oz], [extra-firm tofu], [pressed, cut into #half-in cubes, patted dry]),
      ([16 oz], [white rice noodles], [wide like linguine]),
      1,
      ([#frac(3,4) cup], [creamy peanut butter]),
      ([3 Tbsp], [lime juice]),
      ([1#half Tbsp], [garlic chili sauce]),
      ([3], [cloves garlic], [finely chopped]),
      ([#half cup], [water]),
      2,
      ([#frac(3,4) cup], [brown sugar]),
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
  recipe(
    "main",
    "green chutney chicken",
    adapted-from: "Oct 25 p22",
    image-path: "imgs/green-chicken-chutney.png",
    (
      1,
      ([1], [cilantro bunch], [(medium size) coarsely chopped with stems]),
      ([4], [garlic cloves]),
      ([1], [jalapeño], [stem removed]),
      ([#half cup], [mint leaves], [when tightly packed]),
      ([#frac(1,4) cup], [sour cream]),
      ([2 Tbsp], [yellow mustard]),
      ([1 tsp], [ground cardamom]),
      ([3 Tbsp], [olive oil]),
      ([2 tsp], [salt]),
      none,
      ([\~2 lb], [chicken thighs], [(boneless) cut into 2" pieces])
    ),
    [
      Purée #g(1) in food processor. Use rubber spatula to make sure sauce is very well blended, until smooth and bright green. Transfer to bowl.

      Add #i[chicken] to bowl. Toss to coat. Allow to sit for at least #u[15 min] at room temperature (or overnight in the fridge).

      Set oven to broil, with rack in top slot. Place chicken on tinfoil-lined sheet. Remove when browned and cooked to temperature.
    ],
  ),
  recipe(
    "main",
    "miso-marinated salmon",
    (
      ([1 lb], [salmon filet]),
      1,
      ([#frac(1,3) cup], [sake]),
      ([#frac(1,3) cup], [mirin]),
      ([#frac(1,3) cup], [white miso]),
      ([3 Tbsp], [sugar]),
      ([1 tsp], [salt]),
      2,
      ([1 cup], [dried rice], [cooked]),
      ([3 Tbsp], [rice vinegar]),
      ([3 g], [dried seaweed], [like seasoned laver, crushed])
    ),
    [
      Combine #g(1) to create a marinade. Reserve some for serving. Marinade #i[salmon] #u[1-2 days] in fridge.

      Scrape the marinade off the salmon to discard. Broil the salmon filets on low-middle rack, cooking #u[8 mins] until tops are slightly charred.
      
      Combine #g(2). Serve with salmon and reserved marinade.
    ],
  ),
  recipe(
    "main",
    "gnocchi",
    adapted-from: "ANTI-CHEF on YouTube",
    bon-appetit: false,
    (
      ([1.5 lb], [plum tomatoes]),
      ([1], [yellow onion], [skinned, cut in half]),
      ([4 Tbsp], [butter]),
      none,
      ([4], [golden potatoes], [skinned, coursely diced]),
      ([2 cup], [flour]),
      none,
      ([1 oz], [Parmesan], [grated])
    ),
    [
      Place #i[tomatoes] in boiling water for #u[1 min]. Remove tomato skin once the tomatoes are handleable. Rinse in cold water. Cut lengthwise and remove stems. Cook in covered saucepan for #u[10 mins] over #u[medium] heat. Blend the tomatoes, then add #i[onion] and #i[butter]. Cook uncovered on a slow but steady simmer until reduced, #u[45-90 mins]. Add #i[salt] to taste.

      Meanwhile, boil diced #i[potatoes] until tender and mashable to avoid chunks. Strain potatoes and puree. Add #i[flour] to pureed potato a bit at a time until the dough is soft, smooth and light in color. The exact amount of flour added will differ based on potato size. Roll dough to #u[\~#half-in] cylinders. Cut desired size to make individual gnoccho. I don't care about making them look pretty, figure it out yourself if you do.

      Generously salt water in a large pot and bring to a light boil. Add gnocchi, only enough to cover the bottom of the pot in a single layer at a time. Allow each gnoccho to float to the top and stay there for #u[\~10 secs] before removing.

      Soon after removing, add sauce to gnocchi to avoid sticking. Serve with #i[Parmesan].
    ],
  ),
  recipe(
    "main",
    "pork and shrimp cabbage rolls",
    adapted-from: "Mar 25 p75",
    (
      ([1], [large cabbage head]),
      1,
      ([5-8], [green onions], [finely chopped]),
      ([6], [garlic cloves], [finely chopped]),
      ([3"], [ginger], [finely chopped]),
      ([1 lb], [ground pork]),
      ([1 lb], [shrimp], [prepared and chopped]),
      ([3 Tbsp], [soy sauce]),
      ([#frac(3,2) tsp], [salt]),
      ([1 Tbsp], [sugar]),
      ([1 Tbsp], [toasted sesame oil]),
      2,
      ([2 tsp], [ginger powder]),
      ([2 tsp], [garlic powder]),
      ([#frac(1,4) cup], [soy sauce]),
      ([#frac(1,4) cup], [rice vinegar]),
      ([1 Tbsp], [sugar]),
      ([#frac(1,2) tsp], [toasted sesame oil]),
      
    ),
    [
      Fill a pot large and deep enough for the #i[cabbage] halfway full with water. Bring to a boil. Cut a cone shape out of the bottom of the cabbage to remove much of the stem. Set the cabbage stem-down into the water. Boil, covered, for #u[10 mins] to soften leaves.

      Mix #g(1). Scoop this filling into softened cabbage leaves once they can be handled. Use a toothpick to hold rolls together when necessary.

      Steam rolls, in batches if necessary, for #u[11-13 mins]. Mix #g(2) to make sauce and serve.
    ],
  ),
  // recipe(
  //   "main",
  //   "title",
  //   adapted-from: "Apr 25 p18",
  //   (
  //     ([1 lb], [ground pork], [wow]),
  //   ),
  //   [
  //     description
  //   ],
  // ),
  recipe(
    "treat",
    "earl grey sugar cookies",
    is-vegetarian: true,
    image-path: "imgs/earl-grey-cookies.png",
    image-above: true,
    (
      1,
      ([#half cup], [butter], [melted]),
      ([2 Tbsp], [earl grey tea leaves], [chopped if neccessary]),
      2,
      ([#half cup], [sugar], [(plus more for rolling)]),
      ([#frac(1,4) cup], [brown sugar]),
      ([1], [egg]),
      ([1 Tbsp], [vanilla]),
      4,
      ([1#half cup], [flour]),
      ([#half tsp], [baking powder]),
      ([#half tsp], [baking soda]),
      ([#half tsp], [salt]),
    ),
    [
      Mix #g(1). Add #g(2), mixing until smooth. Add dries #gg(3) and mix until no dry spots remain. Refrigerate dough for at least #u[30 mins] to solidify butter.

      Preheat oven to #u[325°F]. Roll balls of dough in sugar. Place on sheet with parchment paper. Cookies will spread, leave room between them. Cook #u[12-15 mins], until edges are darkened and set. Allow to sheet cool before serving.
    ],
  ),
  recipe(
    "treat",
    "applesauce cookies",
    image-path: "imgs/applesauce-cookies.png",
    image-below: true,
    is-vegetarian: true,
    (
      1,
      ([1 cup], [sugar]),
      ([1/2 cup], [shortening]),
      ([2], [eggs]),
      1,
      ([1 tsp], [baking soda]),
      ([1 cup], [applesauce]),
      3,
      ([2 3/4 cups], [flour]),
      ([3/4 tsp], [cinnamon]),
      ([3/4 tsp], [nutmeg]),
      ([1/2 tsp], [salt]),
      none,
      ([7 oz],[chocolate chips]),
    ),
    [
      Preheat oven to #u[400˚F].

      Combine #g(1), stir until well-mixed. Combine #g(2) in its own bowl to mix, then add to first mixture. Add #g(3) and mix. The dough will be thick but mixable with a spoon. Fold in #i[chocolate chips].

      Add dough to cookie sheet with parchment paper. Cook #u[9-12 mins].
    ],
  ),
  // recipe(
  //   "treat",
  //   "title",
  //   adapted-from: "May 25 p38",
  //   (
  //     ([1 lb], [ground pork], [wow]),
  //   ),
  //   [
  //     description
  //   ],
  // ),
)

#for i in recipe-types.map(recipe-type => [
  = #recipe-type;s
  #for j in all-recipes.filter(recipe => recipe.recipe-type == recipe-type) {j.content}
]) { i }

#box()<end>

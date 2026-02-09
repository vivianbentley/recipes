// general set rules
#set text(font: "libertinus serif")
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
#let recipe-types = ("outline", "breakfast", "side", "main", "treat", "bread")
#let recipe-type-symbols = (
  "icons/hat.svg",
  "icons/shakers.svg",
  "icons/pin.svg",
  "icons/dish.svg",
  "icons/toaster.svg",
  "icons/bread.svg",
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
  // recipe(
  //   "side",
  //   "sushi rice",
  //   is-gf: true,
  //   is-colbreak: false,
  //   (
  //     ([2 cup], [dry white rice]),
  //     ([3 cup], [water]),
  //     2,
  //     ([#half cup], [rice vinegar]),
  //     ([1 Tbsp], [cooking oil]),
  //     ([#frac(1, 4) cup], [white sugar]),
  //     ([1 tsp], [salt]),
  //   ),
  //   [
  //     Rinse #i[rice] under cold water in colander until it runs clear. Add to pan with #i[water], set to #u[medium-high]. Bring to boil, then reduce heat to #u[low]. Cover until water is absorbed, #u[\~20 mins].
  //     Add #g(1) to sauce pan over #u[medium] heat until sugar dissolved. Add to cooked rice, mix until liquid is absorbed.
  //   ],
  // ),
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
  // recipe(
  //   "side",
  //   "boullion-baked tofu",
  //   is-nf: true,
  //   is-gf: true,
  //   image-path: "imgs/bouillon-baked-tofu.png",
  //   image-above: true,
  //   adapted-from: "Nov 24 p32",
  //   (
  //     ([1], [firm tofu package], [(\~14oz) pressed, cubed, patted dry]),
  //     1,
  //     ([2 tsp], [vegetable boullion paste]),
  //     ([#half tsp], [pepper]),
  //     ([#half tsp], [garlic powder]),
  //     ([#half tsp], [sugar]),
  //     ([2 Tbsp], [olive oil]),
  //     none,
  //     ([1 Tbsp], [corn starch]),
  //   ),
  //   [
  //     Mix #g(1) and toss with #i[tofu]. Cover and let sit at least #u[15 mins]. Prepare oven (middle rack, #u[400°F]). Lightly oil parchment paper on rimmed baking sheet.
  //     Uncover #i[tofu] and sprinkle on #i[corn starch]. Toss to coat. Arrange tofu on prepared sheet, not touching each other. Bake until golden brown and crispy, #u[30-35 mins].
  //   ],
  // ),
  // recipe(
  //   "main",
  //   "miso-tahini & tofu grain bowls",
  //   adapted-from: "Apr 25 p20",
  //   image-path: "imgs/tofu-grain-bowl.png",
  //   (
  //     ([1], [firm tofu package], [(\~14oz) pressed, cubed, patted dry]),
  //     1,
  //     ([1#half cup], [dry brown rice], [rinsed until water runs clear]),
  //     ([#half cup], [dry quinoa]),
  //     2,
  //     ([8 oz], [red cabbage], [thinly sliced]),
  //     ([3 Tbsp], [rice vinegar#mult]),
  //     ([2 tsp], [honey#mult]),
  //     ([#half tsp], [salt]),
  //     none,
  //     ([1 Tbsp], [soy sauce]),
  //     3,
  //     ([2], [broccoli bunches], [cut into florets with long stems]),
  //     ([1 tsp], [red pepper flakes]),
  //     4,
  //     ([3 cup], [miso]),
  //     ([2 Tbsp], [tahini]),
  //     ([#frac(3, 4) tsp], [turmeric]),
  //     ([2 tsp], [honey#mult]),
  //     ([2 Tbsp], [rice vinegar#mult]),
  //     none,
  //     ([1], [avocado], [thinly sliced]),
  //   ),
  //   [
  //     Preheat oven to #u[450°F]. Bring grains #gg(1) and #u[2#half cup] #i[water] to a boil in medium saucepan. Cover tightly with lid, reduce heat to #u[low]. Cook until grains are tender and liquid is absorbed, #u[40 mins]. Meanwhile, combine #g(2) in large bowl and vigorously massage with hands. Set aside for serving.
  //     Arrange #i[tofu] on rimmed baking sheet, drizzle with #i[soy sauce] and #u[3 Tbsp] #i[olive oil]. Roast until lightly browned, #u[9-11 mins]. Combine #g(3) and roast alongside tofu until starting to char, #u[15-20 mins].
  //     Whisk #g(4) to make sauce for serving.
  //     Assemble bowls with components and serve.
  //   ],
  // ),
  recipe(
    "main",
    "Gado Gado",
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
  //     is-gf: true,
  // is-nf: true,
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
  recipe(
    "side",
    "Black Bean Salad",
    image-path: "imgs/blackbeansalad.jpg",
    is-gf: true,
    is-nf: true,
    adapted-from: "Mystery Magazine",
    (
      ([¾ cup], [olive oil]),
      ([2 teaspoons], [maple syrup]),
      ([juice of 3], [limes]),
      ([2 cans (15-ounce)], [black beans], [rinsed and drained]),
      ([1 can], [corn]),
      ([1], [bell pepper], [diced]),
      ([1 bunch], [scallions], [chopped]),
      ([½ cup], [fresh cilantro], [chopped]),
      ([to taste], [salt]),
      ([to taste], [pepper]),
      ([1], [avocado], [diced]),
      ([as needed], [tortilla chips]),
    ),
    [In a small bowl, whisk together the olive oil, maple syrup, and lime juice.
      Add the black beans, corn, bell pepper, scallions, and cilantro and toss to combine
      Season with salt and pepper to taste.
      Gently fold in the diced avocado just before serving.
      Serve chilled or at room temperature with tortilla chips

      description
    ],
  ),
  recipe(
    "main",
    "Rajma",
    is-gf: true,
    is-nf: true,
    image-path: "imgs/rajma.jpg",
    adapted-from: "The Recipe Hut",
    (
      1,
      ([2–3 tablespoons], [olive oil]),
      ([1 teaspoon], [cumin seeds]),
      ([2–3], [cloves]),
      ([7–8], [black peppercorns]),
      ([1 large], [cardamom pod]),
      ([2], [bay leaves]),
      ([1 large], [onion], [finely chopped]),
      ([pinch], [salt]),
      ([1 tablespoon], [fresh ginger], [grated]),
      ([1 tablespoon], [garlic], [minced]),
      ([3 medium], [tomatoes], [pureed]),
      ([1/4 teaspoon], [turmeric powder]),
      ([to taste], [salt]),
      ([2 heaped teaspoons], [coriander powder]),
      ([1 teaspoon], [roasted cumin powder]),
      ([1/2 teaspoon], [red chili powder]),
      ([1 cup], [dried kidney beans], [washed]),
      ([4 cups], [water]),
      ([1 teaspoon], [dried fenugreek leaves]),
      ([2–3], [green chilies]),
      ([as needed], [fresh cilantro], [chopped]),
      ([1/2 teaspoon], [garam masala]),
      2,
      ([1 1/2 cups], [basmati rice], [washed and soaked]),
      ([1 teaspoon], [cumin seeds]),
      ([1 1/2 cups], [water]),
      ([1 teaspoon], [salt]),
      ([1 1/2 teaspoons], [vegetable oil]),
    ),
    [Sauté the Spices:
      Heat 2-3 tbsp olive oil in a pot. Add 1 tsp cumin seeds and let it splutter.
      Add 2-3 cloves, 7-8 peppercorns, 1 cardamom pod, and 2 bay leaves. Sauté for 1 minute.
      Add 1 finely chopped onion and cook for 2-3 minutes until translucent, adding a pinch of salt.
      Add 1 tbsp grated ginger and 1 tbsp minced garlic. Cook for 2-3 minutes until fragrant.
      Add 3 pureed tomatoes and cook for 10 minutes until the oil separates from the masala.
      Stir in 1/4 tsp turmeric, salt to taste, 2 tsp coriander powder, 1 tsp roasted cumin powder, and 1/2 tsp red chili powder. Cook for 1 minute.
      Add 3 cans of rinsed red kidney beans and 3 cups of water. Stir well.
      Leave uncovered and cook for 25 minutes or until the beans have softened and absorbed the flavors.
      While the rajma is cooking start the rice. Rinse rice 3 times, then add water, salt, oil, and cumin seeds.
      After cooking, taste the rajma and adjust salt and spices as needed.
      Add 1 tsp kasoori methi, 2-3 whole green chilies, and fresh cilantro to the rajma. Cook an additional 2-3 minutes
      Stir in 1/2 tsp garam masala and additional cilantro. Serve hot with rice.
      description
    ],
    image-above: true,
  ),
  recipe(
    "main",
    "White Bean Chili",
    image-path: "imgs/whitebeanchili.jpg",
    image-above: true,
    is-gf: true,
    is-nf: true,
    adapted-from: "Aunty and Uncle family recipe",
    (
      ([3 tablespoons], [avocado oil]),
      ([2 cups], [yellow onion], [diced]),
      ([3 cloves], [garlic], [minced]),
      ([1 lb], [ground Impossible meat]),
      ([2 teaspoons], [salt]),
      ([1 teaspoon], [black pepper]),
      ([2 teaspoons], [ground cumin]),
      ([1 1/2 teaspoons], [dried oregano]),
      ([1 teaspoon], [ground coriander]),
      ([1 1/2 teaspoons], [chili powder]),
      ([1/2 teaspoon], [cayenne pepper]),
      ([2–4 ounces], [green chilies], [diced, undrained]),
      ([3 cans], [white beans], [undrained]),
      ([2 cups], [vegetable broth]),
      ([2], [bay leaves]),
    ),
    [ In a large pot, heat 3 tbsp avocado oil over medium heat.
      Add 2 cups diced yellow onion and 3 cloves minced garlic. Sauté for about 5 minutes until the onions are softened.
      Add 1 lb ground impossible meat to the pot. Season with 2 tsp salt and 1 tsp black pepper. Cook until the impossible meat is browned and fully cooked.
      Stir in 2 tsp cumin, 1½ tsp oregano, 1 tsp coriander, 1½ tsp chili powder, and ½ tsp cayenne pepper. Cook for 1-2 minutes until the spices become fragrant.
      Add 2-4 oz diced green chilies (undrained), 2 cans of white beans (undrained), 2 cups veggie broth, and 2 bay leaves. Stir everything together.
      In a blender or food processor, blend 1 can of white beans into a smooth puree. Add this puree to the pot and stir well.
      Bring the mixture to a boil, then reduce the heat to a simmer. Let it cook for about 30-40 minutes, stirring occasionally, to allow the flavors to meld and the chili to thicken.
      Remove the bay leaves. Serve the chili hot with sourdough bread, sour cream, cheese, and any other desired toppings.
      description
    ],
  ),
  recipe(
    "side",
    "Cauliflower Soup",
    is-gf: true,
    is-nf: true,
    image-path: "imgs/Vegan-Cauliflower-Soup-7.jpg",
    adapted-from: link("https://happykitchen.rocks/silky-vegan-cauliflower-soup/")[Happy Kitchen],
    (
      ([1 head], [cauliflower]),
      ([1 tablespoon], [olive oil]),
      ([2 cloves], [garlic], [minced]),
      ([2+2 sprigs], [thyme]),
      ([1 #frac(1, 2) cups], [vegetable stock]),
      ([1 can], [light coconut milk]),
      ([to taste], [salt]),
      ([to taste], [freshly ground black pepper]),
      ([4 tablespoons], [pomegranate seeds], [to garnish]),
    ),
    [Divide the cauliflower head into florets or roughly chop it.
      Sauté 2 cloves minced garlic in 1 tablespoon olive oil in a large skillet until fragrant, for about 2 minutes. Add 1 1/2 cups vegetable stock, 2 thyme sprigs and cauliflower florets. Bring to a boil, cover, reduce the heat and cook for 15-20 minutes, until the cauliflower is nice and soft.
      Discard the thyme and blend until smooth, using a blender.
      Add 1/2 cup light coconut milk and season with salt and freshly ground black pepper to taste. Garnish with 4 tablespoons pomegranate seeds and 2 sprigs fresh thyme.
      description
    ],
  ),
  //
  recipe(
    "main",
    "Spicy Crunchy Tofu",
    is-gf: true,
    is-nf: true,
    image-path: "imgs/spicycrunchytofu.jpg",
    adapted-from: link(
      "https://thekoreanvegan.com/spicy-crunchy-garlic-tofu-kkampoong-tofu/",
    )[The Korean Vegan Cookbook],
    (
      1,
      ([1 block], [firm tofu], [drained and cut into cubes]),
      ([3 tablespoons], [potato starch]),
      ([1/2 teaspoon], [salt]),
      ([1/4 teaspoon], [black pepper]),
      ([1/2 teaspoon], [onion powder]),
      ([1/2 teaspoon], [garlic powder]),
      ([for frying], [vegetable oil]),
      2,
      ([2 tablespoons], [brown rice syrup]),
      ([2 tablespoons], [water]),
      ([2 tablespoons], [soy sauce]),
      ([1 tablespoon], [vinegar], [rice or white]),
      ([1 teaspoon], [potato starch]),
      ([1 teaspoon], [gochujang]),
      ([1/4 teaspoon], [black pepper]),
      3,
      ([1/2], [red onion], [finely diced]),
      ([1 bunch], [celery], [chopped]),
      ([1 cup], [dried Szechuan red peppercorns]),
      ([2], [scallions], [chopped]),
      ([for stir-frying], [olive oil]),
    ),
    [In a large bowl, mix together 3 tbsp potato starch, 1/2 tsp salt, 1/4 tsp black pepper, 1/2 tsp onion powder, and 1/2 tsp garlic powder.
      Add the tofu cubes to the bowl and toss to coat evenly with the potato starch mixture.
      Heat enough vegetable oil in a large nonstick skillet over medium-high heat to generously coat the surface.
      Once the oil is hot and shimmering, add the tofu cubes in a single layer, making sure they don’t touch each other (you may need to work in batches).
      Cook the tofu for about 3 minutes on one side until it browns, then flip and cook for another 3 minutes on the other side.
      While that tofu is frying is a great time to start cooking the rice.
      Once browned, transfer the tofu to a wire rack to drain excess oil.
      In a small bowl, whisk together 2 tbsp brown rice syrup, 2 tbsp water, 2 tbsp soy sauce, 1 tbsp vinegar, 1 tsp potato starch, 1 tsp gochugaru, and 1/4 tsp black pepper.
      In a large wok or skillet, heat olive oil over medium-high heat.
      Add 1/2 diced red onion, chopped celery and 1 cup dried Szechuan red chilies. Sauté for about 3 minutes until the onion softens.
      Pour the prepared sauce into the wok with the sautéed vegetables and cook for about 1 minute, stirring until the sauce thickens.
      Remove from heat and gently stir in the fried tofu, making sure each piece is coated with the sauce.
      Garnish with chopped scallions.
      Serve immediately while the tofu is crispy.
      description
    ],
  ),
  recipe(
    "main",
    "Butter Chick'n",
    is-gf: true,
    is-nf: true,
    image-path: "imgs/butterchicken.jpg",
    adapted-from: link("https://www.noracooks.com/vegan-butter-chicken/")[Nora Cooks],

    (
      1,
      ([2 blocks], [extra-firm tofu], [(16 oz each)]),
      ([2 tablespoons], [olive oil]),
      ([2 tablespoons], [potato starch]),
      ([1/2 teaspoon], [salt]),
      2,
      ([2 tablespoons], [vegan butter], [or olive oil]),
      ([1 large], [onion], [diced small]),
      ([1 tablespoon], [fresh ginger], [grated], [or 1 teaspoon dried]),
      ([2 cloves], [garlic], [minced]),
      ([1 tablespoon], [garam masala]),
      ([1 teaspoon], [curry powder]),
      ([1 teaspoon], [ground coriander]),
      ([#frac(1, 4) teaspoon], [cayenne pepper]),
      ([1 teaspoon], [salt]),
      ([3 ounces], [tomato paste]),
      ([1 can], [full fat coconut milk]),
      3,
      ([4 cups], [cooked rice], [white or brown]),
      ([to taste], [cilantro], [chopped]),
    ),
    [Press the tofu. We use a tofu press (one of our most used kitchen gizmos) but you can make a homemade press by placing a heavy pan on top of the tofu with something underneath to soak up the water.
      Preheat the oven to 400 degrees F and line a baking sheet with parchment paper.
      Slice the tofu into about 6 slices. Now, rip each slice into medium-large pieces. Ripping gives the tofu a great texture for this dish.
      Add the tofu pieces to a large bowl along with the olive oil, potato starch and salt. Stir gently to coat. Arrange the tofu evenly on the prepared pan, and bake for 25-30 minutes, until golden and crispy.
      While the tofu bakes, start the rice cooker.
      Then prepare the sauce: Melt the 2 tablespoons of vegan butter in a large pan over medium-high heat. Saute the onion for 3-4 minutes in the butter, then add the ginger and garlic and cook for 1 more minute. Add the spices, salt, tomato paste and coconut milk. Stir until smooth and combined, then simmer for 5-10 minutes, stirring frequently.
      When the tofu is done baking, add it to the sauce and stir to coat the pieces. Serve over rice. Garnish with chopped fresh cilantro. Enjoy!
      description
    ],
  ),
  recipe(
    "main",
    "Brocolli Cheddar Orzo",
    is-gf: true,
    is-nf: true,
    image-path: "imgs/vegan-broccoli-cheddar-orzo-2.jpg",
    adapted-from: link("https://naturallieplantbased.com/vegan-broccoli-cheddar-orzo/")[Naturallieplantbased],
    (
      1,
      ([1 tablespoon], [plant-based butter]),
      ([1 medium], [onion], [diced]),
      ([3 cloves], [garlic], [minced]),
      ([#frac(1, 2) cup], [carrots], [shredded]),
      ([#frac(1, 2) teaspoon], [salt]),
      ([#frac(1, 4) teaspoon], [black pepper], [freshly ground]),
      ([#frac(1, 4) teaspoon], [paprika]),
      ([1 cup], [orzo], [uncooked]),
      ([2 cups], [vegetable broth], [low sodium]),
      ([#frac(1, 2) teaspoon], [dijon mustard]),
      ([#frac(1, 2) cup], [non-dairy milk], [unsweetened], [soy or almond]),
      ([2 heaping cups], [broccoli florets], [cut into smaller pieces]),
      ([1 cup], [cheddar], [shredded], [plant-based if vegan]),
      ([#frac(1, 4) cup], [parmesan shreds], [plus more for topping], [plant-based if vegan]),
    ),
    [ In a medium or large pot, begin heating 1 tablespoon vegan butter over medium heat. Add in one diced medium onion and sauté until softened and slightly browned (5-7 minutes).
      Add in 3 cloves minced garlic, 1/2 cup shredded carrots, and salt and spices. Cook for few minutes.
      3 cloves minced garlic, 1/2 cup shredded carrots, 1/2 tsp salt, 1/4 tsp freshly ground black pepper, 1/4 tsp paprika
      Pour in your orzo and vegetable broth. Add in the Dijon mustard. Bring to a boil then lower heat, cover, and simmer for 5 minutes.
      1 cup uncooked orzo, 2 cups vegetable broth, 1/2 tsp Dijon mustard
      Add in the 1/2 cup milk and 2 cups broccoli florets. Stir until combined. Cover for another 4-5 minutes until broccoli is cooked through.
      Stir in the 1 cup vegan cheddar shreds and 1/4 cup parm until it is melty and creamy.
      Enjoy right away. Feel free to sprinkle some freshly ground pepper on top and/or nutritional yeast.
      description
    ],
  ),
  recipe(
    "main",
    "baked sweet potato chaat",
    adapted-from: "Nov 24 p14",
    image-path: "imgs/sweet-potato-chaat.png",
    is-gf: true,
    is-nf: true,
    (
      ([2-3 lb], [sweet potatoes]),
      1,
      ([1 lb], [dry chickpeas], [soaked, cooked, and patted dry]),
      ([1#half Tbsp], [cumin]),
      ([1#half Tbsp], [chaat masala]),
      ([#frac(1, 4) cup], [olive oil#mult]),
      2,
      ([1], [cilantro bunch]),
      ([2], [jalapeño], [stem cut off]),
      ([4-6], [green onions]),
      ([#frac(1, 4) cup], [lime juice]),
      ([#frac(1, 4) cup], [olive oil#mult]),
      3,
      ([1-2], [serves fried onion], [_(see pg. #context locate(label("fried onions")).page())_]),
      ([], [plain vegan yogurt], [or vegan sour cream]),
      ([1], [red onion], [finely chopped]),
      ([1], [pomegranate], [for seeds]),
    ),
    [
      Preheat oven to #u[450°F]. Cut #i[potatoes] in half if large. Prick all over with a fork. Run under water to dampen skin. Place on rimmed baking sheet with parchment paper. Drizzle olive oil and sprinkle salt, spread with hands to coat. Roast #u[30-35 mins].

      In a bowl, mix #g(1). Add to potato sheet. Cook all for another #u[15-20 mins].

      In a food processor, blend #g(2) till well mixed, but not puréed.

      Serve in bowls by mixing and lightly mashing potatoes and chickpeas (or do it like the picture, I'm not your mom), then topping with blended sauce and elements of #g(3).
    ],
  ),
  recipe(
    "bread",
    "Red Bean Bread",
    is-nf: true,
    adapted-from: "The Korean Vegan Cookbook",
    image-path: "imgs/braided red bean bread1.jpg",
    (
      ([1 cup], [warm water], [100–110°F]),
      ([1#half cup], [plant milk], [warmed, 100–110°F]),
      ([2 Tbsp], [plant milk]),
      ([1 Tbsp], [sugar]),
      ([4 tsp], [active dry yeast]),
      ([4 cups], [bread flour]),
      ([#half Tbsp], [salt]),
      ([#frac(1, 3) cup], [extra-virgin olive oil]),
      ([3 cups], [paht], [sweet red bean paste]),
      ([1 Tbsp], [maple syrup]),
      ([], [coarse sea salt], [for sprinkling]),
      ([1 Tbsp], [toasted sesame seeds]),
    ),
    [In a small bowl, mix #u[1 cup] warm water, #u[#half cup] warmed plant milk, #u[2 Tbsp] sugar, and #u[2 tsp] active dry yeast. Set aside #u[10 mins], until foamy.

      In a large bowl, combine #u[4 cups] flour, #u[1 tsp] salt, and #u[2 Tbsp] olive oil. Add yeast mixture and stir with a wooden spoon until a dough forms.

      Turn dough onto a floured surface and knead #u[5 mins] until smooth. Shape into a ball, place in a bowl, cover, and let rise in a warm place #u[1 hour], until doubled in size.

      Preheat oven to #u[400°F]. Line a large baking sheet with parchment paper.

      Punch down dough, knead #u[2 mins], and divide in half. Return one half to the bowl and cover.

      Divide remaining dough into #u[3] equal pieces. Roll each into a #u[10×7-inch] rectangle. Spread #u[#half cup] red bean paste over dough, leaving a #u[#half - inch] border. Roll into a log and pinch edges to seal. Repeat to make three stuffed ropes.

      Place ropes side by side on baking sheet. Pinch tops together, then braid by crossing left over middle, right over middle, repeating to the end. Pinch ends to seal.

      Repeat shaping and braiding with remaining dough to form second loaf.

      In a small bowl, mix #u[2 Tbsp] plant milk with #u[1 Tbsp] maple syrup. Brush over loaves. Sprinkle with sea salt and sesame seeds.

      Bake #u[50 mins], until golden brown. Cool completely before slicing.

      description
    ],
  ),
  recipe(
    "bread",
    "Focacia",
    is-nf: true,
    image-path: "imgs/focaccia.jpg",
    adapted-from: "Bon Appetit",
    (
      ([1 envelope], [active dry yeast], [¼ oz., about 2¼ tsp]),
      ([2 tsp], [maple syrup]),
      ([5 cups], [all-purpose flour], [625 g]),
      ([5 tsp], [Diamond Crystal kosher salt]),
      ([1 Tbsp], [Morton kosher salt]),
      ([6 Tbsp], [extra-virgin olive oil], [divided, plus more for hands]),
      ([4 Tbsp], [unsalted butter], [plus more for pan]),
      ([], [flaky sea salt], [for finishing]),
      ([2–4 cloves], [garlic]),
    ),
    [In a small bowl, mix #u[1 cup] warm water, #u[#half cup] warmed plant milk, #u[2 Tbsp] sugar, and #u[2 tsp] active dry yeast. Set aside #u[10 mins], until foamy.

      In a large bowl, combine #u[4 cups] flour, #u[1 tsp] salt, and #u[2 Tbsp] olive oil. Add yeast mixture and stir with a wooden spoon until a dough forms.

      Turn dough onto a floured surface and knead #u[5 mins] until smooth. Shape into a ball, place in a bowl, cover, and let rise in a warm place #u[1 hour], until doubled in size.

      Preheat oven to #u[400°F]. Line a large baking sheet with parchment paper.

      Punch down dough, knead #u[2 mins], and divide in half. Return one half to the bowl and cover.

      Divide remaining dough into #u[3] equal pieces. Roll each into a #u[10×7-inch] rectangle. Spread #u[#half cup] red bean paste over dough, leaving a #u[#half - inch] border. Roll into a log and pinch edges to seal. Repeat to make three stuffed ropes.

      Place ropes side by side on baking sheet. Pinch tops together, then braid by crossing left over middle, right over middle, repeating to the end. Pinch ends to seal.

      Repeat shaping and braiding with remaining dough to form second loaf.

      In a small bowl, mix #u[2 Tbsp] plant milk with #u[1 Tbsp] maple syrup. Brush over loaves. Sprinkle with sea salt and sesame seeds.

      Bake #u[50 mins], until golden brown. Cool completely before slicing.

      description
    ],
  ),
  recipe(
    "treat",
    "Peanut Butter Bars",
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [Line a standard loaf pan with parchment paper or muffin liners.

      In a medium bowl, mix melted butter, graham crumbs, powdered sugar, and peanut butter until well blended. Press evenly into prepared pan.

      Place chocolate chips and peanut butter in a microwave-safe bowl. Microwave on high, stirring every #u[15 secs], until smooth. Spread evenly over crust.

      Refrigerate #u[1 hour], then cut into #u[8] squares.

      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
  recipe(
    "treat",
    "title",
    is-gf: true,
    is-nf: true,
    adapted-from: "May 25 p38",
    (
      ([1 lb], [tofu], [wow]),
    ),
    [
      description
    ],
  ),
)

#for i in recipe-types.map(recipe-type => [
  = #recipe-type;s
  #for j in all-recipes.filter(recipe => recipe.recipe-type == recipe-type) { j.content }
]) { i }

#box()<end>


// git status
// git commit -asm "Add your commit"
// git push

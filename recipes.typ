// To Do:
// How to optimize so a recipe stays on the same page (images don't get orphaned)
// How to group salads and soups together (or alphabetical sort?)
// Add index by ingredients?
// Add cook time / serving size
// add ella's cookie gun recipe
// Ask miles about how to set ingredients to accept 4 ingredients in a row instead of only 3 for indexing.
// how to add a intro page
// how to have a 'mobile version'

#import "@preview/in-dexter:0.7.2": *


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
#let gg(num, p: true) = [#if p [(];group *#text(group-divide-color, numbering(group-num, num))*#if p [)]]
#let g(num) = gg(num, p: false)
#let status(txt, supp: "") = text(luma(70%))[#v(0cm) #align(right)[_#supp #txt;_]]


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
// add colors here if you need more sections
#let colors = (
  "#D88C9A",
  "#8FDFFA",
  // "#116e11",
  "#F2D0A9",
  "#F1E3D3",
  "#99C1B9",
  "#8E7DBE",
)
// recipe function
#let recipe-types = (
  "table of content",
  // "introduction",
  "bread",
  "breakfast",
  "side",
  "main",
  "treat",
)
#let recipe-type-symbols = (
  "icons/hat.svg",
  // "icons/bread2.svg",
  "icons/bread2.svg",
  "icons/shakers.svg",
  "icons/pin.svg",
  "icons/dish.svg",
  "icons/cupcake2.svg",
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
    image(image-path, width: 100%, height: if image-above or image-below { auto } else { 100% })
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
    "Fried Onions",
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
      ([½ cup], [fruit of choice (mango for yellow, raspberries for pink, blueberries for purple)]),
      ([¾ cup], [unsweetened plant-based milk (soy, almond, cashew, or oat)]),
      ([¼ cup], [coconut milk]),
      ([1 teaspoon], [pure maple syrup]),
      ([1 teaspoon], [vanilla extract]),
      ([3 tablespoons], [chia seeds]),
      ([1 cup], [unsweetened Vegan Yogurt]),
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
    image-above: true,
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
      Leave uncovered and cook for 25 minutes or until the beans have softened and absorbed
      description
      description the flavors.
      While the rajma is cooking start the rice. Rinse rice 3 times, then add water, salt, oil, and cumin seeds.
      After cooking, taste the rajma and adjust salt and spices as needed.
      Add 1 tsp kasoori methi, 2-3 whole green chilies, and fresh cilantro to the rajma. Cook an additional 2-3 minutes
      Stir in 1/2 tsp garam masala and additional cilantro. Serve hot with rice.
    ],
    image-above: true,
  ),
  recipe(
    "main",
    "White Bean Chili",
    image-path: "imgs/whitebeanchili.jpg",
    image-below: true,
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
    [ In a large pot, heat avocado oil over medium heat.
      Add 2 cups diced yellow onion and 3 cloves minced garlic. Sauté for about 5 minutes until the onions are softened.
      Add 1 lb ground impossible meat to the pot. Season with 2 tsp salt and 1 tsp black pepper. Cook until the impossible meat is browned and fully cooked.
      Stir in 2 tsp cumin, 1½ tsp oregano, 1 tsp coriander, 1½ tsp chili powder, and ½ tsp cayenne pepper. Cook for 1-2 minutes until the spices become fragrant.
      Add 2-4 oz diced green chilies, 2 cans of white beans, 2 cups veggie broth, and 2 bay leaves. Stir everything together.
      In a blender or food processor, blend 1 can of white beans into a smooth puree. Add this puree to the pot and stir well.
      Bring the mixture to a boil, then reduce the heat to a simmer. Let it cook for about 30-40 minutes, stirring occasionally, to allow the flavors to meld and the chili to thicken.
      Remove the bay leaves. Serve the chili hot with sourdough bread, vegan sour cream, vegan cheese, and any other desired toppings.
    ],
  ),
  recipe(
    "side",
    "Cauliflower Soup",
    is-gf: true,
    is-nf: true,
    image-above: true,
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
    [
      Divide the cauliflower head into florets or roughly chop it.
      Sauté 2 cloves minced garlic in 1 tablespoon olive oil in a large skillet until fragrant, for about #u[2 minutes]. Add 1 1/2 cups vegetable stock, 2 thyme sprigs and cauliflower florets.

      Bring to a boil, cover, reduce the heat and cook for #u[15-20 minutes], until the cauliflower is nice and soft.
      Discard the thyme and blend until smooth, using a blender.


      Add 1/2 cup light coconut milk and season with salt and freshly ground black pepper to taste. Garnish with 4 tablespoons pomegranate seeds and 2 sprigs fresh thyme.
    ],
  ),
  //
  recipe(
    "main",
    "Spicy Crunchy Tofu",
    image-below: true,
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
    ],
  ),
  recipe(
    "main",
    "Butter Chick'n",
    is-gf: true,
    is-nf: true,
    image-below: true,
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
      Preheat the oven to #u[400°F] and line a baking sheet with parchment paper.
      Slice the tofu into about 6 slices. Now, rip each slice into medium-large pieces. Ripping gives the tofu a great texture for this dish.
      Add the tofu pieces to a large bowl along with the olive oil, potato starch and salt. Stir gently to coat. Arrange the tofu evenly on the prepared pan, and bake for #u[25-30 minutes], until golden and crispy.
      While the tofu bakes, start the rice cooker.
      Then prepare the sauce: Melt the 2 tablespoons of vegan butter in a large pan over medium-high heat. Saute the onion for #u[3-4 minutes] in the butter, then add the ginger and garlic and cook for 1 more minute. Add the spices, salt, tomato paste and coconut milk. Stir until smooth and combined, then simmer for 5-10 minutes, stirring frequently.
      When the tofu is done baking, add it to the sauce and stir to coat the pieces. Serve over rice. Garnish with chopped fresh cilantro. Enjoy!
    ],
  ),
  recipe(
    "main",
    "Brocolli Cheddar Orzo",
    is-gf: true,
    is-nf: true,
    image-above: true,
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
    ],
  ),
  recipe(
    "main",
    "Baked Sweet Potato Chaat",
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
      ([1-2], [serves fried onion], [_(see pg. #context locate(label("Fried Onions")).page())_]),
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
    image-below: true,
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
    ],
  ),
  recipe(
    "bread",
    "Focacia",
    is-nf: true,
    image-path: "imgs/focaccia.jpg",
    image-below: true,
    adapted-from: "Bon Appetit",
    (
      ([1 envelope], [active dry yeast], [2¼ tsp]),
      ([2 tsp], [maple syrup]),
      ([5 cups], [all-purpose flour]),
      ([5 tsp], [Diamond Crystal kosher salt]),
      ([1 Tbsp], [Morton kosher salt]),
      ([6 Tbsp], [extra-virgin olive oil], [divided, plus more for hands]),
      ([4 Tbsp], [unsalted butter], [plus more for pan]),
      ([], [flaky sea salt], [for finishing]),
      ([2–4 cloves], [garlic]),
    ),
    [Whisk one ¼-oz. envelope active dry yeast (about 2¼ tsp.), 2 tsp. honey, and 2½ cups lukewarm water in a medium bowl and let sit #u[5 minutes] or until foamy.
      Add 5 cups all-purpose flour and 5 tsp. Diamond Crystal or 1 Tbsp. Morton kosher salt and mix with a rubber spatula until a dough forms.
      Pour 4 Tbsp. extra-virgin olive oil into a big bowl. Cover with a silicone lid and let it rise at room temperature until doubled in size, #u[3–4 hours].

      Generously butter a 13x9" baking pan. Pour 1 Tbsp. extra-virgin olive oil into center of pan. Keeping the dough in the bowl and using a fork in each hand, gather up edges of dough farthest from you and lift up and over into center of bowl. Give the bowl a quarter turn and repeat process.

      Do this 2 more times; you want to deflate dough while you form it into a rough ball. Transfer dough to prepared pan. Pour any oil left in bowl over and turn dough to coat it in oil. Let rise, uncovered, in a dry, warm spot until doubled in size, at least #u[1½ hours] and up to #u[4 hours].
      Place a rack in middle of oven; preheat to 450°. To see if the dough is ready, poke it with your finger. It should spring back slowly, leaving a small visible indentation. Lightly oil your hands. If using a rimmed baking sheet, gently stretch out dough to fill. Dimple focaccia all over with your fingers, like you’re aggressively playing the piano, creating very deep depressions in the dough (reach your fingers all the way to the bottom of the pan). Drizzle with remaining 1 Tbsp. extra-virgin olive oil and sprinkle with flaky sea salt. Bake focaccia until puffed and golden brown all over, #u[20–30 minutes].
      Hold off on this last step until you're ready to serve the focaccia: Melt 4 Tbsp. unsalted butter in a small saucepan over medium heat. Remove from heat. Peel and grate in 2–4 garlic cloves with a Microplane (use 2 cloves if you’re garlic-shy or up to 4 if you love it). Return to medium heat and cook, stirring often, until garlic is just lightly toasted, #u[30–45 seconds].
      Brush garlic-butter all over focaccia and slice into squares or rectangles.
    ],
  ),
  recipe(
    "treat",
    "Peanut Butter Bars",
    is-nf: true,
    adapted-from: link(
      "https://minibatchbaker.com/small-batch-no-bake-chocolate-peanut-butter-bars/",
    )[Mini Batch Baker],
    image-path: "imgs/No-Bake-Peanut-Butter-Bars-RC-2010984005.jpg",
    (
      ([], [Bar dough]),
      ([1/2 cup], [graham cracker crumbs], [60 g], [sub gluten-free cookie crumbs]),
      ([1/2 cup], [powdered sugar], [60 g], [sub regular sugar]),
      ([1/4 cup], [plant butter], [melted], [56 g]),
      ([1/4 cup], [peanut butter], [64 g], [sub other nut/seed butter]),
      ([], [Chocolate layer]),
      ([1/3 cup], [chocolate chips], [60 g]),
      ([1 Tbsp], [peanut butter], [16 g], [sub other nut/seed butter]),
    ),
    [Line a standard loaf pan with parchment paper or muffin liners.

      In a medium bowl, mix melted butter, graham crumbs, powdered sugar, and peanut butter until well blended. Press evenly into prepared pan.

      Place chocolate chips and peanut butter in a microwave-safe bowl. Microwave on high, stirring every #u[15 secs], until smooth. Spread evenly over crust.

      Refrigerate #u[1 hour], then cut into #u[8] squares.

    ],
  ),
  recipe(
    "main",
    "Dan Dan Noodles",
    adapted-from: "Chinese Homestyle",
    image-path: "imgs/dandannoodle.jpg",
    image-above: true,
    (
      1,
      ([4 Tbsp], [Chinese sesame paste], [or tahini]),
      ([#frac(1, 4) cup], [light soy sauce]),
      ([#frac(1, 4) cup], [Chinkiang vinegar]),
      ([4 cloves], [garlic], [finely minced]),
      ([3], [scallions], [thinly sliced]),
      ([2 Tbsp], [sugar]),
      ([#frac(1, 3)–1 cup], [chili oil with flakes]),
      ([1 tsp], [Sichuan peppercorns], [freshly ground]),
      2,
      ([8 oz], [white button mushrooms]),
      ([#frac(1, 2) cup], [whole pecans], [or walnuts]),
      ([3], [scallions], [coarsely chopped]),
      ([3 cloves], [garlic], [peeled]),
      ([1/2 block], [extra-firm tofu]),
      ([1 Tbsp], [peanut oil], [or vegetable oil]),
      ([1/3 cup], [Sichuan pickled mustard greens]),
      ([1 #frac(1, 2) Tbsp], [soy sauce]),
      ([2 Tbsp], [Shaoxing wine]),
      3,
      ([1 lb], [fresh thin wheat noodles]),
      ([several bunches], [baby bok choy]),
      ([1/2 cup], [unsalted dry roasted peanuts], [crushed]),
    ),
    [In a medium bowl, whisk #u[4 Tbsp] sesame paste, #u[#frac(1, 4) cup] light soy sauce, and #u[#frac(1, 4) cup] Chinkiang vinegar.
      Stir in #u[4] finely minced garlic cloves, #u[3] thinly sliced scallions, and #u[2 Tbsp] sugar.
      Mix in #u[#frac(1, 3)–1 cup] chili oil with flakes, adding #u[1 Tbsp] at a time to reach desired heat.
      Stir in #u[1 tsp] freshly ground Sichuan peppercorns, adding #u[#half tsp] at a time until pleasantly numbing.

      In a food processor, combine #u[8 oz] white button mushrooms, #u[#half cup] whole pecans, #u[3] coarsely chopped scallions, and #u[3] peeled garlic cloves. Pulse until finely chopped.
      Add #u[#half block] extra-firm tofu and pulse again until evenly chopped but not smooth.

      Heat #u[1 Tbsp] peanut (or vegetable) oil in a skillet over medium heat.
      Add #u[#frac(1, 3) cup] Sichuan pickled mustard greens and sauté briefly until fragrant.
      Add tofu–mushroom mixture and cook, stirring, until bottom of pan looks dry, #u[1–2 mins].
      Stir in #u[1#half Tbsp] soy sauce and #u[2 Tbsp] Shaoxing wine, scraping up browned bits.
      Reduce heat to medium and cook, stirring occasionally, #u[10 mins], until thickened and paste no longer drips from spatula.
      Transfer topping to a bowl.

      Boil #u[1 lb] thick fresh noodles according to package instructions.
      Add baby bok choy to boiling noodles for #u[30–60 secs].
      Divide noodles and bok choy among serving bowls.
      Spoon over sauce.
      Top generously with tofu mixture.
      Sprinkle with #u[#half cup] crushed roasted peanuts (optional).
      Mix well and serve.
    ],
  ),
  recipe(
    "main",
    "Jackfruit Tacos",
    is-nf: true,
    adapted-from: "Provecho",
    image-above: true,
    image-path: "imgs/Vegan-Jackfruit-Tacos-1200-1821402596.jpg",
    (
      ([5 Tbsp], [avocado oil]),
      ([#frac(1, 2)], [white onion], [finely chopped]),
      ([5 cloves], [garlic], [minced]),
      ([6], [guajillo chiles]),
      ([1 tsp], [cumin seeds]),
      ([#frac(1, 2)], [large tomato], [roughly chopped]),
      ([#frac(1, 2) cup], [low-sodium vegetable broth]),
      ([1], [large tomato], [roughly chopped]),
      ([1 Tbsp], [dried oregano]),
      ([1 Tbsp], [paprika], [or smoked paprika]),
      ([1 tsp], [fine sea salt]),
      ([2 cans], [young green jackfruit in water], [2 oz each], [rinsed and drained]),
      ([8], [corn/flour tortillas]),
      ([], [pico de gallo], [vegan sour cream], [sliced avocado for topping]),
      ([], [cilantro], [finely chopped]),
      ([], [lime wedges], [for squeezing]),
    ),
    [Make the sauce
      In a large skillet over medium heat, warm #u[2 Tbsp] avocado oil.
      Add #u[#half] finely chopped white onion, #u[5] minced garlic cloves, #u[6] guajillo chiles, and #u[1 tsp] cumin seeds. Cook, stirring, until oil takes on a reddish tint, #u[4 mins] (lower heat if browning too fast).
      Reduce heat to low and cook, stirring, until guajillos turn reddish brown, #u[2 mins]. Remove guajillos and set aside. Transfer onion–garlic–cumin mixture to a blender.
      Stem and seed the #u[6] guajillo chiles and add to blender.
      Add #u[#half cup] fresh orange juice, #u[#half cup] low-sodium vegetable broth, #u[#half large] tomato (roughly chopped), #u[1 Tbsp] dried oregano, #u[1 Tbsp] paprika or smoked paprika, and #u[1 tsp] fine sea salt. Blend until smooth. Set aside.

      Prepare the jackfruit
      Take #u[2 (20-oz.) cans] young green jackfruit, rinsed and drained. Shred with hands and pat dry. Set aside.
      Warm a large skillet over medium heat #u[4–5 mins].
      Add remaining #u[3 Tbsp] avocado oil and heat until shimmering.
      Add shredded jackfruit and cook, stirring occasionally, until golden brown and crispy, #u[8 mins].
      Lower heat and cook until deeper brown, #u[5 mins], stirring if sticking.
      Add #u[1 Tbsp] water, then pour in blended sauce. Bring to a boil.
      Turn heat to medium, cover partially, and simmer until sauce thickens and most liquid evaporates, #u[12–15 mins].

      Assemble the tacos
      Warm #u[8] corn or flour tortillas.
      Add a generous scoop of jackfruit filling to each.
      Top with pico de gallo, vegan sour cream, sliced avocado (optional), and finely chopped cilantro leaves and tender stems.
      Serve with lime wedges for squeezing.
    ],
  ),
  recipe(
    "side",
    "Eggless Drop Soup",
    is-nf: true,
    adapted-from: "Chinese Homestyle",
    image-path: "imgs/eggdrop.jpg",
    (
      ([], [Spice mix]),
      ([2 Tbsp], [water]),
      ([4 tsp], [cornstarch/potato starch]),
      ([#frac(1, 4) tsp], [white pepper powder]),
      ([#frac(1, 4) tsp], [salt], [or to taste]),
      ([#frac(1, 8) tsp], [turmeric powder], [for yellow color, optional]),
      ([], [Soup]),
      ([4 cups], [water]),
      ([3], [green onions], [thinly sliced, white and green parts separated]),
      ([2 slices], [ginger]),
      ([2 tsp], [mushroom powder]),
      ([4], [fresh yuba sheets], [or 1 semi-dried yuba sheet, cut into strips]),
      ([2 tsp], [sesame oil]),
    ),
    [Make the spice mix
      Combine all ingredients in a small bowl and whisk until well blended.

      Cook the soup
      In a small pot, add water, white part of green onion, and ginger.
      Bring to a boil over high heat, then reduce to low and simmer.

      Whisk spice mix again until cornstarch is fully dissolved. Pour into soup and stir well. Simmer until slightly thickened, ~#u[30 secs].
      Add mushroom powder and stir to combine.

      Add yuba sheet and cook #u[1 min], until tender. Taste soup and adjust with salt or mushroom powder if needed.

      Finish & serve
      Drizzle with sesame oil and sprinkle with green part of green onion. Stir to combine and serve hot.

    ],
  ),
  recipe(
    "main",
    "Pineapple Fried Rice",
    image-path: "imgs/friedrice.png",
    is-gf: true,
    image-below: true,
    adapted-from: "Vegan Asian Cookbook",
    (
      ([3 cups], [cooked and cooled rice], [leftover is best]),
      ([14 oz], [extra-firm tofu]),
      ([3 Tbsp], [neutral oil]),
      ([#frac(1, 2) tsp], [salt], [divided, plus more to taste]),
      ([1], [small onion], [diced]),
      ([1], [red bell pepper], [seeded and diced]),
      ([], [frozen peas], [desired quantity]),
      ([2 Tbsp], [temari sauce]),
      ([2 tsp], [coconut sugar], [or to taste]),
      ([2 tsp], [curry powder]),
      ([#frac(1, 2) tsp], [chili powder]),
      ([#frac(1, 4) tsp], [ground white pepper], [or to taste]),
      ([2 cups], [pineapple chunks], [fresh or canned, cut into #frac(1, 2)-inch (1.3-cm) cubes]),
      ([1 cup], [roasted cashews]),
      ([#frac(1, 2) cup], [chopped scallions], [plus more for garnish]),
      ([#frac(1, 2) cup], [seeded and diced tomato]),
    ),
    [Prepare the rice & tofu
      Place #u[3 cups] cooked, cooled rice in a large bowl and gently break apart with a spoon. Set aside.
      Press #u[14 oz] extra-firm tofu for #u[10 mins] to remove excess liquid, then cut into #u[#half - inch] cubes.

      Cook the tofu & vegetables
      Heat a large skillet or wok over medium-high heat and add #u[3 Tbsp] neutral oil.
      Add tofu cubes, sprinkle with #u[#frac(1, 4) tsp] salt, and pan-fry, flipping every few minutes, until golden and crisp, ~#u[20 mins]. Move tofu to one side.
      Add #u[1] small diced onion and #u[1] diced red bell pepper. Sauté ~#u[2 mins] until softened.

      Add rice & seasonings
      Add rice to skillet. Season with #u[2 Tbsp] soy sauce, #u[2 tsp] coconut sugar, #u[2 tsp] curry powder, #u[#half tsp] chili powder (or sliced chile), and #u[#frac(1, 4) tsp] ground white pepper. Mix well.
      Add remaining #u[#frac(1, 4) tsp] salt, adjust to taste, and stir-fry until rice is heated through.

      Add fruits & nuts
      Add #u[1 cup] pineapple cubes and increase heat to high. Stir-fry #u[2–3 mins], stirring occasionally.
      Add #u[#frac(1, 3) cup] roasted cashews, #u[#half cup] chopped scallions, #u[#half cup] diced tomato, and desired amount of frozen peas. Stir-fry #u[2 mins] more.

      Finish & serve
      Taste and adjust seasoning. Remove from heat and serve hot, garnished with extra chopped scallions.
    ],
  ),
  recipe(
    "side",
    "Warm Cous Cous Spiced Salad",
    is-gf: true,
    is-nf: true,
    adapted-from: "America's Test Kitchen",
    image-path: "imgs/couscous.jpg",
    (
      ([1], [carrot], [peeled and chopped]),
      ([5 tsp], [extra-virgin olive oil], [divided]),
      ([#frac(1, 8) tsp], [table salt]),
      ([#frac(2, 3) cup], [vegetable broth]),
      ([#frac(1, 2) tsp], [smoked paprika]),
      ([#frac(1, 4) tsp], [ground cumin]),
      ([1 15 oz can], [chickpeas], [rinsed]),
      ([#frac(1, 4) cup], [raisins]),
      ([#frac(1, 4) cup], [chopped fresh parsley or cilantro]),
      ([2 tsp], [lemon juice], [plus lemon wedges for serving]),
      ([#frac(1, 2) cup], [pearl couscous]),
    ),
    [Cook the couscous
      In a large saucepan, combine #u[#half cup] pearl couscous, #u[1] chopped carrot, #u[2 tsp] olive oil, and #u[#frac(1, 8) tsp] salt.
      Cook over medium heat, stirring often, until about half of the grains are golden, ~#u[5 mins].

      Add broth & spices
      Stir in #u[#frac(2, 3) cup] vegetable broth, #u[#half tsp] smoked paprika, and #u[#frac(1, 4) tsp] ground cumin.
      Bring to a simmer, reduce heat to low, cover, and cook gently, stirring occasionally, until broth is absorbed and couscous is tender but slightly chewy, ~#u[10–15 mins].
      Remove from heat and let sit, covered, #u[3 mins].

      Finish & serve
      Stir in #u[1 (15-oz.) can] rinsed chickpeas, #u[#frac(1, 4) cup] raisins, #u[#frac(1, 4) cup] chopped parsley or cilantro, #u[2 tsp] lemon juice, and remaining #u[1 Tbsp] (3 tsp) olive oil.
      Season with additional salt and pepper to taste.
      Serve warm with lemon wedges on the side.
    ],
  ),
  recipe(
    "side",
    "Green Salad",
    image-above: false,
    image-path: "imgs/Strawberry-Arugula-Salad-with-Hemp-Seeds-and-Brown-Sugar-Pecans-Healthy-quick-and-satisfying-recipe-salad-strawberry-healthy-vegan-glutenfree-minimalistbaker.jpg",
    is-gf: true,
    is-nf: true,
    adapted-from: link("https://minimalistbaker.com/strawberry-arugula-salad/")[Minimalist Baker],
    (
      1,
      ([1 heaping cup], [raw hazelnuts], [roughly chopped]),
      ([2 tsp], [olive oil], [or melted coconut oil]),
      ([1 Tbsp], [coconut sugar]),
      ([2 tsp], [maple syrup]),
      ([1 pinch], [sea salt]),
      ([1 pinch], [ground cinnamon]),
      2,
      ([2 Tbsp], [balsamic vinegar]),
      ([2 Tbsp], [extra virgin olive oil]),
      ([#frac(1, 2) tsp], [maple syrup]),
      ([1–2 Tbsp], [minced shallot]),
      ([1 pinch], [sea salt]),
      ([1 pinch], [black pepper]),
      3,
      ([5 oz], [package mixed greens]),
      ([1 #frac(1, 2) cups], [thinly sliced strawberries]),
    ),
    [Toast the hazelnuts
      Preheat oven to #u[350°F] (#u[176°C]) and line a baking sheet with parchment.
      Add raw hazelnuts and toast #u[7 mins]. Remove from oven.
      Add remaining ingredients (#u[oil], #u[coconut sugar], #u[maple syrup], #u[sea salt], #u[cinnamon]) to hazelnuts and toss to combine.
      Return to oven and roast #u[4–6 mins], until fragrant and golden. Set aside to cool.

      Prepare the dressing
      Combine all dressing ingredients in a jar or mixing bowl. Shake or whisk vigorously to combine.
      Taste and adjust: more balsamic for acidity, maple syrup for sweetness, salt or pepper for balance, olive oil for creaminess. Set aside.

      Assemble the salad
      In a large mixing bowl, add spinach, #u[#half] of the strawberries, and #u[#half] of the roasted hazelnuts.
      Drizzle with #u[#half] of the dressing and toss to combine.
      Plate and garnish with remaining strawberries and hazelnuts. Serve with remaining dressing if desired.
    ],
  ),
  recipe(
    "side",
    "Pasta Salad",
    is-nf: true,
    adapted-from: link("https://foodwithfeeling.com/vegan-pasta-salad-easy/")[Food with Feeling],
    image-path: "imgs/Vegan-Pasta-Salad-2-683x1024.jpg",
    (
      ([1 lb], [pasta], [I used rotini]),
      ([#frac(1, 2)], [red onion], [thinly sliced]),
      ([#frac(1, 2) cup], [grape or cherry tomatoes], [halved or quartered]),
      ([1], [small green bell pepper], [chopped], [about 1 cup]),
      ([1 can], [sliced black olives], [6 oz]),
      ([#frac(1, 4) cup], [chopped fresh parsley or cilantro], [I used parsley]),
      ([], [salt and pepper], [to taste]),
      ([#frac(1, 3) cup], [olive oil]),
      ([2 Tbsp], [white balsamic vinegar]),
      ([#frac(1, 2) tsp], [oregano]),
      ([1 tsp], [garlic powder]),
      ([1 tsp], [onion powder]),
      ([#frac(1, 4) tsp], [crushed red pepper]),
      ([], [sugar], [good pinch]),
    ),
    [Cook the pasta
      Cook pasta according to package directions until desired doneness. Drain and let cool.
      If serving cold, run under cold water to cool thoroughly.

      Make the dressing
      Combine olive oil, vinegar, spices, and sugar. Whisk until fully combined. Set aside.

      Assemble the salad
      In a large bowl, combine pasta, chopped vegetables, and parsley (or cilantro).
      Add dressing and toss until pasta and veggies are fully coated.
      Season with salt and pepper to taste and serve.
    ],
  ),
  recipe(
    "main",
    "Curry Lentil Soup",
    image-path: "imgs/lentil-soup-recipe-580x794.jpg",
    is-gf: true,
    is-nf: true,
    adapted-from: link("https://www.loveandlemons.com/curry-lentil-soup/#wprm-recipe-container-75207")[Love and Lemons],
    (
      ([2 Tbsp], [coconut oil]),
      ([1], [medium onion], [chopped]),
      ([4 cloves], [garlic], [minced]),
      ([3 Tbsp], [minced fresh ginger]),
      ([1 Tbsp], [mild curry powder]),
      ([#frac(1, 4) tsp], [crushed red pepper flakes], [plus more to taste]),
      ([1 can], [fire-roasted diced tomatoes], [28 oz]),
      ([1 cup], [dry French green lentils], [rinsed]),
      ([2 #frac(1, 2) cups], [water]),
      ([1 can], [full-fat coconut milk], [14 oz]),
      ([#frac(1, 2) tsp], [sea salt], [plus more to taste]),
      ([], [freshly ground black pepper]),
      ([#frac(1, 2) cup], [chopped fresh cilantro]),
      ([2 Tbsp], [fresh lime juice]),
    ),
    [Cook the aromatics
      Heat oil in a large pot or Dutch oven over medium heat. Add onion and a pinch of salt. Cook until soft and lightly browned around edges, #u[8–10 mins], reducing heat to low as needed.

      Add spices
      With heat on low, add garlic, ginger, curry powder, and red pepper flakes. Cook, stirring, until fragrant, ~#u[2 mins].

      Cook the lentils
      Add tomatoes, lentils, water, coconut milk, #u[#half tsp] salt, and several grinds of black pepper. Bring to a boil, cover, reduce heat, and simmer, stirring occasionally, until lentils are tender, #u[25–35 mins].
      If too thick, stir in #u[#half–1 cup] more water to reach desired consistency.

      Finish & serve
      Stir in cilantro and lime juice. Adjust seasoning with salt and pepper. Serve hot.

    ],
  ),
  recipe(
    "breakfast",
    "Southwest Tofu Scramble",
    image-path: "imgs/tofuscramble.jpg",
    is-gf: true,
    is-nf: true,
    adapted-from: "Minimalist Baker",
    (
      1,
      ([8 oz], [extra-firm tofu], [extra-firm tofu]),
      ([1–2 Tbsp], [olive oil]),
      ([#frac(1, 4)], [medium red onion], [thinly sliced]),
      ([#frac(1, 2)], [medium red bell pepper], [thinly sliced]),
      ([2 cups], [kale], [loosely chopped]),
      2,
      ([#frac(1, 2) tsp], [sea salt], [reduce amount for less salty sauce]),
      ([#frac(1, 2) tsp], [garlic powder]),
      ([#frac(1, 2) tsp], [ground cumin]),
      ([#frac(1, 4) tsp], [chili powder]),
      ([], [water], [to thin]),
      ([#frac(1, 4) tsp], [turmeric], [optional]),
      3,
      ([], [For serving, optional]),
      ([], [salsa]),
      ([], [cilantro and/or hot sauce]),
      ([], [toast, butter, jam]),
      ([], [breakfast potatoes]),
      ([], [fresh fruit]),
    ),
    [Press the tofu
      While tofu is draining, prepare the sauce: combine dry spices in a small bowl and add enough water to make a pourable sauce. Set aside.

      Prep vegetables and heat a large skillet over medium heat. Add olive oil, onion, and red pepper. Season with a pinch of salt and pepper and stir. Cook until softened, ~#u[5 mins].
      Add kale, season with a bit more salt and pepper, cover, and steam #u[2 mins].

      Unwrap tofu and crumble with a fork into bite-sized pieces.

      Move vegetables to one side of the pan. Add tofu and sauté #u[2 mins]. Pour sauce mostly over tofu and a little over the veggies. Stir immediately to evenly coat.
      Cook #u[5–7 mins], until tofu is slightly browned.

      Serve
      Serve immediately with breakfast potatoes, toast, or fruit. Optional: add salsa, hot sauce, or fresh cilantro for extra flavor.

    ],
  ),
  recipe(
    "treat",
    "Chocolate Chip Cookies",
    image-path: "imgs/Chocolate-Chip-Cookies-1-1-1024x1536-183090191.jpg",
    is-nf: true,
    adapted-from: "Purely Kaylee",
    (
      ([#frac(1, 2) cup], [vegan butter], [slightly softened]),
      ([1 cup], [light brown sugar], [packed]),
      ([#frac(1, 4) cup], [plant-based milk]),
      ([2 tsp], [vanilla extract]),
      ([1 #frac(3, 4) cups], [all-purpose flour]),
      ([1 tsp], [baking soda]),
      ([#frac(1, 2) tsp], [salt]),
      ([1 cup], [vegan chocolate chips]),
    ),
    [Prepare the dough
      In a large bowl, add vegan butter and brown sugar. Cream together until just combined, ~#u[1–2 mins].
      Add plant-based milk and vanilla extract. Cream again to combine.

      Add dry ingredients
      Add all-purpose flour, baking soda, and salt. Fold until evenly combined, then stir in chocolate chips.
      Cover dough and refrigerate #u[30 mins] or longer.

      Bake the cookies
      Preheat oven to #u[350°F] and line a baking sheet with parchment paper.
      Scoop cookie dough into balls and place on prepared baking sheet.
      Bake #u[12 mins] on the middle rack, removing while centers are still slightly underbaked.
      Let cookies rest #u[5 mins] on baking sheet before serving.
    ],
  ),
  recipe(
    "treat",
    "PB Chocolate Nobake Cookies",
    is-gf: true,
    image-path: "imgs/nobakecookies.jpg",
    adapted-from: link("https://www.karissasvegankitchen.com/vegan-no-bake-cookies/#recipe")[karissasvegankitchen],
    (
      ([#frac(1, 2) cup], [vegan butter]),
      ([1#frac(3, 4) cup], [granulated sugar]),
      ([#frac(1, 2) cup], [non-dairy milk]),
      ([#frac(1, 4) cup], [cocoa powder]),
      ([3 cup], [quick oats]),
      ([#frac(3, 4) cup], [creamy peanut butter]),
      ([1 tbsp], [vanilla extract]),
      ([#frac(1, 4) tsp], [salt]),
    ),
    [
      Make the chocolate mixture
      In a large saucepan, combine the butter, sugar, non-dairy milk, and cocoa powder. Bring to a boil over medium heat, whisking frequently. Let boil for #u[1 min].

      Remove from heat. Immediately stir in the oats, peanut butter, vanilla, and salt until fully combined.

      Prep & scoop
      Line #u[2 baking sheets] with parchment paper. Drop spoonfuls of the warm cookie mixture onto the baking sheets.

      Cool & set
      Let cool in fridge until set, about #u[30 mins].
    ],
  ),
  recipe(
    "main",
    "Tortilla Soup",
    image-path: "imgs/tortillasoup.jpg",
    image-below: true,
    is-gf: true,
    is-nf: true,
    adapted-from: "Megan's Recipe",
    (
      1,
      ([1], [jalapeño], [diced, seeds removed]),
      ([1], [poblano pepper], [diced, seeds removed]),
      ([1], [red onion], [diced, divided]),
      ([5 cloves], [garlic], [minced]),
      ([2 tbsp], [tomato paste]),
      ([2], [chipotle peppers in adobo], [diced]),
      ([1 can], [hominy], [drained and rinsed]),
      ([1 can], [corn], [drained]),
      ([1 can], [black beans], [drained and rinsed]),
      ([1 can], [fire-roasted diced tomatoes]),
      ([1 can], [crushed tomatoes]),
      ([1 tsp], [ground coriander]),
      ([1 tsp], [smoked paprika]),
      ([#frac(1, 2) tsp], [ground cumin]),
      ([1 tsp], [salt]),
      ([#frac(1, 2) tsp], [black pepper]),
      ([2 cup], [vegetable broth]),
      2,
      ([1], [avocado], [sliced or diced]),
      ([#frac(1, 4) cup], [fresh cilantro], [chopped]),
      ([1], [lime], [cut into wedges]),
    ),
    [
      Heat oil in a pot over medium-high heat. Add jalapeño and poblano and sauté until lightly charred, about #u[8 mins].

      Add cumin, coriander, smoked paprika, pepper, and salt. Stir and cook for #u[1 min] until fragrant.

      Reserve #u[#frac(1, 4)] of the diced red onion for topping. Add remaining onion and garlic to the pot and cook until onions are browned.

      Stir in tomato paste and cook briefly. Add diced chipotle peppers in adobo and cook for about #u[1 min].

      Add hominy, corn, black beans, fire-roasted diced tomatoes, crushed tomatoes, and vegetable broth. Bring to a simmer and cook for #u[20 mins].

      Ladle into bowls and top with avocado, cilantro,and lime wedges. Serve hot.
    ],
  ),
  recipe(
    "main",
    "Crispy Tofu Tacos",
    image-path: "imgs/crispytofutaco.jpg",
    image-above: true,
    is-gf: true,
    is-nf: true,
    adapted-from: "New York Times",
    (
      1,
      ([2 blocks], [firm tofu]),
      ([#frac(1, 4) cup plus 3 tbsp], [olive oil], [divided]),
      ([2 tbsp], [soy sauce]),
      ([2 tsp], [ground cumin]),
      ([1 tsp], [smoked paprika]),
      ([#frac(1, 2) tsp], [garlic powder]),
      ([#frac(1, 2) tsp], [onion powder]),
      ([#frac(1, 4) to #frac(1, 2) tsp], [ground cayenne]),
      ([to taste], [salt]),
      ([to taste], [black pepper]),
      ([#frac(1, 4) cup], [tomato paste]),
      2,
      ([2], [ripe avocados]),
      ([2 tbsp], [mayonnaise], [vegan, if desired]),
      ([#frac(1, 2) tsp], [lime zest], [finely grated]),
      ([3 tbsp], [lime juice]),
      ([8], [flour/corn tortillas], [warmed]),
      3,
      ([for serving], [red onion], [minced]),
      ([for serving], [radishes], [thinly sliced]),
      ([for serving], [cilantro], [chopped]),
    ),
    [
      Preheat the oven
      Heat oven to #u[400°F].

      Prepare the tofu
      Drain tofu, squeezing out excess moisture (it may break into chunks).
      Coarsely grate tofu onto two #u[11-by-17-inch] foil-lined sheet pans.
      Drizzle each pan with #u[2 tbsp olive oil] and #u[1 tbsp soy sauce].
      In a small bowl, mix cumin, paprika, garlic powder, onion powder, cayenne, #u[1 tsp salt], and #u[1 tsp pepper].
      Sprinkle half the seasoning over each pan and toss to coat.
      Spread into an even layer.

      Roast the tofu
      Roast #u[30–35 mins], stirring halfway through and rotating pans,
      until tofu sizzles, darkens, and crisps.

      Add tomato paste mixture
      Mix tomato paste with remaining #u[3 tbsp olive oil].
      Drizzle half over each pan of tofu and toss to combine.
      Spread evenly and roast again #u[10–15 mins]
      until tofu audibly crackles and develops a slight crunch.

      Make the avocado cream
      In a small food processor or blender, blend avocados, mayonnaise,
      lime zest, and lime juice until creamy.
      Season generously with salt.

      Assemble the tacos
      Swipe warmed tortillas with avocado cream.
      Top with crispy tofu, red onion, radishes, and cilantro.
      Serve immediately.

    ],
  ),
  //
  recipe(
    "bread",
    "Manapua Dough",
    is-nf: true,
    image-path: "imgs/manapua.jpg",
    adapted-from: "Ella's Recipe",
    (
      ([3 cups], [all-purpose flour], [plus extra for rolling]),
      ([1 packet], [active dry yeast]),
      ([2 tsp], [sugar], [for activating yeast]),
      ([1 tbsp], [sugar]),
      ([2 tsp], [baking powder]),
      ([1 tbsp], [oil], [neutral oil of choice]),
      ([1 cup], [water]),
      ([#frac(1, 4) cup], [water], [for activating yeast]),
      ([1 mug], [water], [for steaming to activate yeast]),
      ([about 2 tbsp per bun], [filling], [of choice]),
    ),
    [
      Activate the yeast
      Heat #u[1 mug water] until steaming.
      In a small bowl, combine #u[1 packet yeast], #u[2 tsp sugar], and #u[1/4 cup water].
      Set bowl over the mug so steam gently warms the mixture.
      Let sit until yeast foams and doubles in size.

      Mix the dry ingredients
      In a separate bowl, combine #u[3 cups flour] (reserve extra for rolling),
      #u[1 tbsp sugar], and #u[2 tsp baking powder].
      Mix until well combined.

      Make the dough
      Once yeast is active, add yeast mixture, #u[1 tbsp oil], and #u[1 cup water]
      to the flour mixture.
      Mix and knead until combined and smooth.
      Dough should be soft but not very sticky (add flour as needed).

      Let the dough rise
      Cover and let rise in a warm place
      until doubled in size.

      Divide the dough
      Punch down dough and divide into #u[12–18 pieces].

      Fill and steam
      Roll each piece flat.
      Fill with about #u[2 tbsp filling] of choice.
      Pinch closed to seal.
      Steam on parchment for #u[15 mins].

    ],
  ),
  //   recipe(
  //     "treat",
  //     "title",
  //     is-gf: true,
  //     is-nf: true,
  //     adapted-from: "May 25 p38",
  //     (
  //       ([1 lb], [tofu], [wow]),
  //     ),
  //     [
  //       description
  //     ],
  //   ),
)

// Trying to figure out an index
// #index [apple]

// = Recipe Index
// #columns (2)[
// #make-index (title : [Ingredients Index], outlined : true, use-page-counter : true)
// ]




#for i in recipe-types.map(recipe-type => [
  = #recipe-type;s
  #for j in all-recipes.filter(recipe => recipe.recipe-type == recipe-type) { j.content }
]) { i }

#box()<end>

#make-index(title: [Index], outlined: true, use-page-counter: true)


// git status
// git commit -asm "Add your commit"
// git push
// create new pdf
// ctrl shift p
// export open file as pdf

// =============================================================================
// Research report — Typst template
// Institution-neutral: every organisation-specific value (name, address, logo,
// colours, licence) arrives as a parameter from the Quarto metadata.
// =============================================================================

// ---- Palette (neutral defaults; override `primary` / `accent` from YAML) -----
#let ink = rgb("#1b2530")
#let muted = rgb("#647381")
#let line-color = rgb("#d9e2e8")
#let surface = rgb("#f4f7f9")

// ---- Vertical rhythm ---------------------------------------------------------
// One base unit drives every vertical gap, so paragraphs, headings, figures and
// code blocks stay proportional when the font size changes.
#let rhythm = (
  par: 0.85em,        // gap between paragraphs
  block: 1.1em,       // gap around figures, tables, code, callouts
  h1-above: 2.4em,
  h1-below: 1.0em,
  h2-above: 1.8em,
  h2-below: 0.75em,
  h3-above: 1.4em,
  h3-below: 0.6em,
)

#let report(
  title: none,
  subtitle: none,
  authors: (),
  keywords: (),
  date: none,
  document-type: none,
  version: none,
  // Organisation (all optional)
  org-name: none,
  org-unit: none,
  org-address: none,
  org-website: none,
  cover-logo: none,
  cover-logo-width: 120mm,
  header-logo: none,
  license: none,
  license-logo: none,
  primary: rgb("#004d80"),
  accent: rgb("#d07a02"),
  // Content
  abstract-title: [Abstract],
  abstract: none,
  lang: "en",
  region: "GB",
  // Typography
  font: ("Source Serif 4",),
  headingfont: ("Montserrat",),
  codefont: ("Roboto Mono",),
  mathfont: ("New Computer Modern Math",),
  fontsize: 10.5pt,
  linestretch: 1.0,
  sectionnumbering: "1.1.1",
  toc: true,
  toc-title: [Contents],
  toc-depth: 3,
  doc,
) = {
  let primary-dark = primary.darken(30%)
  let link-color = primary.lighten(10%)

  set document(title: title, keywords: keywords)
  if authors.len() > 0 {
    set document(author: authors.map(a => content-to-string(a.name)).join(", ", last: " & "))
  }

  // ---- Body text -------------------------------------------------------------
  set text(
    font: font, lang: lang, region: region, size: fontsize, fill: ink,
    number-type: "lining", hyphenate: true,
  )
  set par(
    justify: true,
    leading: linestretch * 0.62em,
    spacing: rhythm.par,
    first-line-indent: 0pt,
  )
  show math.equation: set text(font: mathfont)
  show math.equation.where(block: true): set block(above: rhythm.block, below: rhythm.block)
  show raw: set text(font: codefont, size: 0.88em)
  show link: set text(fill: link-color)
  show ref: set text(fill: link-color)
  show figure: set block(above: rhythm.block * 1.3, below: rhythm.block * 1.3)
  show figure.caption: set text(size: 0.9em, fill: muted)
  show list: set block(above: rhythm.par, below: rhythm.par)
  show enum: set block(above: rhythm.par, below: rhythm.par)
  set list(indent: 0.6em, body-indent: 0.5em, spacing: 0.55em)
  set enum(indent: 0.6em, body-indent: 0.5em, spacing: 0.55em)
  set bibliography(title: [References])

  // ---- Headings: sans-serif, sized on a 1.2 modular scale --------------------
  set heading(numbering: sectionnumbering)
  show heading: set text(font: headingfont, fill: primary-dark, weight: 600, hyphenate: false)
  show heading: set par(justify: false)

  show heading.where(level: 1): it => {
    set block(above: rhythm.h1-above, below: rhythm.h1-below, sticky: true)
    block(width: 100%)[
      #set text(size: 1.55em)
      #if it.numbering != none and it.outlined {
        counter(heading).display(it.numbering)
        h(0.6em)
      }
      #it.body
      #v(0.15em, weak: true)
      #line(length: 100%, stroke: 0.9pt + primary)
    ]
  }
  show heading.where(level: 2): set block(above: rhythm.h2-above, below: rhythm.h2-below, sticky: true)
  show heading.where(level: 2): set text(size: 1.22em, fill: primary)
  show heading.where(level: 3): set block(above: rhythm.h3-above, below: rhythm.h3-below, sticky: true)
  show heading.where(level: 3): set text(size: 1.05em, fill: link-color)
  show heading.where(level: 4): set block(above: rhythm.h3-above, below: rhythm.par, sticky: true)
  show heading.where(level: 4): set text(size: 1em, style: "italic", weight: 500)

  show raw.where(block: true): it => block(
    width: 100%,
    fill: surface,
    stroke: 0.6pt + line-color,
    radius: 3pt,
    inset: 9pt,
    above: rhythm.block,
    below: rhythm.block,
  )[#it]

  // =============================== COVER ======================================
  set page(
    paper: "a4",
    margin: (left: 22mm, right: 22mm, top: 18mm, bottom: 18mm),
    numbering: none,
    header: none,
    footer: none,
  )
  {
    set text(font: headingfont)
    set par(justify: false)
    align(center)[
      #if cover-logo != none { image(cover-logo, width: cover-logo-width) } else { v(20mm) }
      #v(26mm)
      #block(width: 100%)[
        #set text(size: 25pt, weight: 600, fill: primary-dark)
        #title
      ]
      #if subtitle != none {
        v(5mm)
        text(size: 14pt, weight: 400, fill: muted)[#subtitle]
      }
      #v(16mm)
      #line(length: 35mm, stroke: 2pt + accent)
      #v(12mm)
      #for author in authors {
        text(size: 11pt, weight: 600, fill: ink)[#author.name]
        linebreak()
        text(size: 8.7pt, weight: 400, fill: muted)[#author.affiliation]
        if author.email != none and author.email != [] {
          linebreak()
          text(size: 8.3pt, fill: link-color)[#author.email]
        }
        v(5mm)
      }
      #v(1fr)
      #let meta = ()
      #if document-type != none { meta += ([DOCUMENT TYPE], document-type) }
      #if version != none { meta += ([VERSION], version) }
      #if date != none { meta += ([DATE], date) }
      #grid(
        columns: (1fr, 1.6fr),
        column-gutter: 9mm,
        row-gutter: 3.5mm,
        align: (right, left),
        ..meta.enumerate().map(((i, c)) => if calc.even(i) {
          text(size: 8pt, weight: 700, fill: muted, tracking: 0.06em)[#c]
        } else {
          text(size: 9.5pt, weight: 500, fill: ink)[#c]
        })
      )
      #v(6mm)
      #line(length: 100%, stroke: 0.8pt + line-color)
      #v(3mm)
      #grid(
        columns: (1fr, auto),
        align: (left + horizon, right + horizon),
        {
          set text(size: 7.5pt, fill: muted)
          set align(left)
          if org-name != none { text(weight: 600, fill: ink)[#org-name]; linebreak() }
          if org-unit != none { [#org-unit]; linebreak() }
          if org-address != none { [#org-address]; linebreak() }
          if org-website != none { link(org-website)[#org-website] }
        },
        {
          if license-logo != none { image(license-logo, height: 8mm) }
          if license != none { v(1mm); text(size: 6.5pt, fill: muted)[#license] }
        },
      )
    ]
  }

  // ====================== FRONT MATTER (abstract, toc) ========================
  let front-title(t) = {
    text(font: headingfont, size: 20pt, weight: 600, fill: primary-dark)[#t]
    v(4pt)
    line(length: 28mm, stroke: 2pt + accent)
    v(10mm)
  }

  pagebreak()
  counter(page).update(1)
  set page(
    margin: (left: 25mm, right: 25mm, top: 28mm, bottom: 25mm),
    numbering: "i",
    number-align: center,
    header: none,
  )
  if abstract != none {
    block(width: 100%)[
      #front-title(abstract-title)
      #abstract
      #if keywords.len() > 0 {
        v(6mm)
        text(font: headingfont, size: 8pt, weight: 700, fill: muted, tracking: 0.06em)[KEYWORDS]
        h(3mm)
        text(size: 0.92em, fill: ink)[#keywords.join(" · ")]
      }
    ]
    pagebreak()
  }

  if toc {
    front-title(toc-title)
    show outline.entry.where(level: 1): it => {
      v(0.9em, weak: true)
      text(font: headingfont, weight: 600, fill: primary-dark, it)
    }
    show outline.entry: set text(font: headingfont, size: 0.92em)
    outline(title: none, depth: toc-depth, indent: 1.4em)
    pagebreak()
  }

  // ============================ MAIN MATTER ===================================
  counter(page).update(1)
  set page(
    margin: (left: 25mm, right: 25mm, top: 28mm, bottom: 25mm),
    numbering: "1",
    number-align: center,
    header: context {
      set text(font: headingfont, size: 7.5pt, weight: 500, fill: muted)
      grid(
        columns: (1fr, auto),
        align: (left + bottom, right + bottom),
        title,
        if header-logo != none { image(header-logo, height: 5mm) },
      )
      v(-1mm)
      line(length: 100%, stroke: 0.5pt + line-color)
    },
    footer: context {
      set text(font: headingfont, size: 7.5pt, fill: muted)
      align(center, counter(page).display("1"))
    },
  )
  doc
}

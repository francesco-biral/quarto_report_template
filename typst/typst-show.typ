#set table(inset: 6pt, stroke: none)

#show: doc => report(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
$if(it.name.literal)$
    (
      name: [$it.name.literal$],
      affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
      email: [$it.email$]
    ),
$endif$
$endfor$
  ),
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(document-type)$
  document-type: [$document-type$],
$endif$
$if(version)$
  version: [$version$],
$endif$
$if(org.name)$
  org-name: [$org.name$],
$endif$
$if(org.unit)$
  org-unit: [$org.unit$],
$endif$
$if(org.address)$
  org-address: [$org.address$],
$endif$
$if(org.website)$
  org-website: "$org.website$",
$endif$
$if(org.cover-logo)$
  cover-logo: "$org.cover-logo$",
$endif$
$if(org.cover-logo-width)$
  cover-logo-width: $org.cover-logo-width$,
$endif$
$if(org.header-logo)$
  header-logo: "$org.header-logo$",
$endif$
$if(org.primary-color)$
  primary: rgb("#$org.primary-color$"),
$endif$
$if(org.accent-color)$
  accent: rgb("#$org.accent-color$"),
$endif$
$if(license.text)$
  license: [$license.text$],
$endif$
$if(license.show-logo)$
$if(license.logo)$
  license-logo: "$license.logo$",
$endif$
$endif$
$if(abstract)$
  abstract: [$abstract$],
  abstract-title: [$labels.abstract$],
$endif$
$if(keywords)$
  keywords: ($for(keywords)$"$keywords$",$endfor$),
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(headingfont)$
  headingfont: ("$headingfont$",),
$endif$
$if(codefont)$
  codefont: ("$codefont$",),
$endif$
$if(mathfont)$
  mathfont: ($for(mathfont)$"$mathfont$",$endfor$),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(linestretch)$
  linestretch: $linestretch$,
$endif$
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$
$if(toc)$
  toc: $toc$,
$endif$
$if(toc-title)$
  toc-title: [$toc-title$],
$endif$
  toc-depth: $toc-depth$,
  doc,
)

# Quarto + Typst research report template

A template for scientific reports, project deliverables and similar documents. From one modular Quarto source it produces:

- a formal **PDF** (via Typst) with cover page, abstract, table of contents, running header;
- an **HTML** companion with navigation, foldable code and an organisation footer.

The template is institution-neutral. Organisation name, address, logos, colours and licence are parameters, so you can brand it for your institution without committing any of that to a public repository.

---

## 1. Requirements

- [Quarto](https://quarto.org) ≥ 1.6 (bundles Typst ≥ 0.12; no LaTeX needed)
- Python ≥ 3.11 with Jupyter, NumPy, Matplotlib and PyYAML

```bash
conda env create -f environment.yml
conda activate quarto-report
```

## 2. Get started

1. On GitHub, click **Use this template** (or clone/download the repository).
2. Edit the YAML header of `report.qmd` (title, authors, abstract, …).
3. Set your organisation details (Section 4).
4. Render:

```bash
quarto render                              # PDF + HTML, neutral branding
quarto render --profile myorg              # with your private branding
quarto render report.qmd --to typst        # PDF only
quarto render report.qmd --to html         # HTML only
```

Output goes to `output/` (`research-report.pdf`, `research-report.html`).

## 3. Project structure

```
report.qmd              Main document: metadata, Introduction, Conclusions, Acknowledgements
sections/_*.qmd         Middle sections (one file per section, included from report.qmd)
_quarto.yaml            Project + format settings, neutral branding defaults
_quarto-example.yml     Example branding profile (copy → _quarto-myorg.yml)
typst/                  PDF template (typst-template.typ) and metadata bridge (typst-show.typ)
filters/org-footer.lua  HTML footer + palette from the org metadata
assets/css/report.css   HTML styling
assets/fonts/           Bundled fonts (with licences)
assets/logos/           Logos (only placeholder + licence badge are committed)
code/python/brand.py    Gives plots the brand colours
references.bib          Bibliography
```

## 4. Parameters

### 4.1 Document metadata (`report.qmd`)

| Key | Purpose |
|---|---|
| `title`, `subtitle` | Cover and running header |
| `author` | List with `name`, `affiliations`, `email` |
| `document-type` | e.g. *Research report*, *Deliverable D2.1*, *Technical note* |
| `version`, `date` | Shown in the cover metadata block |
| `abstract` | Abstract page (omit to skip the page) |
| `keywords` | Listed under the abstract and in PDF metadata |

### 4.2 Organisation and licence (`_quarto.yaml` or a profile)

```yaml
org:
  name: "Organisation Name"
  unit: "Department / Research Group"
  address: "Street, Postcode City, Country"
  website: "https://example.org"
  cover-logo: "assets/logos/placeholder-logo.svg"   # PDF cover + HTML footer
  cover-logo-width: 90mm                            # PDF only
  header-logo: "assets/logos/small-logo.png"        # optional, PDF running header
  primary-color: "004d80"   # hex WITHOUT "#"
  accent-color: "d07a02"    # hex WITHOUT "#"
license:
  text: "CC BY-NC-SA 4.0"
  logo: "assets/logos/by-nc-sa.png"
  show-logo: false          # true = show the CC badge
```

The CC badge is off by default: set `license.show-logo: true` to show it on the PDF cover and in the HTML footer (use another badge by changing `logo`). Every field is optional; remove one and it disappears from the cover and footer. The colours apply to PDF headings and rules, the HTML palette and the plots (through `brand.py`).

Two rules:

- Write colours **without `#`**. Pandoc escapes `#`, which breaks Typst.
- Use logo **filenames without underscores** (`my-logo.png`, not `my_logo.png`) for the same reason.

### 4.3 Private branding with a Quarto profile

Keep your real institutional data out of the public repository:

1. `cp _quarto-example.yml _quarto-myorg.yml` and fill it in.
2. Copy your logos into `assets/logos/`.
3. Render with `quarto render --profile myorg`, or set it once per shell: `export QUARTO_PROFILE=myorg`.

Profile values are merged over `_quarto.yaml`. `.gitignore` excludes every `_quarto-*.yml` (except the example) and every file in `assets/logos/` except the placeholder and the licence badge. Before pushing, check with `git status` that no private file is staged.

You can keep several profiles (e.g. one per institution or project) and switch with `--profile`.

### 4.4 Typography and layout (`_quarto.yaml` → `format: typst`)

| Key | Default | Notes |
|---|---|---|
| `mainfont` | Source Serif 4 | PDF body text |
| `headingfont` | Montserrat | Headings, cover, header/footer (matches the HTML) |
| `codefont` | Roboto Mono | |
| `mathfont` | New Computer Modern Math | Bundled with Typst |
| `fontsize` | 11pt | All spacing scales with it |
| `linestretch` | 1.0 | Multiplies line spacing |
| `toc`, `toc-depth` | true, 3 | |
| `section-numbering` | 1.1.1 | |

Fonts in `assets/fonts/` are found automatically (`font-paths`). To use another font, drop its `.otf`/`.ttf` there and change the key.

Vertical spacing is set in one place: the `rhythm` dictionary at the top of `typst/typst-template.typ` (paragraph gap, gap around figures/code/equations, space above and below each heading level). Headings are kept with the text that follows them.

## 5. Writing content

- **Sections:** add `sections/_name.qmd` (no YAML header) and include it from `report.qmd` with `{{< include sections/_name.qmd >}}`. Keep image paths relative to `report.qmd`.
- **Figures:** label a code cell `#| label: fig-name`, cite as `@fig-name`.
- **Tables:** caption with `: Caption {#tbl-name}`, cite as `@tbl-name`.
- **Equations:** add `{#eq-name}` after `$$ … $$`, cite as `@eq-name`.
- **Citations:** add entries to `references.bib`, cite as `@key`.
- **Callouts:** `.callout-note`, `.callout-tip`, `.callout-warning`, `.callout-important`.
- **Diagrams and Gantt charts (Mermaid):** see `sections/_workplan.qmd`.

  ````markdown
  ```{mermaid}
  %%| label: fig-flow
  %%| fig-cap: "My workflow."
  %%| fig-width: 6
  flowchart LR
    A --> B --> C
  ```
  ````

  Cite as `@fig-flow`. In the PDF, Mermaid is rendered to a 300-dpi PNG with a headless browser: install Chrome/Edge or run `quarto install chromium` once. Mermaid Gantt charts work well up to ~15 tasks; for large schedules, draw the chart in Python (matplotlib) using `brand.py` colours.
- **Page break:** `{{< pagebreak >}}`.
- **Unnumbered section:** `# Title {.unnumbered .unlisted}`.

## 6. Executable code

Python via Jupyter is the default. Code runs but is hidden (`echo: false` in `_quarto.yaml`). To show one cell, add `#| echo: true`. In HTML it appears folded; in the PDF it is printed.

To make plots follow the brand colours:

```python
import sys; sys.path.insert(0, "code/python")
from brand import brand
b = brand()   # b["primary"], b["accent"], b["ink"], b["muted"], b["line"]
```

For an R-first report, remove `jupyter: python3` from `report.qmd`, use `{r}` cells and install `knitr`. Mixing R and Python cells in one document needs `knitr` + `reticulate`.

## 7. Troubleshooting

- **Render hangs after the code cells finish:** Quarto is starting a headless browser to render the Mermaid diagrams for the PDF. Stop with Ctrl+C, then run `quarto install chrome-headless-shell` (Quarto ≥ 1.8) or `quarto install chromium`. Alternatively, point to your own browser: `export QUARTO_CHROMIUM="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"`. Run `quarto render --log-level debug` to see where it stops.
- **`color string contains non-hexadecimal letters`:** write colours in YAML without `#` (e.g. `"004d80"`).
- **Logo not found / odd path errors:** avoid underscores in logo filenames.

## 8. Fonts and licences

- Template code — MIT License (`LICENSE`).
- Source Serif 4 — Adobe, SIL Open Font License 1.1 (`assets/fonts/SourceSerif4-LICENSE.md`)
- Montserrat — SIL Open Font License 1.1 (`assets/fonts/Montserrat-OFL.txt`)
- Roboto Mono — SIL Open Font License 1.1 (`assets/fonts/RobotoMono-OFL.txt`)
- Reports you write are yours; set their licence with the `license:` field.

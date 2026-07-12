# BUAA Markdown Thesis Template (`buaa`)

Write a Beihang University graduate thesis in **Markdown** (Obsidian-friendly), then build a
standards-aligned PDF with **Pandoc + XeLaTeX**.

This repository is a **minimal syntax demo**, not a full research thesis: two body chapters
document configuration and sample markup; back-matter files only exercise the required
commands. Replace them with your own chapters when you start writing.

The LaTeX side is a modular port of official BUAAThesis **v4.1.0** conventions:
`buaa/core/` (shared) + `buaa/reports/<profile>/` (covers, TOC, headers, back matter).
The demo uses report profile `thesis` and degree option `professional`.

Report profiles: [`buaa/reports/README.md`](buaa/reports/README.md).

---

## 1. Quick start

```bash
cd /path/to/thesis-root
./buaa/scripts/build.sh              # → Artifact.pdf
./buaa/scripts/build.sh my-thesis.pdf
```

Checked-in PDFs (not produced by every build): `输出示例.pdf` (this template) and
`官方示例.pdf` (official BUAAThesis reference).

Requirements: **Pandoc ≥ 3**, **XeLaTeX** (MacTeX / TeX Live), and the fonts under
`buaa/font/` (keep them with the template).

Always run from the thesis root so `./buaa/…` and `./references.bib` resolve correctly.
The build script sets `TEXINPUTS` to include `buaa//` so `buaa.cls` and its `\input` tree load.

**In Obsidian:** install the **Shell commands** plugin, set working directory to the
thesis root, and add `./buaa/scripts/build.sh` (alias e.g. `Build thesis PDF`).
Run it from the command palette or a hotkey. Terminal builds remain available the
same way. No Obsidian Pandoc export plugin is used.

---

## 2. Architecture

```
chapters/*.md  ──▶  ./buaa/scripts/build.sh
                         │  (sorted filename order)
                         ▼
              Pandoc (--defaults buaa/pandoc.yaml)
                         │  Lua filters → citeproc → bilingual-etal
                         ▼
              buaa/buaa.cls
                ├── core/          shared packages, layout, metadata, hooks
                ├── font/setup.tex bundled CJK + Times + math
                └── reports/<profile>/setup.tex
                         │
                         ▼
              XeLaTeX  ──▶  PDF
```

| Piece | Path | Role |
|-------|------|------|
| Metadata + chapters | `chapters/*.md` | Sorted by filename; `00-meta.md` first |
| Bibliography | `references.bib` | Zotero Better BibTeX export |
| Reading notes | `literatures/` | Optional Zotero Integration notes |
| Pandoc defaults | `buaa/pandoc.yaml` | Reader, engine, filters |
| Class loader | `buaa/buaa.cls` | Thin loader → core + report profile |
| Shared LaTeX | `buaa/core/*.tex` | Options, packages, layout, hooks, document lifecycle |
| Report profiles | `buaa/reports/{thesis,coursework,generic}/` | Front/back matter per document type |
| CSL | `buaa/gb-t-7714-2015-numeric-superscript.csl` | GB/T 7714-2015 numeric superscript |
| Filters | `buaa/scripts/*.lua` | Table widths, continued captions, TikZ, et al. |
| Build | `buaa/scripts/build.sh` | Collect `chapters/*.md` → Pandoc |

### Class load order (`buaa.cls`)

1. `core/input.tex` — path helpers + `\buaa@loadreport`
2. `core/options.tex` — class options (profile, degree, secrecy, …)
3. `ctexbook` — base class
4. `core/{packages,helpers,math,metadata,layout,hooks}.tex`
5. `reports/<profile>/setup.tex` — overrides hooks; inputs front/back fragments
6. `core/document.tex` — `\AtBeginDocument` / `\AfterEndPreamble` lifecycle

### `buaa/core/` modules

| File | Role |
|------|------|
| `input.tex` | `\buaa@input`, `\buaa@loadreport` |
| `options.tex` | Profile / degree / secrecy / library\|print / OS / STEM\|HSS |
| `packages.tex` | Package set, `\englogo`, `\BUAAThesisVer` |
| `helpers.tex` | Loads `buaa/font/setup.tex`; shared utilities |
| `math.tex` | Math / theorem setup |
| `metadata.tex` | `\Title`, `\Author`, `\Bib`, coursework fields, … |
| `layout.tex` | Fixed geometry, page styles, `\makecontextlist` |
| `hooks.tex` | Default stubs for profile hooks |
| `document.tex` | Begin-document / end-preamble lifecycle |

Defaults when options are omitted: profile `thesis`, degree `master`, `public`,
`library`, `mac`, `short`, `STEM`. The demo overrides degree to `professional`.

### Layout

```
thesis-root/
├── README.md
├── references.bib
├── 输出示例.pdf                ← checked-in build from this Markdown template
├── 官方示例.pdf                ← official BUAAThesis reference PDF (read-only)
├── Artifact.pdf                ← default name from ./buaa/scripts/build.sh
├── chapters/
│   ├── 00-meta.md              ← classoption + \Title / \Author / …
│   ├── 01-导读与配置.md         ← how to configure (demo)
│   ├── 02-语法示例.md           ← citations, tables, TikZ, math, algorithms (demo)
│   ├── 90-结论.md              ← \summary
│   ├── 91-参考文献.md          ← \buaareferences + ::: {#refs}
│   ├── 92-附录.md              ← \appendix
│   ├── 93-学术成果.md          ← \achievement
│   ├── 94-致谢.md              ← \acknowledgments
│   └── 95-作者简介.md          ← \biography
├── assets/                     ← thesis figures (png/jpg/…)
│   └── mac.jpg                 ← demo bitmap used in 02-语法示例.md
├── literatures/
│   ├── zotero_literature_template.md
│   └── <citekey>.md            ← example notes
└── buaa/
    ├── buaa.cls
    ├── pandoc.yaml
    ├── gb-t-7714-2015-numeric-superscript.csl
    ├── scripts/                ← build.sh + Lua filters
    ├── assets/logo-buaa.eps
    ├── font/ + setup.tex       ← SimSun/Hei/Kai/Fang, Xingkai, Times, Cambria Math
    ├── i18n/                   ← secret / degree / department strings (thesis)
    ├── core/                   ← shared infrastructure
    └── reports/
        ├── README.md
        ├── thesis/             ← graduate thesis (default)
        ├── coursework/         ← course / lab report
        └── generic/            ← minimal title + optional abstract + TOC
```

---

## 3. Demo chapters vs your thesis

| File | Demo purpose | When writing for real |
|------|----------------|------------------------|
| `00-meta.md` | Sample MBA / professional metadata | Replace with your title, author, dates, abstract |
| `01-导读与配置.md` | Full option reference for `00-meta` | Delete or rewrite as 引言 |
| `02-语法示例.md` | Copy-paste markup samples | Delete or keep a private cheat-sheet chapter |
| `90`–`95` | Short stubs for each back-matter command | Fill with real content |

Body files are numbered so lexical sort = thesis order (`01`…`89` main, `90+` back matter).
`build.sh` does not hard-code chapter names: any `chapters/*.md` is included.

---

## 4. Configuration

### 4.1 `buaa/pandoc.yaml` (build only)

```yaml
from: markdown+raw_tex+tex_math_dollars+pipe_tables
to: pdf
pdf-engine: xelatex
top-level-division: chapter
variables:
  lmodern: false
filters:
  - buaa/scripts/full-width-tables.lua
  - buaa/scripts/longtable-continued.lua
  - buaa/scripts/tikz.lua
  - citeproc
  - buaa/scripts/bilingual-etal.lua
```

- `raw_tex` is required for `\summary`, `\ref{…}`, `\footnote{…}`, etc.
- **citeproc is a filter** — do not also set `citeproc: true` or pass `--citeproc`.
- `lmodern: false` keeps Latin text on Times New Roman (`buaa/font/setup.tex`).

### 4.2 `chapters/00-meta.md` (document)

Demo `classoption` list:

```yaml
classoption:
  - fontset=none      # bundled fonts via buaa/font/setup.tex
  - professional      # master | professional | doctor | prodoctor
  - public            # secrecy
  - library           # library | print  (print adds blank verso pages)
  - mac
  - short             # short | long title block
  - STEM              # STEM | HSS heading style
  - thesis            # thesis | coursework | generic
```

Put cover fields in `header-includes` as LaTeX commands (`\Title`, `\Author`, `\Abstract`, …),
not as free YAML keys. Full tables of fields and commands: **`chapters/01-导读与配置.md`**.

Notes:

- Academic `master` / `doctor` also require `\Discipline` and `\Direction`.
- Page geometry is **fixed** in `buaa/core/layout.tex`. Later `\geometry{…}` is ignored.
- Load TikZ from `header-includes` if you use `luatikz` / `tikz` blocks.
- Degree / secrecy / library options primarily affect the `thesis` profile; other profiles ignore unused metadata.

### 4.3 Back-matter commands (thesis profile)

| Command | Page |
|---------|------|
| `\summary` | 结论 |
| `\buaareferences` … `\buaareferencesend` | Wrap citeproc `::: {#refs}` |
| `\appendix` | Appendix chapters from following `#` headings |
| `\achievement` | 学术成果 |
| `\acknowledgments` | 致谢 |
| `\biography` | 作者简介 |
| `\chaptera{标题}` | Extra unnumbered appendix-style chapter |

Front matter (covers, statement, abstract, TOC, optional lists) is built automatically by
the `thesis` profile after `\begin{document}`.

For `coursework` / `generic` command sets and required metadata, see
[`buaa/reports/README.md`](buaa/reports/README.md).

---

## 5. Writing syntax (see also `02-语法示例.md`)

### Citations

```markdown
[@jensen1976]
[@fama1983; @liweian2005]
```

CSL path in `00-meta.md`; bibliography in `references.bib`. Only **cited** entries appear
under 参考文献.

### Footnotes

Use LaTeX footnotes (not Pandoc `[^id]`):

```markdown
Sentence.\footnote{Note text.}
```

The class renders per-page circled markers (①②③…). See `chapters/02-语法示例.md`.

### Tables (Markdown-first)

```markdown
Table: Caption {#tab:id}

| Col A | Col B |
| ----- | ----- |
| …     | …     |
```

- Prefer pipe tables over hand-written `table` / `longtable`.
- Pandoc emits `longtable` (page breaks + repeated headers).
- `full-width-tables.lua` sets column widths; `longtable-continued.lua` adds `题注（续）`
  on continuation pages.
- Cross-ref: `\ref{tab:id}`.

### TikZ figures

````markdown
```luatikz
% caption: Title
% label: fig:id
\begin{tikzpicture}
…
\end{tikzpicture}
```
````

`tikz.lua` wraps captioned blocks in `figure`. Reference with `\ref{fig:id}` (not `@fig:…`).

### Markdown figures

```markdown
![Caption](assets/file.jpg){#fig:id width=90%}
```

Images live under `assets/` (paths relative to thesis root). Cross-ref: `\ref{fig:id}`.

### Math & algorithms

Inline `$…$`, display `$$…$$`, `align`, and `algorithm` environments are available.
Math font: Cambria Math when present under `buaa/font/`.

---

## 6. What the class already handles

- Bundled CJK (Song / Hei / Kai / Fang) + cover Xingkai + Times Latin + math
- Circled per-page footnotes; degree-specific running headers (`thesis`)
- `library` vs `print` pagination; chapter-wise 图/表 numbers (A.1 in appendices)
- Cover helpers: `\englogo{…}`, `\BUAAThesisVer{}`
- Shared TOC / figure-table lists via `\makecontextlist` (`buaa/core/layout.tex`)

---

## 7. Troubleshooting

| Symptom | Fix |
|---------|-----|
| Duplicate bibliography entries | citeproc enabled twice — keep only the filter in `pandoc.yaml` |
| Extra blank pages | Use `library` instead of `print` |
| TikZ won’t preview in Obsidian | Plain `` ```luatikz ``; put `% caption:` / `% label:` inside the block |
| Missing Chinese glyphs | Keep `buaa/font/` files; use `fontset=none` |
| `\geometry` seems ignored | Intended — margins are locked by the class |
| Long table page 2 lacks 「（续）」 | Ensure `longtable-continued.lua` is in `pandoc.yaml` |
| `buaa.cls` / `\input` not found | Run `./buaa/scripts/build.sh` from thesis root (it sets `TEXINPUTS`) |

---

## 8. New thesis checklist

1. Keep `buaa/` intact; edit `chapters/00-meta.md`.
2. Replace `01` / `02` with your chapters (`01-引言.md`, …).
3. Fill `90`–`95` (or drop unused back-matter files).
4. Point Zotero Better BibTeX at `references.bib`; cite with `[@citekey]`.
5. Optional: import notes via `literatures/zotero_literature_template.md`.
6. Build with `./buaa/scripts/build.sh`.
7. Other document types: set `coursework` or `generic` in `classoption`
   (see `buaa/reports/README.md`).

---

## 9. Environment (Obsidian + Zotero)

**System:** Zotero, MacTeX/TeX Live/MiKTeX (XeLaTeX), Pandoc ≥ 3.

**Zotero:** Better BibTeX → auto-export `references.bib`; stable citekeys
(e.g. `auth.lower+year`).

**Obsidian plugins:**

- Restored by `template-obsidian/restore-obsidian-plugins.sh <thesis-root>`
  (auto-detects vault↔thesis relative path and `pandoc` / `xelatex` / `lualatex`).
- **Shell commands** — `working_directory` = detected thesis-rel; command
  `./buaa/scripts/build.sh`; alias `Build thesis PDF`; PATH aug from detected tools.
- **Zotero Integration**, **LuaTikZ** — literature paths and `lualatexPath` set
  for the same target layout.

**Zotero Integration paths** (vault-relative; filled by restore):

- Notes: `{thesis-rel}/literatures/{{citekey}}.md` (or `literatures/…` if vault = thesis)
- Template: `{thesis-rel}/literatures/zotero_literature_template.md`
- Insert citations as `[@{{citekey}}]`

**LuaTikZ:** detected `lualatex` absolute path; Chinese preview preamble e.g.
`luatexja-fontspec` + `Songti SC`. Keep the plugin temp directory **off iCloud** if the
vault syncs through iCloud Drive.

---

## Provenance

Typography follows the official BUAAThesis **v4.1.0** series. Compare layout against
`官方示例.pdf`; this repo’s Markdown build is illustrated by `输出示例.pdf`. The modular
`buaa/` tree (`core/` + `reports/` + bundled `font/`) and Markdown workflow are maintained
for Obsidian-centric drafting. Class version string: `\BUAAThesisVer{}`
(`v4.1.0 modular` in `buaa/core/packages.tex`).

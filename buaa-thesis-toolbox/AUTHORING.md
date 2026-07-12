# Authoring & Troubleshooting

How to write chapters, front/back matter, figures, tables, math, and citations
for the modular BUAA Markdown thesis, plus a build-error table.

## Chapter files

Split under `chapters/`, numeric prefixes with leading zeros so lexical sort =
thesis order:

| Pattern | Role |
|---------|------|
| `00-meta.md` | Document metadata as `buaa` `\Command{}` calls in `header-includes` |
| `01-*.md` … `89-*.md` | Main chapters, sorted by filename |
| `90-*.md` and later | Back matter (结论 / 参考文献 / 附录 / …) |

The selected **report profile** auto-generates covers, declaration, abstract, and
TOC after `\begin{document}` — do **not** write a manual front-matter dump.

Demo template files (replace when writing for real):

| File | Demo purpose |
|------|----------------|
| `00-meta.md` | Sample professional / MBA metadata + TikZ packages |
| `01-导读与配置.md` | Full option / field reference |
| `02-语法示例.md` | Citations, footnotes, tables, TikZ, Markdown figures, math, algorithms |
| `90`–`95` | Stubs for each back-matter command |

`build.sh` does not hard-code chapter names: any `chapters/*.md` is included.

### Heading → structure (`top-level-division: chapter`)

| Markdown | Becomes | Numbering |
|----------|---------|-----------|
| `#` | 章 chapter | 第1章… |
| `##` | 节 section | 1.1… |
| `###` | 条 subsection | 1.1.1… |
| `####` | subsubsection | 1.1.1.1… |

### Back-matter commands (thesis profile; `raw_tex`)

| Command | Produces |
|---------|----------|
| `\summary` | 结论 (unnumbered) |
| `\buaareferences` + `::: {#refs}` + `\buaareferencesend` | 参考文献 heading + citeproc list |
| `\appendix` | Enter appendix mode; each following Markdown H1 → appendix chapter |
| `\achievement` | 攻读学位期间取得的学术成果 |
| `\acknowledgments` | 致谢 |
| `\biography` | 作者简介 |
| `\chaptera{标题}` | Extra unnumbered appendix-style chapter |
| `# 标题` after `\appendix` | Numbered appendix chapter (A, B, …) |

For `coursework` / `generic` command sets and required metadata, see
`buaa/reports/README.md`.

## Report profiles

Select in `chapters/00-meta.md` `classoption:`:

```yaml
classoption:
  - fontset=none
  - professional      # or master | doctor | prodoctor
  - public
  - library           # or print
  - mac
  - short
  - STEM
  - thesis            # or coursework | generic
```

| Option | Folder | Use |
|--------|--------|-----|
| `thesis` (default) | `buaa/reports/thesis/` | BUAA graduate thesis |
| `coursework` | `buaa/reports/coursework/` | Course / lab report |
| `generic` | `buaa/reports/generic/` | Minimal title + optional abstract + TOC |

Degree / secrecy / `library`/`print` mainly affect the **thesis** profile.

## Metadata reference (`\Command{}` in `00-meta.md`)

| Command | Args | Notes |
|---------|------|-------|
| `\Title{中}{en}` | title | |
| `\Subtitle{中}{en}` | subtitle | optional |
| `\Author{中}{en}` | author | |
| `\StudentID{...}` | student number | printed as `10006<id>` where applicable |
| `\Department{中}{en}` | school / department | Chinese and English names |
| `\Degree{en}` | English degree name | English cover |
| `\Major{中}` | major / discipline | |
| `\Feild{中}` | research field | class command is misspelled — use `Feild` |
| `\Discipline{中}` | first-level discipline | required for academic `master` / `doctor` |
| `\Direction{中}` | discipline direction | required for academic degrees |
| `\SpecialProg{中}` | special programme | optional |
| `\Tutor{中}{en}{职称}` | supervisor | 3rd arg = title/职称 |
| `\Cotutor{中}{en}{职称}` | co-supervisor | optional |
| `\CLC{...}` | CLC classification no. | |
| `\Branch{...}` | discipline category | e.g. 工商管理 / 工学 |
| `\Abstract{中}{en}` | abstract bodies | |
| `\Keyword{中}{en}` | keywords | 3–5, comma-separated, no trailing punctuation |
| `\Signs{...}` | main symbols table body | optional |
| `\Abbreviations{...}` | abbreviations table body | optional |
| `\DateEnroll/\DateGraduate/\DateSubmit/\DateDefence{m}{d}{y}` | dates | |
| `\Listfigtab{on}` | toggle list of figures/tables | |
| `\emptypagewords{...}` | blank-page placeholder text | |
| `\refcolor{off}` | citation link color | |
| `\englogo{...}` / `\BUAAThesisVer{}` | cover helpers | version string from `core/packages.tex` |

### Class options (`classoption:`)

| Group | Values | Meaning |
|-------|--------|---------|
| Fonts | `fontset=none` | **Required** — bundled fonts via `buaa/font/setup.tex` |
| Degree | `master` · `professional` · `doctor` · `prodoctor` | master's / prof. master's / doctoral / prof. doctoral |
| Secrecy | `public` · `privacy` · `secret[…]` · `classified[…]` · `topsecret[…]` | 密级 on cover |
| Output | `library` · `print` | `print` adds blank verso pages between major parts |
| OS | `win` · `linux` · `mac` | OS / font hint |
| Title length | `short` · `long` | title-page information block |
| Subject family | `STEM` · `HSS` | decimal STEM headings or HSS headings |
| Report profile | `thesis` · `coursework` · `generic` | front/back matter set |

Figures and tables are numbered by chapter (`1.1`, `1.2`, …). Appendix chapters
use `A.1`, `A.2`, ….

Page geometry is **locked** in `buaa/core/layout.tex` — later `\geometry{…}` is ignored.

## Pandoc defaults (`buaa/pandoc.yaml`)

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

- `raw_tex` is required for back-matter commands, `\ref{}`, `\footnote{}`.
- **citeproc is a filter** — do not also set `citeproc: true` or pass `--citeproc`.
- `lmodern: false` keeps Latin on Times New Roman (`buaa/font/setup.tex`).
- Filter order matters: citeproc must run **before** `bilingual-etal.lua`.

## Figures — TikZ

Write a **plain** `luatikz` block so Obsidian LuaTikZ previews it live. For a
numbered, cross-referenceable PDF figure, add `% caption:` / `% label:` comment
lines at the top (Obsidian ignores them; `buaa/scripts/tikz.lua` reads them):

````markdown
```luatikz
% caption: TikZ circle example
% label: fig:tikz-circle
\begin{tikzpicture}
\draw (0,0) circle (1cm);
\end{tikzpicture}
```
````

⚠️ **Do not put a LaTeX float inside the fence.** Obsidian LuaTikZ only renders
`tikzpicture` (plus optional `\usetikzlibrary{…}`). Wrapping
`\begin{figure}…\caption{…}\label{…}\end{figure}` (or a raw
```` ```{=latex} ```` figure dump) **breaks live preview** — the block stays blank
or shows source. Caption/label belong in `% caption:` / `% label:` comments;
`tikz.lua` wraps the PDF export in `figure` for you.

| OK in `luatikz` | Not OK in `luatikz` (use comments / let the filter wrap) |
|-----------------|---------------------------------------------------------|
| `\usetikzlibrary{…}` (preview needs it; PDF strip is fine — also load in `00-meta`) | `\begin{figure}` / `\end{figure}` |
| `\begin{tikzpicture}…\end{tikzpicture}` | `\caption{…}` / `\label{…}` / `\centering` |
| `% caption:` / `% label:` comment lines | Pandoc fence attrs like `` ```{=latex} `` or `` ```luatikz {.foo} `` |

Reference with `\ref{fig:tikz-circle}` — **not** `@fig:…` (that collides with
citeproc). `tikz.lua`: accepts `tikz`/`luatikz`; with caption/label wraps in a
`figure` float, else a `center` block; strips a stray `standalone` preamble
(`\documentclass` / `\usepackage` / `\usetikzlibrary`) and `\begin{document}` /
existing float wrappers, so a full standalone preview block still exports.

Load libraries once in `00-meta.md`:

```yaml
header-includes:
  - \usepackage{tikz}
  - \usetikzlibrary{arrows.meta,positioning,fit,backgrounds}
```

**CJK text inside figures: use `\rmfamily` (Song/宋体), not bold.** Under
ctex, Chinese `\sffamily` maps to **黑体** — heavy strokes that look bold. Prefer
`font=\rmfamily\small` and avoid `\sffamily` / `\bfseries` for figure labels.

**Do not use `\songti` in TikZ blocks.** It is defined in the thesis PDF build
via `buaa/font/setup.tex`, but Obsidian's LuaTikZ preview uses
`standalone + luatexja-fontspec` (no ctex), where `\songti` is undefined.
`\rmfamily` works in both environments.

## Figures — Markdown (raster / bitmap)

Prefer Pandoc image syntax over hand-written `\includegraphics` floats. Put
files under thesis-root `assets/` (paths relative to the thesis root, not
`chapters/`).

```markdown
![Caption](assets/file.jpg){#fig:id width=90%}
```

- Alt text becomes the figure caption; `{#fig:id}` becomes `\label{fig:id}`.
- Optional attributes: `width=90%`, `height=…`.
- Cross-ref with `\ref{fig:id}` — **not** `@fig:…` (collides with citeproc).
- Demo: `template/assets/mac.jpg` → `![…](assets/mac.jpg){#fig:mac-demo …}` in
  `02-语法示例.md`.

Remote URLs may fail under XeLaTeX — download into `assets/` first. Cover logo
(`buaa/assets/logo-buaa.eps`) stays under `buaa/assets/` for the class; body
figures belong in thesis-root `assets/`.

For subfigures, use the loaded `subcaption` package (`\subcaptionbox` or the
`subfigure` environment). Do not load the obsolete `subfigure` package.

## Tables

Pipe tables with an optional `Table:` caption line (Markdown-first; prefer over
hand-written `table` / `longtable`):

```markdown
Table: Caption {#tab:id}

| Metric | Meaning | Note |
| ------ | ------- | ---- |
| A      | …       | …    |
```

- Pandoc emits `longtable` (page breaks + repeated headers).
- `full-width-tables.lua` measures columns (CJK width 2), assigns proportional
  widths clamped to 6–50.
- `longtable-continued.lua` adds `题注（续）` on continuation pages.
- Cross-ref: `\ref{tab:id}`.
- Cell/caption fonts come from `buaa/core/layout.tex` (五号宋体).

## Math

Inline `$…$`, display `$$…$$` (via `tex_math_dollars`). Math font: **Cambria Math**
when `buaa/font/Cambria Math.ttf` is present; otherwise STIX Two Math fallback.
`theorem` / `definition` / `example` / `remark` environments are predefined
(numbered per chapter). Algorithm environments are available in the demo chapter.

## Citations

1. Manage in Zotero; keep `references.bib` auto-exported (Better BibTeX, Keep updated).
2. Cite: single `[@jensen1976]`; multiple `[@fama1983; @liweian2005]`.
3. citeproc + GB/T 7714-2015 numeric-superscript CSL render superscript numbers.
   Wrap `::: {#refs}` with `\buaareferences` and `\buaareferencesend`.
4. Only **cited** entries appear — normal citeproc behavior.
5. CSL path and bibliography path live in `00-meta.md` YAML
   (`csl: ./buaa/gb-t-7714-2015-numeric-superscript.csl`,
   `bibliography: ./references.bib`).

Never enable citeproc twice (filter *and* `--citeproc` / `citeproc: true`).

## Export-friendliness

Avoid emoji-style Unicode in TikZ/source: use `1/2/3` not `①②③`, `->` not `→`,
`...` not `⋯`/`…`. Circled footnote markers in the PDF are produced by the class,
not by typing ① in Markdown.

## Build

```bash
cd /path/to/thesis-root
./buaa/scripts/build.sh              # Artifact.pdf
./buaa/scripts/build.sh custom.pdf
```

From Obsidian, use the **Shell commands** plugin with working directory = thesis
root and the same `./buaa/scripts/build.sh` (see SETUP.md).

The script:

1. Resolves thesis root as parent of `buaa/`.
2. Sets `TEXINPUTS="${ROOT}/buaa//:…"` so `buaa.cls` and `\input` trees load.
3. Collects `chapters/*.md` in sorted order.
4. Runs `pandoc … --defaults ./buaa/pandoc.yaml -o <output>`.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Every reference appears twice | citeproc on twice | Keep only the `citeproc` filter in `pandoc.yaml`; remove `--citeproc` / `citeproc: true` |
| Unexpected blank pages | `print` inserts blank verso pages | Use `library` for electronic/library output |
| TikZ won't preview in Obsidian | `\begin{figure}`/`\caption`/`\label` inside the fence, or Pandoc fence attrs | Plain `` ```luatikz ``; **only** `tikzpicture` (+ optional `\usetikzlibrary`); put `% caption:` / `% label:` at top — never wrap a float |
| Long table page 2 lacks 「（续）」 | Missing filter | Ensure `longtable-continued.lua` is in `pandoc.yaml` |
| `buaa.cls` / `\input` not found | Wrong cwd or no `TEXINPUTS` | Run `./buaa/scripts/build.sh` from thesis root |
| Chinese missing / tofu boxes | Missing bundled fonts | Keep `buaa/font/` intact; use `fontset=none` |
| Latin looks like LM / cramped caps | `lmodern` stole Latin | Keep `variables.lmodern: false` in `pandoc.yaml` |
| `\geometry` seems ignored | Margins locked by class | Intended — edit `buaa/core/layout.tex` only if you must |
| `Can be used only in preamble` | font setup called too late | Don't move font setup to `begindocument/end` |
| `You have requested document class '../buaa'…` | `../` path vs internal name | Harmless warning; ignore |
| `Label 'ref-…' multiply defined` | same source labeled twice by citeproc | Harmless; or de-duplicate citation |
| Remote image fails | XeLaTeX can't fetch URLs | Download to thesis-root `assets/`, use `![…](assets/…){#fig:id}` |
| Wrong profile front matter | Missing / wrong class option | Set `thesis` / `coursework` / `generic` in `00-meta.md` |

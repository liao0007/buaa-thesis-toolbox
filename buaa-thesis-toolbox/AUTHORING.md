# Authoring & Troubleshooting

How to write chapters, front/back matter, figures, tables, math, and citations
for the BUAA Markdown thesis, plus a build-error table.

## Chapter files

Split under `chapters/`, numeric prefixes with leading zeros so lexical sort =
thesis order:

| Pattern | Role |
|---------|------|
| `00-meta.md` | Thesis metadata as `buaa.cls` `\Command{}` calls in `header-includes` |
| `01-*.md` … `89-*.md` | Main chapters, sorted by filename |
| `90-*.md` and later | Back matter (结论 / 参考文献 / 附录 / …) |

`buaa.cls` auto-generates covers, declaration, abstract, and TOC after
`\begin{document}` — do **not** write `\BuaaFrontMatter`.

### Heading → structure (top-level-division: chapter)

| Markdown | Becomes | Numbering |
|----------|---------|-----------|
| `#` | 章 chapter | 第1章… |
| `##` | 节 section | 1.1… |
| `###` | 条 subsection | 1.1.1… |
| `####` | subsubsection | 1.1.1.1… |

### Back-matter commands (written raw in the body via `raw_tex`)

| Command | Produces |
|---------|----------|
| `\summary` | 结论 (unnumbered) |
| `\chaptera{参考文献}` + `::: {#refs}\n:::` | 参考文献 heading + citeproc list |
| `\appendix` | 附录 (figures/tables switch to A.1, A.2) |
| `\achievement` | 攻读学位期间取得的学术成果 |
| `\acknowledgments` | 致谢 |
| `\biography` | 作者简介 |
| `\chaptera{标题}` | custom unnumbered chapter |

## Metadata reference (`\Command{}` in `00-meta.md`)

| Command | Args | Notes |
|---------|------|-------|
| `\Title{中}{en}` | title | |
| `\Subtitle{中}{en}` | subtitle | optional |
| `\Author{中}{en}` | author | |
| `\StudentID{...}` | student number | printed as `10006<id>` |
| `\Department{中}` | school / department | English auto-translated for known schools |
| `\Major{中}` | major / discipline | |
| `\Feild{中}` | research field | class command is misspelled — use `Feild` |
| `\Tutor{中}{en}{职称}` | supervisor (3rd arg = title/职称) | |
| `\Cotutor{中}{en}{职称}` | co-supervisor | optional |
| `\CLC{...}` | CLC classification no. | |
| `\Branch{...}` | discipline category | defaults to 工学 (Engineering) |
| `\Abstract{中}{en}` | abstract bodies | |
| `\Keyword{中}{en}` | keywords | 3–5, comma-separated, no trailing punctuation |
| `\DateEnroll/\DateGraduate/\DateSubmit/\DateDefence{m}{d}{y}` | dates | |
| `\Listfigtab{on}` | toggle list of figures/tables | |

### Class options (`classoption:`)

| Group | Values | Meaning |
|-------|--------|---------|
| Degree | `master` · `professional` · `doctor` · `prodoctor` | master's / prof. master's / doctoral / prof. doctoral |
| Print | `oneside` · `twoside` | single/double-sided |
| Secrecy | `public` · `privacy` · `secret[3/5/10/*]` · `classified[…]` · `topsecret[…]` | secrecy level (密级) on cover |
| Fonts | `fontset=fandol` | recommended for Pandoc+XeLaTeX |

## Figures — TikZ

Write a **plain** `luatikz` block so Obsidian LuaTikZ previews it live. For a
numbered, cross-referenceable PDF figure, add `% caption:` / `% label:` comment
lines at the top (Obsidian ignores them; `scripts/tikz.lua` reads them):

````markdown
```luatikz
% caption: TikZ circle example
% label: fig:tikz-circle
\begin{tikzpicture}
\draw (0,0) circle (1cm);
\end{tikzpicture}
```
````

Reference with `\ref{fig:tikz-circle}` — **not** `@fig:…` (that collides with
citeproc). `tikz.lua`: accepts `tikz`/`luatikz`; with caption/label wraps in a
`figure` float, else a `center` block; strips a stray `standalone` preamble
(`\documentclass` / `\usepackage` / `\usetikzlibrary`) and `\begin{document}` /
existing float wrappers, so a full standalone preview block still exports.
Libraries load once in `00-meta.md`:

```yaml
header-includes:
  - \usepackage{tikz}
  - \usetikzlibrary{arrows.meta,positioning,fit,backgrounds}
```

**CJK text inside figures: use `\rmfamily` (Song/宋体), not bold.** Under
`ctexbook + fontset=fandol`, Chinese `\sffamily` (sans) maps to **FandolHei
(黑体)** — heavy strokes that look bold. So set node fonts like
`font=\rmfamily\small` and avoid `\sffamily` and `\bfseries` (otherwise figure
text exports as "bold" and clashes with the Song body text).

**Do not use `\songti`.** It is a ctex-only command, defined only in the thesis
PDF build. Obsidian's LuaTikZ preview uses `standalone + luatexja-fontspec` (no
ctex), where `\songti` raises `Undefined control sequence` and the preview
fails. `\rmfamily` is a LaTeX core command valid in both environments: ctex maps
it to the CJK main font (Song), the luatexja preview maps it to mincho (Song) —
both non-bold.

## Figures — raster

```markdown
![figure caption example](../assets/example.png)
```

Prefer local files under `assets/` (class sets `\graphicspath` to `../assets/`
and `assets/`). Remote URLs may fail under XeLaTeX — download first.

## Tables

Pipe tables with an optional `Table:` caption line. `full-width-tables.lua`
measures each column (CJK counted as width 2), assigns proportional widths
clamped to 6–50, so one long cell can't blow out the layout. Rendered in
5-point Song (5号宋体), 1.2 line spacing.

```markdown
Table: example table

| Metric | Meaning | Note |
| ------ | ------- | ---- |
| A      | …       | …    |
```

## Math

Inline `$…$`, display `$$…$$` (via `tex_math_dollars`), typeset with STIX Two
Math by default. `theorem` / `definition` / `example` / `remark` environments
are predefined (numbered per chapter).

## Citations

1. Manage in Zotero; keep `references.bib` auto-exported (Better BibTeX, Keep updated).
2. Cite: single `[@bilgihan2025]`; multiple `[@google; @googlea]`.
3. citeproc + GB/T 7714-2015 numeric-superscript CSL render superscript numbers
   and build the list at `::: {#refs}` under `\chaptera{参考文献}`.
4. Only cited entries appear — normal citeproc behavior.

Never enable citeproc twice (YAML *and* `--citeproc`), or entries double.

## Export-friendliness

Avoid emoji-style Unicode in TikZ/source: use `1/2/3` not `①②③`, `->` not `→`,
`...` not `⋯`/`…`.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Every reference appears twice | citeproc on twice | Keep it only in YAML/defaults; remove `--citeproc` from plugin args |
| Blank page after 结论 (Conclusion) | `\cleardoublepage` under `twoside` | Already fixed in `buaa.cls` (`\clearpage`); re-copy the class if reverted |
| TikZ won't preview in Obsidian | Pandoc fence attributes on the fence line | Use a plain `luatikz` block; put caption/label as `%` comment lines inside |
| `Can be used only in preamble` | font setup called too late | Don't move font setup to `begindocument/end`; class uses `begindocument/before` + unicode-math hook |
| `Missing \begin{document}` at a bare `}` | `\@removefromreset` bare in preamble | Keep inside `\AtBeginDocument{\makeatletter … \makeatother}` |
| `You have requested document class '../buaa'…` | `../` path vs internal name | Harmless warning; ignore |
| `Label 'ref-…' multiply defined` | same source labeled twice by citeproc | Harmless; or de-duplicate citation |
| Chinese missing / tofu boxes | no CJK font installed | Install a font (SETUP §Fonts) or set `CJKmainfont`/`CJKsansfont` |
| Remote image fails | XeLaTeX can't fetch URLs | Download to `assets/`, use local path |

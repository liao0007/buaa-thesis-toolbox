# BUAA Markdown Thesis Template (`buaa`)

A Markdown-first workflow for writing a Beihang University (BUAA) master's / doctoral
thesis in Obsidian and exporting a standards-compliant PDF through Pandoc + XeLaTeX.

You write plain Markdown in Obsidian (with live math, TikZ, and citation previews),
and a single Pandoc command turns it into a fully formatted thesis PDF — cover pages,
Chinese fonts, per-page circled footnotes, superscript GB/T 7714 citations, headers,
and the standard back matter (结论 / 参考文献 / 附录 / 致谢 …).

---

## 1. How it fits together

```
chapters/*.md ──▶ build-thesis.sh ──▶ Pandoc ──▶ LaTeX(buaa.cls) ──▶ XeLaTeX ──▶ thesis.pdf
      │                                           │
      └─ 00-meta.md + sorted chapter files       buaa.cls formats covers/front matter
```

| Layer | File | Role |
|-------|------|------|
| Draft | `chapters/*.md` | Thesis metadata and content split into sorted chapter files |
| Pandoc defaults | `pandoc-thesis.yaml` | Minimal shared build settings: reader, PDF engine, citeproc, chapter division, filters |
| Document class | `buaa.cls` | All BUAA formatting: fonts, covers, headers, TOC, captions, back matter |
| Citation style | `gb-t-7714-2015-numeric-superscript.csl` | GB/T 7714-2015 numeric superscript |
| Bibliography | `references.bib` | Auto-exported from Zotero (Better BibTeX) |
| TikZ filter | `scripts/tikz.lua` | Turns ` ```luatikz ` / ` ```tikz ` blocks into figures |
| Table filter | `scripts/full-width-tables.lua` | Auto-sizes table column widths from content |

### Folder layout

```
thesis-root/
├── README.md                     ← this file
├── buaa.cls                      ← the thesis class
├── pandoc-thesis.yaml            ← Pandoc --defaults file
├── references.bib                ← Zotero-exported bibliography
├── gb-t-7714-2015-numeric-superscript.csl  ← GB/T 7714-2015 citation style
├── thesis.md                     ← split-build pointer note
├── thesis.pdf                    ← compiled thesis
├── chapters/
│   ├── 00-meta.md                ← thesis-specific LaTeX metadata commands
│   ├── 01-引言.md
│   └── ...
├── literatures/                  ← per-source literature notes
├── scripts/
│   ├── build-thesis.sh            ← sorted multi-file Pandoc build
│   ├── tikz.lua                   ← TikZ code-block filter
│   └── full-width-tables.lua      ← table column-width filter
└── assets/
    ├── logo-buaa.eps
    └── head-*.eps
```

---

## 2. Compiling

### Command line (canonical)

```bash
cd /path/to/thesis-root
./scripts/build-thesis.sh
```

The build script collects every `chapters/*.md` file, sorts them by file name, and
passes them to Pandoc in that order:

```bash
pandoc \
  "chapters/00-meta.md" \
  "chapters/01-引言.md" \
  "chapters/02-文献综述.md" \
  "..." \
  "chapters/91-参考文献.md" \
  --defaults "./pandoc-thesis.yaml" \
  -o "thesis.pdf"
```

That single `--defaults` file already sets the input extensions, `xelatex`, `citeproc`,
the two Lua filters, and `variables.indent: true` so Pandoc does not load `parskip`.

> **Always run from the thesis root.** All relative paths (`./assets/…`,
> `./references.bib`, `./scripts/…`) are resolved from that directory.

### Chapter files

The current thesis is split under `chapters/`:

| File pattern | Role |
|--------------|------|
| `00-meta.md` | Thesis-specific `buaa.cls` metadata commands in `header-includes` |
| `01-*.md` to `89-*.md` | Main thesis chapters, sorted by file name |
| `90-*.md` and later | Back matter such as 结论, 参考文献, 附录, 致谢 |

Use numeric prefixes with leading zeroes so lexical sort matches thesis order.
The root `thesis.md` file is now only a human-readable pointer to this split workflow.

### From Obsidian (Obsidian Pandoc plugin)

The plugin is configured in `.obsidian/plugins/obsidian-pandoc/data.json` with:

```
--defaults=/absolute/path/to/thesis-root/pandoc-thesis.yaml
```

Do not add `--citeproc`, `--csl`, `--pdf-engine`, or `--lua-filter` again in plugin
arguments if `--defaults=.../pandoc-thesis.yaml` is already present.

### Requirements

- MacTeX / TeX Live with **XeLaTeX** (`ctexbook`, `fontspec`, `unicode-math`, `tikz`).
- **Pandoc** ≥ 3.x.
- Fonts (any one per slot; the class falls back automatically):
  - CJK serif 正文: SimSun / STSong / **Songti SC** / FandolSong / Noto Serif CJK SC
  - CJK sans 黑体: SimHei / STHeiti / **Heiti SC** / FandolHei / Noto Sans CJK SC
  - Latin: **Times New Roman** / TeX Gyre Termes
  - Math: XITS Math / **STIX Two Math** / TeX Gyre Termes Math

---

## 3. The draft files (`chapters/*.md`)

### 3.1 Defaults vs thesis metadata

Only the settings that work best as Pandoc defaults stay in `pandoc-thesis.yaml`:

```yaml
from: markdown+raw_tex+tex_math_dollars+pipe_tables
to: pdf
pdf-engine: xelatex
citeproc: true
top-level-division: chapter
filters:
  - scripts/full-width-tables.lua
  - scripts/tikz.lua
```

Most thesis and export configuration is centralized in `chapters/00-meta.md`:

```yaml
---
bibliography: ./references.bib
classoption:
  - fontset=fandol
  - master
  - public
  - twoside
csl: ./gb-t-7714-2015-numeric-superscript.csl
documentclass: buaa
indent: true
link-citations: true
numbersections: true
header-includes:
  - \Title{北航硕士学位论文}{LATEX Template of Beihang University Thesis}
  - \Author{廖亮}{Liao Liang}
  - \Department{经济管理学院}
  - \Major{工商管理}
  - \Feild{公司治理}
  - ...
---
```

Key points:

- `from: markdown+raw_tex+…` — **`raw_tex` is required** so inline commands like
  `\summary`, `\chaptera{参考文献}`, `\ref{…}`, `\footnote{…}` pass straight through.
- `fontset=fandol` avoids local macOS CJK font lookup failures while still defining
  the `\songti` and `\heiti` commands used by `buaa.cls`.
- `citeproc: true` must stay in `pandoc-thesis.yaml`; when it is placed only in
  `00-meta.md`, Pandoc does not run the citeproc processing stage early enough.
- `to: pdf`, `pdf-engine: xelatex`, `from`, `top-level-division`, and Lua filters
  stay in `pandoc-thesis.yaml` because they are build execution settings rather than
  document metadata.
- Put thesis metadata inside `header-includes` as `\Command{}` calls, **not** as loose
  YAML keys — the class reads them via LaTeX, and the plugin mishandles spaces/backslashes
  in the extra-arguments field.

### 3.2 Body structure

Because `pandoc-thesis.yaml` sets `top-level-division: chapter`:

| Markdown | Becomes | Numbering (science/engineering decimal) |
|----------|---------|-----------|
| `#` | 章 (chapter) | 第1章、第2章… |
| `##` | 节 (section) | 1.1、1.2… |
| `###` | 条 (subsection) | 1.1.1、1.1.2… |
| `####` | (subsubsection) | 1.1.1.1… |

Chapter headings render centered as `第N章  标题`; running headers show
`第N章 标题`. Figures/tables are numbered continuously (图1, 图2, 表1) in the
main body and switch to A.1/A.2 in the appendix.

### 3.3 Front matter and back matter commands

These `\Command{}` macros come from `buaa.cls` and are written directly in the Markdown
body (thanks to `raw_tex`):

| Command | Produces |
|---------|----------|
| *(none)* | `buaa.cls` automatically generates cover pages, declaration, abstract, and TOC after `\begin{document}`. Do not write `\BuaaFrontMatter`. |
| `\summary` | 结论 (unnumbered chapter) |
| `\chaptera{参考文献}` | 参考文献 heading for Pandoc citeproc output |
| `\appendix` | 附~~录 (switches figures/tables to A.1, A.2 numbering) |
| `\achievement` | 攻读硕士学位期间取得的学术成果 |
| `\acknowledgments` | 致谢 |
| `\biography` | 作者简介 |
| `\chaptera{标题}` | A custom unnumbered appendix-style chapter |

The bibliography itself is emitted by citeproc where you place the div:

```markdown
\chaptera{参考文献}

::: {#refs}
:::
```

---

## 4. Thesis metadata reference (`\Command{}`)

### 4.1 Content commands

| Command | Arguments | Notes |
|---------|-----------|-------|
| `\Title{中}{en}` | Chinese / English title | |
| `\Subtitle{中}{en}` | subtitle | optional |
| `\Author{中}{en}` | author name | |
| `\StudentID{...}` | student number | printed as `10006<id>` |
| `\Department{中}` | school / department | English school name is translated by `buaa.cls` for known schools |
| `\Major{中}` | major / discipline | |
| `\Feild{中}` | research field | The class command is misspelled as `Feild`; use that spelling |
| `\Tutor{中}{en}{职称}` | supervisor + title (职称) | |
| `\Cotutor{中}{en}{职称}` | co-supervisor | optional |
| `\CLC{...}` | CLC classification no. | |
| `\Branch{...}` | discipline category (e.g. 工学 Engineering) | defaults to 工学 |
| `\Abstract{中文摘要}{English abstract}` | abstract bodies (Chinese / English) | |
| `\Keyword{中文关键词}{English keywords}` | keywords (Chinese / English) | |
| `\DateEnroll{m}{d}{y}` … | enroll / submit / defence dates | `\DateGraduate`, `\DateSubmit`, `\DateDefence` |

### 4.2 Class options (`classoption:`)

| Group | Values | Meaning |
|-------|--------|---------|
| Degree | `master` · `professional` · `doctor` · `prodoctor` | master's / prof. master's / doctoral / prof. doctoral (affects cover + header text) |
| Print | `oneside` · `twoside` | single/double-sided layout & headers |
| Secrecy | `public` · `privacy` · `secret[3/5/10/*]` · `classified[…]` · `topsecret[…]` | secrecy level (密级) label on cover |
| Fonts | `fontset=fandol` | recommended for stable Pandoc + XeLaTeX export |

---

## 5. Figures, TikZ, tables, math

### 5.1 TikZ (Obsidian preview + PDF export)

Write a **plain** `luatikz` block so the Obsidian LuaTikZ plugin can render it live:

````markdown
```luatikz
\begin{tikzpicture}
\draw (0,0) circle (1cm);
\end{tikzpicture}
```
````

For a **numbered, captioned, cross-referenceable** figure in the PDF, add two LaTeX
comment lines at the top of the block. Obsidian ignores them (they're `%` comments),
but `scripts/tikz.lua` reads them:

````markdown
```luatikz
% caption: TikZ circle example
% label: fig:tikz-circle
\begin{tikzpicture}
\draw (0,0) circle (1cm);
\end{tikzpicture}
```
````

Then reference it in text with `\ref{fig:tikz-circle}` (use `\ref{…}`, **not** `@fig:…`,
which would collide with citeproc).

What `tikz.lua` does:
- Accepts block classes `luatikz` or `tikz`.
- Reads `% caption:` / `% label:` lines (or Pandoc attributes `{#fig:x caption="…"}`).
- With a caption/label → wraps in `\begin{figure}[htbp]\centering … \caption{} \label{} \end{figure}`.
- Without → wraps in `\begin{center} … \end{center}` (no number).
- Strips a stray `standalone` preamble (`\documentclass`, `\usepackage`,
  `\usetikzlibrary`) plus `\begin{document}` / existing float wrappers, so a full
  standalone-style preview block still exports.

TikZ libraries are loaded once in the draft YAML:

```yaml
header-includes:
  - \usepackage{tikz}
  - \usetikzlibrary{arrows.meta,positioning,fit,backgrounds}
```

**CJK text inside figures: use `\rmfamily` (Song/宋体), not bold.** Under
`ctexbook + fontset=fandol`, Chinese `\sffamily` (sans) maps to **FandolHei (黑体)**
— heavy strokes that look bold. Set node fonts like `font=\rmfamily\small` and avoid
`\sffamily` / `\bfseries`, otherwise figure text exports as "bold" and clashes with the
Song body text. **Do not use `\songti`**: it is a ctex-only command, and Obsidian's
LuaTikZ preview (`standalone + luatexja-fontspec`, no ctex) raises `Undefined control
sequence` and fails to preview. `\rmfamily` is a LaTeX core command that maps to Song
(non-bold) in both the ctex build and the luatexja preview.

### 5.2 Raster images

```markdown
![figure caption example](../assets/example.png)
```

Prefer local files under `assets/` (the class sets `\graphicspath` to `../assets/` and
`assets/`). Remote URLs may fail under XeLaTeX — download them first.

### 5.3 Tables

Use pipe tables with an optional `Table:` caption line. `full-width-tables.lua`
measures each column's content (CJK counted as width 2) and assigns proportional widths,
clamped to a 6–50 range, so one long cell can't blow out the layout. Tables render in
5-point Song (5号宋体) with 1.2 line spacing.

```markdown
Table: example table

| Metric | Meaning | Note |
| ------ | ------- | ---- |
| A      | …       | …    |
```

### 5.4 Math

Inline `$…$` and display `$$…$$` (via `tex_math_dollars`), typeset with the math font
(`STIX Two Math` by default). `\begin{theorem}`, `\begin{definition}`, `\begin{example}`,
`\begin{remark}` environments are predefined (numbered per chapter).

---

## 6. Citations

1. Manage sources in Zotero; export the library as Better BibTeX to `references.bib`
   with **Keep updated** on (see §10, Phase 2).
2. Cite in Markdown with Pandoc syntax:
   - single: `[@bilgihan2025]`
   - multiple: `[@google; @googlea]`
3. citeproc + the GB/T 7714-2015 numeric-superscript CSL render them as superscript
   numbers, and build the list at the `::: {#refs}` div under `\chaptera{参考文献}`.

Only cited entries appear in 参考文献 — that's normal citeproc behavior.

**Do not enable citeproc twice.** It must be on in exactly one place (the draft YAML /
`pandoc-thesis.yaml`), never also via a `--citeproc` command-line flag, or entries double.

---

## 7. Formatting the class already handles

- **Fonts** use `fontset=fandol`, so 正文 / 黑体 commands required by `buaa.cls`
  are available under Pandoc + XeLaTeX.
- **Footnotes**: per-page reset, circled numbers ①②③…, 小五号宋体.
- **Headers/footers**: 硕士/博士学位论文 running head, centered page number; distinct
  odd/even behavior under `twoside`.
- **Back matter** (结论/参考文献/附录/…): unnumbered chapters that break with
  `\clearpage` (not `\cleardoublepage`), so no stray blank page appears between them
  under `twoside`.
- **Figure/table numbering**: continuous (1, 2, 3…) in the main body, switching to
  A.1, A.2 in the appendix.
- **Captions**: 图/表 label in 5号宋体 bold, centered.

---

## 8. Troubleshooting

| Symptom                                        | Cause                                                     | Fix                                                                                                           |
| ---------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Every reference appears twice                  | citeproc enabled twice (YAML *and* `--citeproc`)          | Keep it only in YAML/defaults; remove `--citeproc` from the plugin args                                       |
| Blank page after 结论                            | `\cleardoublepage` forcing odd-page start under `twoside` | Already fixed in `buaa.cls` (`\clearpage` + `\@openrightfalse`); re-copy the class if you reverted it         |
| TikZ won't preview in Obsidian                 | Pandoc fence attributes on the fence line                 | Use a plain ` ```luatikz ` block; put caption/label as `% caption:` / `% label:` lines inside                 |
| `Can be used only in preamble`                 | `\setmathfont` / `\setCJKmainfont` called too late        | Don't move font setup to `begindocument/end`; the class uses `begindocument/before` + the `unicode-math` hook |
| `Missing \begin{document}` at a bare `}`       | `\@removefromreset` placed bare in preamble               | Keep it inside the `\AtBeginDocument{\makeatletter … \makeatother}` block                                     |
| `You have requested document class '../buaa'…` | `../` path prefix vs internal name                        | Harmless warning; ignore                                                                                      |
| `Label 'ref-…' multiply defined`               | Same source cited in ways citeproc labels twice           | Harmless; or de-duplicate the citation                                                                        |
| Chinese missing / tofu boxes                   | None of the CJK fonts installed                           | Install one of the §2 font options, or set `CJKmainfont`/`CJKsansfont` explicitly                             |
| Remote image fails                             | XeLaTeX can't fetch URLs                                  | Download to `assets/` and use a local path                                                                    |

---

## 9. Quick start for a new thesis

1. Copy or rename chapter files under `chapters/` using numeric prefixes.
2. Edit `chapters/00-meta.md` `header-includes` with your real title, author,
   supervisor, abstract, keywords, and dates.
3. Edit `pandoc-thesis.yaml` only for shared build options such as degree/secrecy
   `classoption`, bibliography, CSL, filters, or output engine.
4. Replace the skeleton chapters (`# 引言(章)` …) with your content; keep the
   `\summary` / `\chaptera{参考文献}` / `\appendix` / `\acknowledgments` back-matter commands.
5. Cite with `[@citekey]`; keep `references.bib` synced from Zotero.
6. Compile:
   ```bash
   cd /path/to/thesis-root
   ./scripts/build-thesis.sh
   ```
7. Check the generated PDF.

For full environment setup (Zotero, Better BibTeX, Obsidian plugins, LuaTikZ), see §10.

---

## 10. Environment setup (Obsidian, Zotero, LaTeX, Pandoc)

End-to-end setup for the Obsidian academic writing environment. Complete the phases in
order — Obsidian plugins depend on system-level tools such as Zotero, LaTeX, Pandoc, and
SVG converters.

### Phase 1: System-level prerequisites

- Install Zotero desktop for your operating system.
- Install a LaTeX distribution.
  - Windows: install MiKTeX or TeX Live.
  - macOS: install MacTeX.
  - Linux: install `texlive-full` through the system package manager.
- Install Pandoc from the official Pandoc GitHub releases page.
- Install or verify an SVG converter for TikZ rendering.
  - Prefer `pdf2svg` or `dvisvgm`.
  - Confirm whether `dvisvgm` is already included with MacTeX / TeX Live.
  - On Windows, install missing converters through Chocolatey or Scoop if needed.
- Verify command-line availability.
  - Run `pandoc -v` and confirm a version number appears.
  - Run `pdflatex -v` and confirm a version number appears.
  - If either command fails, add the installation directory to the system `PATH`.

### Phase 2: Zotero & bibliography configuration

- Install Better BibTeX for Zotero.
  - Download the latest `.xpi` release from the Better BibTeX GitHub repository.
  - In Zotero, open `Tools > Add-ons`.
  - Click the gear icon and select `Install Add-on From File`.
- Configure predictable citation keys.
  - Open `Zotero Preferences > Better BibTeX`.
  - Set citation key format to `auth.lower+year`, or another predictable pattern.
  - Confirm generated keys look like `smith2023`.
- Establish an auto-exported bibliography file.
  - In Zotero, select the primary library or collection.
  - Right-click and choose `Export Library`.
  - Select `Better BibTeX` as the export format.
  - Enable `Keep updated`.
  - Save the export as `thesis-root/references.bib`.
  - Confirm Zotero updates `references.bib` after adding or changing a reference.

### Phase 3: Obsidian vault structure & plugins

- Confirm the thesis vault folder structure exists.
  - `thesis-root/chapters`
  - `thesis-root/literatures`
  - `thesis-root/assets`
  - `thesis-root/scripts`
- In Obsidian, disable Safe Mode.
  - Go to `Settings > Community Plugins`.
  - Turn off Safe Mode.
- Install required community plugins.
  - Zotero Integration.
  - Obsidian Pandoc.
  - LuaTikZ for Obsidian live TikZ rendering.
  - Latex Suite.
  - Txt as MD.
- Enable all installed plugins.

### Phase 4: Obsidian plugin configuration

#### Zotero Integration

- Open `Settings > Zotero Integration`.
- Confirm the Zotero database path is detected correctly.
- Click `Add Import Format`.
- Name the format `Literature Note`.
- Set output path to `thesis-root/literatures/{{citekey}}.md`.
- Set imported annotation image path to `thesis-root/literatures/{{citekey}}/`.
- Set template file to your Zotero Nunjucks template location (e.g.
  `thesis-root/literatures/_template.njk`).
- Confirm imported notes include title, authors, year, URL, abstract, and annotations.
- Configure citation insertion as Pandoc citation format, bracketed as `[@{{citekey}}]`.
- Use `[[{{citekey}}]]` as the note suggestion template.

#### Obsidian Pandoc

- Open `Settings > Obsidian Pandoc`.
- Configure the Pandoc executable path.
  - Use `/opt/homebrew/bin/pandoc`.
- Configure the PDFLaTeX path.
  - Use `/Library/TeX/texbin/pdflatex`.
- Set export source format to `Markdown`.
- Add Pandoc extra arguments: `--defaults=/absolute/path/to/thesis-root/pandoc-thesis.yaml`.
- Use the repo-local Lua filters declared in `pandoc-thesis.yaml`.
- Do not put `-V header-includes=...` in Obsidian Pandoc extra arguments. Use document YAML `header-includes` instead, because the plugin argument field can mishandle backslashes, quoting, and spaces.
- Put thesis-specific metadata in `chapters/00-meta.md`, for example:

  ```yaml
  ---
  bibliography: ./references.bib
  documentclass: buaa
  classoption:
    - fontset=fandol
    - master
    - public
    - twoside
  header-includes:
    - \usepackage{tikz}
    - \usetikzlibrary{arrows.meta,positioning,fit,backgrounds}
  ---
  ```

- Keep font settings out of Obsidian Pandoc extra arguments when the font name contains spaces; the plugin splits extra arguments on spaces.
- Keep CSL style and bibliography paths in `chapters/00-meta.md`; do not put `--csl=...` or `--bibliography=...` in Obsidian Pandoc extra arguments.
- If a draft needs a LaTeX class file, keep that in document YAML too, for example:

  ```yaml
  ---
  documentclass: report
  classoption:
    - a4paper
    - oneside
  ---
  ```

- For this BUAA workflow, keep `buaa.cls`, `assets/`, and `pandoc-thesis.yaml` in the thesis root; do not add a class option globally in Obsidian Pandoc plugin settings.
- Keep TikZ package/library loading in each draft's YAML `header-includes`; write each diagram as a `tikz` code block containing `\begin{tikzpicture}` ... `\end{tikzpicture}`.
- Convert Mermaid diagrams in your chapter notes to TikZ code blocks when they need to appear in the thesis PDF.
- Keep TikZ/source text export-friendly by avoiding emoji-style Unicode symbols in chapter source files.
  - Replaced circled numbers `①②③④` with plain `1/2/3/4`.
  - Replaced Unicode arrow `→` with ASCII `->`.
  - Replaced midline ellipsis `⋯` / `…` with ASCII `...`.
  - Verified no emoji-style codepoints remain in TikZ-heavy source files for the scanned symbol ranges.
- Run a small Markdown-to-PDF export test with `./scripts/build-thesis.sh`.
- Verify the explicit Markdown-to-TeX-to-PDF path without command-line `header-includes` or command-line `--csl`.
  - Generated TeX: `/private/tmp/sample-yaml-csl/Sample.tex`.
  - Generated PDF: `/private/tmp/sample-yaml-csl/Sample.pdf`.
  - Confirmed generated TeX contains citeproc `CSLReferences`, `\usepackage{tikz}`, `\usetikzlibrary{arrows.meta,positioning,fit,backgrounds}`, and raw `\begin{tikzpicture}`, with no verbatim/highlighting block.
  - Note: the sample may emit a non-fatal overfull hbox warning if the TikZ diagram is wider than the text block.

#### TikZ plugin

- Use `LuaTikZ` as the active Obsidian live TikZ renderer.
- Configure `LuaTikZ` local renderer.
  - Renderer: `LuaLaTeX`.
  - LuaLaTeX path: `/Library/TeX/texbin/lualatex`.
  - Current plugin config in `.obsidian/plugins/luatikz/data.json`:

    ```json
    {
      "renderEngine": "lualatex",
      "lualatexPath": "/Library/TeX/texbin/lualatex",
      "enableLocalShellRenderer": true,
      "outputFormat": "svg",
      "timeoutMs": 15000,
      "cacheEnabled": true,
      "extraPreamble": "\\usepackage{luatexja-fontspec}\n\\setmainjfont{Songti SC}"
    }
    ```

  - Extra preamble for Chinese text:

    ```latex
    \usepackage{luatexja-fontspec}
    \setmainjfont{Songti SC}
    ```

  - Keep LuaTikZ scratch builds out of the iCloud-synced plugin directory:
    - Backed up the original temp folder to `.obsidian/plugins/luatikz/.luatikz-temp.backup-20260701`.
    - Pointed `.obsidian/plugins/luatikz/.luatikz-temp` to `/private/tmp/obsidian-luatikz-temp`.
  - Reason: LuaTikZ writes `.tex`, `.aux`, `.log`, `.pdf`, and `.svg` files during live rendering; iCloud-managed plugin temp folders can fail with `I can't write on file ... .aux`.
  - Verified a minimal standalone TikZ document compiles through the symlinked LuaTikZ temp path with `/Library/TeX/texbin/lualatex`.
  - Verified a minimal Chinese TikZ node compiles with `Songti SC` embedded and converts from PDF to SVG.
  - After changing LuaTikZ settings, reload Obsidian or disable/enable the `LuaTikZ` plugin, then clear LuaTikZ cache if an old broken SVG remains visible.
- Current standard path: Obsidian preview through `LuaTikZ`; Pandoc PDF export through `pandoc-thesis.yaml` plus `chapters/00-meta.md`.
- Verify local TeX/SVG tools are available for other workflows.
  - `pdflatex`: `/Library/TeX/texbin/pdflatex`.
  - `dvisvgm`: `/Library/TeX/texbin/dvisvgm`.
  - `pdf2svg`: `/opt/homebrew/bin/pdf2svg`.
- Create a simple TikZ render test note under `thesis-root/chapters/`.
- Open that note in Obsidian reading mode and confirm the SVG renders.

#### Txt as MD

- Open `Settings > Txt as MD`.
- Add `tex` to the comma-separated list of allowed extensions.
- Restart Obsidian.
- Confirm `.tex` files open inside Obsidian instead of an external editor.

### Phase 5: Pre-flight check

- Test math rendering.
  - Create a new note.
  - Type `$$ \sum_{i=1}^n $$`.
  - Confirm the summation symbol renders correctly.
- Test TikZ rendering.
  - Open your TikZ test note under `thesis-root/chapters/`.
  - Wait 2-3 seconds.
  - Confirm the SVG renders in reading mode.
- Test the Zotero bridge.
  - Press the Zotero Integration hotkey, such as `Ctrl+Shift+O` or `Cmd+Shift+O`.
  - Search for a paper by title or author.
  - Import the paper.
  - Confirm the generated Markdown note appears in `thesis-root/literatures`.
  - Confirm the note contains the correct title, abstract, and annotation content.

### Completion criteria

- Zotero can auto-update `thesis-root/references.bib`.
- Zotero Integration can generate literature notes from your import template.
- Markdown drafts can export through Pandoc with citations resolved.
- Math and TikZ blocks render correctly inside Obsidian.
- `.tex` files can be opened and edited directly in Obsidian.

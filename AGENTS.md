# AGENTS.md

## Cursor Cloud specific instructions

### What this repo is
This is the `buaa-thesis-toolbox` skill: a Markdown-first BUAA (Beihang University)
thesis toolchain. The reference workflow is authored on macOS with Obsidian + Zotero,
but the only part that runs headlessly (and the thing to build/test in Cloud) is the
**Pandoc → Lua filters → XeLaTeX (`buaa.cls`) → PDF** pipeline that lives under
`template/`. Obsidian and Zotero are macOS GUI apps and are out of scope in the
cloud VM.

### Build / run the thesis (the "application")
Run from the thesis root so relative paths (`./references.bib`, `./assets/…`,
`./scripts/…`) resolve:

```bash
cd template
./scripts/build-thesis.sh   # sorts chapters/*.md, runs pandoc --defaults ./pandoc-thesis.yaml → 毕业论文.pdf
```

There is no lint/test suite in this repo; correctness is verified by a clean PDF
build. Inspect/render the result with `poppler-utils` (`pdfinfo`, `pdftoppm`).

### Non-obvious caveats (learned during setup)
- **Pandoc must be ≥ 3.2.** Ubuntu's apt Pandoc (3.1.3) crashes the
  `scripts/full-width-tables.lua` filter with `table expected, got pandoc Cell`
  (`pandoc.utils.stringify` only accepts a table `Cell` in newer Pandoc). The
  update script installs the latest Pandoc `.deb` from GitHub when the present
  version is too old; a matching version is baked into the VM snapshot.
- **Ghostscript is required.** The cover/degree-header art in `assets/*.eps` is
  converted from EPS by XeLaTeX via ghostscript. Without it the build dies with
  `xdvipdfmx:fatal: pdf_link_obj(): passed invalid object` partway through (looks
  like a truncated `.aux` / `\@newl@bel` runaway, but the root cause is missing gs).
- **`buaa.cls` hardcodes `\setmainfont{Times New Roman}`** under XeLaTeX with no
  fallback, so the `ttf-mscorefonts-installer` font package is a hard dependency.
- CJK (`fandol`), math (`STIX Two Math` / `unicode-math`), and TikZ come from the
  TeX Live `texlive-lang-chinese`, `texlive-fonts-extra`, `texlive-science`, and
  `texlive-pictures` packages.
- `pandoc-thesis.yaml` sets `to: pdf`, so `pandoc -o out.tex` still emits a PDF; to
  get intermediate LaTeX for debugging, pass `-t latex -s` explicitly.
- The build writes `毕业论文.pdf` plus `.aux/.log/.toc` into `template/`; these are
  build outputs and should not be committed.

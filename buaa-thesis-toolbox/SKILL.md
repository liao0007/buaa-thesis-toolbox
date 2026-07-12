---
name: buaa-thesis-toolbox
description: Set up and operate a Markdown-first thesis writing environment using Obsidian + Pandoc + XeLaTeX + Zotero, built around the modular BUAA (Beihang University) buaa class (core + report profiles). Use when the user wants to scaffold a new thesis project, configure the Obsidian/Zotero/Pandoc/LaTeX toolchain, compile Markdown chapters into a standards-compliant PDF, switch report profiles (thesis/coursework/generic), or troubleshoot citation/TikZ/font build errors.
disable-model-invocation: true
---

# Thesis Writing Environment (Obsidian + Pandoc + XeLaTeX + Zotero)

Scaffold and run a Markdown-first academic thesis workflow. You write plain
Markdown chapters in Obsidian (live math, TikZ, citation previews) and one
build script produces a fully formatted PDF via the modular `buaa` LaTeX class:
covers, bundled CJK/Latin/math fonts, per-page circled footnotes, superscript
GB/T 7714 citations, headers, and standard back matter
(结论 / 参考文献 / 附录 / 学术成果 / 致谢 / 作者简介).

The bundled project is a **minimal syntax demo** (config guide + markup samples),
not a full research thesis. Replace demo chapters when the author starts writing.

## Pipeline

```
chapters/*.md ─▶ ./buaa/scripts/build.sh [output.pdf]
                      │
                      ▼
              Pandoc (--defaults buaa/pandoc.yaml)
                Lua filters → citeproc → bilingual-etal
                      │
                      ▼
              buaa/buaa.cls
                ├── core/                 shared packages, layout, metadata, hooks
                ├── font/setup.tex        bundled CJK + Times + Cambria Math
                └── reports/<profile>/    thesis | coursework | generic
                      │
                      ▼
              XeLaTeX ─▶ Artifact.pdf (default) or chosen name
```

| Layer | Path | Role |
|-------|------|------|
| Draft | `chapters/*.md` | Metadata + content; sorted by filename |
| Bibliography | `references.bib` | Zotero Better BibTeX auto-export |
| Reading notes | `literatures/` | Optional Zotero Integration notes |
| Pandoc defaults | `buaa/pandoc.yaml` | Reader, engine, filter chain |
| Class loader | `buaa/buaa.cls` | Thin loader → core + report profile |
| Shared LaTeX | `buaa/core/*.tex` | Options, packages, layout, hooks, lifecycle |
| Report profiles | `buaa/reports/{thesis,coursework,generic}/` | Front/back matter per document type |
| Citation style | `buaa/gb-t-7714-2015-numeric-superscript.csl` | GB/T 7714-2015 numeric superscript |
| Lua filters | `buaa/scripts/*.lua` | Tables, continued captions, TikZ, et al. |
| Build | `buaa/scripts/build.sh` | Collect `chapters/*.md` → Pandoc |
| Fonts | `buaa/font/` + `setup.tex` | simsun/simhei/simkai/simfang, Xingkai, Times, Cambria Math |
| Cover asset | `buaa/assets/logo-buaa.eps` | University calligraphy |
| Body figures | `assets/` (thesis root) | Markdown `![…](assets/…){#fig:id}` bitmaps |
| Demo PDFs | `输出示例.pdf`, `官方示例.pdf` | Markdown build sample + official reference |

## Bundled templates

Two trees sit next to this file. Do **not** regenerate from scratch — copy them:

### Thesis content — `template/`

```bash
THESIS_ROOT="/path/to/thesis-root"
SKILL_DIR="$HOME/.cursor/skills/_buaa-skills/buaa-thesis-toolbox"
mkdir -p "$THESIS_ROOT"
cp -R "$SKILL_DIR/template/." "$THESIS_ROOT/"
chmod +x "$THESIS_ROOT/buaa/scripts/build.sh"
```

Contents:

- `template/buaa/` — `buaa.cls`, `pandoc.yaml`, CSL, `core/`, `reports/`, `font/`, `i18n/`, `assets/`, `scripts/`
- `template/assets/` — demo body figures (e.g. `mac.jpg` for Markdown image syntax)
- `template/chapters/` — `00-meta.md` + demo body + back matter `90`–`95`
- `template/literatures/` — Zotero import Nunjucks template + sample notes
- `template/references.bib`, `template/README.md`
- `template/输出示例.pdf`, `template/官方示例.pdf`

### Obsidian plugins — `template-obsidian/`

Settings-only bundle for **Shell commands**, **Zotero Integration**, and **LuaTikZ**.
Does not vendor `main.js`. Restore **detects** vault↔thesis relative path and
external tools (`pandoc` / `xelatex` / `lualatex`) for the target machine:

```bash
# Preferred — pass thesis root only; auto-detect vault + paths + tools
"$SKILL_DIR/template-obsidian/restore-obsidian-plugins.sh" "$THESIS_ROOT"

# Optional preview
"$SKILL_DIR/template-obsidian/restore-obsidian-plugins.sh" "$THESIS_ROOT" --dry-run
```

Then in Obsidian: disable Safe Mode → install/enable the three plugins if missing → reload.
Command palette → **Build thesis PDF**. Details: `template-obsidian/README.md`.

## Scaffold a new thesis

1. Confirm the target thesis-root directory with the user (folder that will contain
   `buaa/` + `chapters/`). Prefer pointing restore at that folder and letting it
   discover whether an ancestor vault already exists.
2. Copy the whole thesis `template/` as above; make `build.sh` executable.
3. Restore Obsidian plugin settings (target-aware):

   ```bash
   "$SKILL_DIR/template-obsidian/restore-obsidian-plugins.sh" "$THESIS_ROOT"
   ```

   The script sets Shell commands `working_directory`, Zotero `literatures/…`
   paths, LuaTikZ `lualatexPath`, and OS PATH augmentation from detection — do
   not copy another machine’s absolute / folder-name-specific paths by hand.
4. Edit `chapters/00-meta.md`:
   - `classoption:` — degree, secrecy, `library`/`print`, OS, `short`/`long`,
     `STEM`/`HSS`, report profile (`thesis` / `coursework` / `generic`), and
     **`fontset=none`** (bundled fonts via `buaa/font/setup.tex`).
   - `header-includes:` — real `\Title`, `\Author`, `\Department`, `\Degree`,
     `\Major`, `\Feild`, `\Discipline`, `\Direction`, `\Tutor`, `\Abstract`,
     `\Keyword`, `\StudentID`, `\CLC`, `\Date*`, optional `\SpecialProg`,
     `\Signs`, `\Abbreviations`, TikZ packages.
5. Replace demo chapters `01` / `02` with real content; keep numeric prefixes so
   lexical sort = thesis order. Keep back-matter command files
   (`90` `\summary`, `91` `\buaareferences` + `::: {#refs}` + `\buaareferencesend`,
   `92` `\appendix`, `93` `\achievement`, `94` `\acknowledgments`,
   `95` `\biography`) or drop unused ones.
6. Point Zotero Better BibTeX auto-export at `<thesis-root>/references.bib`.
7. Spot-check restore output: thesis-rel, tool paths, and
   Command palette → **Build thesis PDF**.

## Compile

Always run from the thesis root so relative paths and `TEXINPUTS` resolve:

```bash
cd "$THESIS_ROOT"
./buaa/scripts/build.sh              # → Artifact.pdf
./buaa/scripts/build.sh my-thesis.pdf
```

The script sorts `chapters/*.md` by filename, sets `TEXINPUTS` to include
`buaa//`, and calls Pandoc with `--defaults ./buaa/pandoc.yaml`.

Build from a terminal **or** from Obsidian via the **Shell commands** plugin
(working directory = thesis root; command `./buaa/scripts/build.sh`). See
[SETUP.md](SETUP.md) §Shell commands. No Obsidian Pandoc export plugin.

## Architecture (class load order)

1. `core/input.tex` — path helpers + `\buaa@loadreport`
2. `core/options.tex` — profile / degree / secrecy / library|print / OS / STEM|HSS
3. `ctexbook` — base class
4. `core/{packages,helpers,math,metadata,layout,hooks}.tex`
5. `reports/<profile>/setup.tex` — overrides hooks; inputs front/back fragments
6. `core/document.tex` — `\AtBeginDocument` / `\AfterEndPreamble` lifecycle

Defaults when options are omitted: profile `thesis`, degree `master`, `public`,
`library`, `mac`, `short`, `STEM`. The demo overrides degree to `professional`.

Report profile details: `template/buaa/reports/README.md` (copied into every project).

## Non-negotiable rules

- **`raw_tex` must stay in `from:`** so `\summary`, `\buaareferences`,
  `\buaareferencesend`, `\ref{}`, `\footnote{}`, `\appendix`, `\biography`, etc.
  pass through.
- **Enable citeproc in exactly one place** — as a **filter** in `buaa/pandoc.yaml`
  (before `bilingual-etal.lua`). Never also set `citeproc: true` or pass
  `--citeproc`, or every reference doubles.
- **Thesis metadata goes in `chapters/00-meta.md` `header-includes` as
  `\Command{}` calls**, not loose YAML keys and not Obsidian-plugin arguments
  (the plugin mishandles spaces/backslashes).
- **`fontset=none`** is required for this template (bundled fonts in
  `buaa/font/setup.tex`). Do not switch back to `fontset=fandol` unless you
  intentionally abandon the bundled font set.
- Keep BUAA 4.1.0-aligned class options explicit: degree (`professional` =
  professional master), secrecy (`public`), output (`library`/`print`), OS
  (`mac`/`win`/`linux`), title length (`short`/`long`), subject family
  (`STEM`/`HSS`), and report profile (`thesis`/`coursework`/`generic`).
- Page geometry is **fixed** in `buaa/core/layout.tex`; later `\geometry{…}` is ignored.
- Figures and tables are numbered by chapter; use `subcaption` for subfigures.
- **Body bitmaps:** `![Caption](assets/file.jpg){#fig:id width=90%}` under
  thesis-root `assets/`; cross-ref with `\ref{fig:id}` (not `@fig:…`). Details:
  [AUTHORING.md](AUTHORING.md) §Figures — Markdown.
- **Obsidian TikZ = plain `luatikz` + `tikzpicture` only.** Do **not** wrap
  `\begin{figure}` / `\caption` / `\label` inside the fence — LuaTikZ will not
  preview. Put PDF metadata as top-of-block comments `% caption:` / `% label:`;
  `tikz.lua` turns them into a float at build time. Details: [AUTHORING.md](AUTHORING.md)
  §Figures — TikZ.
- The class name `\Feild` is intentionally misspelled — use that spelling.
- Build from thesis root so `./buaa/scripts/build.sh` can set `TEXINPUTS`.

## When to read the companion docs

- **Setting up the toolchain** (Zotero, Better BibTeX, Obsidian plugins via
  `template-obsidian/`, LuaTikZ, LaTeX, Pandoc, fonts) → [SETUP.md](SETUP.md).
- **Writing content** (chapters, `\Command{}` reference, class options, profiles,
  TikZ, Markdown figures, tables, math, citations) or **fixing build errors** →
  [AUTHORING.md](AUTHORING.md).
- **Typography compliance** (official 字号/字体 spec, `layout.tex` / cover fonts,
  TikZ/table font rules, PDF font audit) → [TYPOGRAPHY-REFERENCE.md](TYPOGRAPHY-REFERENCE.md).
- **Handing the project to the author** → the copied `README.md` is their manual.
- **Report profiles** → `buaa/reports/README.md` inside the project.

---
name: buaa-thesis-toolbox
description: Set up and operate a Markdown-first thesis writing environment using Obsidian + Pandoc + XeLaTeX + Zotero, built around the BUAA (Beihang University) thesis class. Use when the user wants to scaffold a new thesis project, configure the Obsidian/Zotero/Pandoc/LaTeX toolchain, compile Markdown chapters into a standards-compliant PDF, or troubleshoot citation/TikZ/font build errors.
disable-model-invocation: true
---

# Thesis Writing Environment (Obsidian + Pandoc + XeLaTeX + Zotero)

Scaffold and run a Markdown-first academic thesis workflow. You write plain
Markdown chapters in Obsidian (live math, TikZ, citation previews) and one
Pandoc command produces a fully formatted PDF via the `buaa.cls` LaTeX class:
covers, Chinese fonts, per-page circled footnotes, superscript GB/T 7714
citations, headers, and standard back matter (结论 / 参考文献 / 附录 / 致谢).

## Pipeline

```
chapters/*.md ─▶ build-thesis.sh ─▶ Pandoc(+citeproc+Lua filters) ─▶ LaTeX(buaa.cls) ─▶ XeLaTeX ─▶ thesis.pdf
```

| Layer | File | Role |
|-------|------|------|
| Draft | `chapters/*.md` | Metadata + content in sorted, numeric-prefixed files |
| Pandoc defaults | `pandoc-thesis.yaml` | Build execution settings (engine, citeproc, filters) |
| Document class | `buaa.cls` | All formatting: fonts, covers, headers, TOC, back matter |
| Citation style | `gb-t-7714-2015-numeric-superscript.csl` | GB/T 7714-2015 numeric superscript |
| Bibliography | `references.bib` | Auto-exported from Zotero (Better BibTeX) |
| Lua filters | `scripts/tikz.lua`, `scripts/full-width-tables.lua` | TikZ figures + table sizing |
| Assets | `assets/*.eps` | Cover logo and degree header images |

## Bundled template

Everything needed lives in `template/` next to this file. Do not regenerate
these from scratch — copy them:

- `template/buaa.cls`, `template/pandoc-thesis.yaml`, `template/*.csl`, `template/references.bib`
- `template/chapters/` — `00-meta.md` + numbered skeleton chapters + back matter
- `template/scripts/` — `build-thesis.sh`, `tikz.lua`, `full-width-tables.lua`
- `template/assets/` — `logo-buaa.eps`, `head-{master,doctor,professional,prodoctor}.eps`
- `template/literatures/` — sample Zotero literature notes
- `template/README.md` — full end-user reference for the compiled project

## Scaffold a new thesis

1. Confirm the target thesis-root directory with the user (an Obsidian vault
   folder). Then copy the whole template in:

   ```bash
   THESIS_ROOT="/path/to/thesis-root"
   SKILL_DIR="$HOME/.cursor/skills/buaa-thesis-toolbox"
   mkdir -p "$THESIS_ROOT"
   cp -R "$SKILL_DIR/template/." "$THESIS_ROOT/"
   chmod +x "$THESIS_ROOT/scripts/build-thesis.sh"
   ```

2. Edit `chapters/00-meta.md` `header-includes` with the real `\Title`,
   `\Author`, `\Department`, `\Major`, `\Feild`, `\Tutor`, `\Abstract`,
   `\Keyword`, `\StudentID`, `\CLC`, and the `\Date*` commands.
3. Set degree/secrecy/print in `classoption:` (see AUTHORING.md §Class options).
4. Replace skeleton chapter bodies; keep numeric prefixes so lexical sort
   matches thesis order, and keep the back-matter command files
   (`90-结论` `\summary`, `91-参考文献` `\chaptera{参考文献}` + `::: {#refs}`,
   `92-附录` `\appendix`, `93` `\achievement`, `94` `\acknowledgments`).
5. Point Zotero Better BibTeX auto-export at `<thesis-root>/references.bib`.

## Compile

Always run from the thesis root so relative paths resolve:

```bash
cd "$THESIS_ROOT"
./scripts/build-thesis.sh          # collects sorted chapters/*.md → 毕业论文.pdf
```

The script sorts `chapters/*.md` by filename and passes them to Pandoc with
`--defaults ./pandoc-thesis.yaml`. Rename the output in `build-thesis.sh` if a
different filename is wanted.

## Non-negotiable rules

- **`raw_tex` must stay in `from:`** so inline `\summary`, `\chaptera{}`,
  `\ref{}`, `\footnote{}`, `\appendix` pass through.
- **Enable citeproc in exactly one place** (`pandoc-thesis.yaml`). Never also
  add `--citeproc` on the command line / plugin args, or every reference doubles.
- **Thesis metadata goes in `chapters/00-meta.md` `header-includes` as
  `\Command{}` calls**, not loose YAML keys and not Obsidian-plugin arguments
  (the plugin mishandles spaces/backslashes).
- **`fontset=fandol`** is the recommended classoption for stable Pandoc+XeLaTeX.
- The class name `\Feild` is intentionally misspelled — use that spelling.

## When to read the companion docs

- **Setting up the toolchain** (Zotero, Better BibTeX, Obsidian plugins,
  LuaTikZ, LaTeX, Pandoc, fonts) → read [SETUP.md](SETUP.md).
- **Writing content** (chapters, `\Command{}` reference, class options, TikZ,
  tables, math, citations) or **fixing build errors** → read [AUTHORING.md](AUTHORING.md).
- **Handing the project to the author** → the copied `README.md` is their manual.

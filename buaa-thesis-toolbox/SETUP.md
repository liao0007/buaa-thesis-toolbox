# Environment Setup

End-to-end setup for the Obsidian + Zotero + LaTeX + Pandoc thesis toolchain.
Complete phases in order — Obsidian plugins depend on system-level tools.

Paths below are the verified macOS locations from the reference machine
(Homebrew + MacTeX). Adjust for Windows/Linux where noted.

## Phase 1: System-level prerequisites

- Install **Zotero** desktop.
- Install a **LaTeX** distribution with XeLaTeX + LuaLaTeX:
  - macOS: MacTeX. Windows: MiKTeX or TeX Live. Linux: `texlive-full`.
- Install **Pandoc** ≥ 3.x (Homebrew `brew install pandoc`, or GitHub releases).
- Install an **SVG converter** for TikZ live preview: `pdf2svg` (`brew install
  pdf2svg`) and/or `dvisvgm` (ships with MacTeX/TeX Live).
- Verify on PATH:

  ```bash
  pandoc -v          # expect 3.x
  xelatex -v
  lualatex -v
  ```

  Verified reference paths:
  - `pandoc` → `/opt/homebrew/bin/pandoc`
  - `xelatex` / `pdflatex` / `lualatex` / `dvisvgm` → `/Library/TeX/texbin/…`
  - `pdf2svg` → `/opt/homebrew/bin/pdf2svg`

### Fonts

`fontset=fandol` (set in `chapters/00-meta.md`) avoids local CJK lookup while
defining `\songti` / `\heiti`. If setting fonts explicitly, install one per slot:

| Slot | Options |
|------|---------|
| CJK serif 正文 | SimSun / STSong / Songti SC / FandolSong / Noto Serif CJK SC |
| CJK sans 黑体 | SimHei / STHeiti / Heiti SC / FandolHei / Noto Sans CJK SC |
| Latin | Times New Roman / TeX Gyre Termes |
| Math | XITS Math / STIX Two Math / TeX Gyre Termes Math |

## Phase 2: Zotero & bibliography

- Install **Better BibTeX for Zotero** (`.xpi` from its GitHub releases →
  Zotero `Tools > Add-ons` → gear → `Install Add-on From File`).
- Citation key format: `Zotero Preferences > Better BibTeX` → `auth.lower+year`
  (keys look like `smith2023`).
- Auto-export the bibliography: select the library/collection → right-click →
  `Export Library` → format `Better BibTeX` → enable **Keep updated** → save as
  `<thesis-root>/references.bib`. Confirm it updates after edits.

## Phase 3: Obsidian vault & plugins

- Ensure the thesis-root vault has `chapters/`, `literatures/`, `assets/`,
  `scripts/` (the bundled template already provides these).
- `Settings > Community Plugins` → turn off Safe Mode.
- Install and enable: **Zotero Integration**, **Obsidian Pandoc**, **LuaTikZ**,
  **Latex Suite**, **Txt as MD**.

## Phase 4: Plugin configuration

### Zotero Integration

- Confirm the Zotero database path is detected.
- `Add Import Format` named `Literature Note`:
  - Output path: `<thesis-root>/literatures/{{citekey}}.md`
  - Annotation image path: `<thesis-root>/literatures/{{citekey}}/`
  - Template file: your Zotero Integration Nunjucks template (e.g.
    `<thesis-root>/literatures/_template.njk`).
- Citation insertion: Pandoc format, bracketed `[@{{citekey}}]`.
- Note suggestion: `[[{{citekey}}]]`.

### Obsidian Pandoc

- Pandoc path: `/opt/homebrew/bin/pandoc`. PDFLaTeX path: `/Library/TeX/texbin/pdflatex`.
- Export source format: `Markdown`.
- Extra arguments — **only** this:
  `--defaults=/absolute/path/to/thesis-root/pandoc-thesis.yaml`
- Do **not** also pass `--citeproc`, `--csl`, `--bibliography`, `--pdf-engine`,
  `--lua-filter`, or `-V header-includes=...` — those live in
  `pandoc-thesis.yaml` / `chapters/00-meta.md`. The plugin splits args on spaces
  and mishandles backslashes/quotes.

### LuaTikZ (live TikZ preview)

`.obsidian/plugins/luatikz/data.json`:

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

- Keep the LuaTikZ scratch/temp folder **out of iCloud-synced** plugin dirs
  (iCloud can fail with `I can't write on file ... .aux`). Symlink its
  `.luatikz-temp` to a local path, e.g. `/private/tmp/obsidian-luatikz-temp`.
- After changing settings: reload Obsidian (or disable/enable LuaTikZ), then
  clear the LuaTikZ cache if a stale SVG persists.

### Txt as MD

- `Settings > Txt as MD` → add `tex` to allowed extensions → restart Obsidian so
  `.tex` files open inside Obsidian.

## Phase 5: Pre-flight check

- Math: new note, type `$$ \sum_{i=1}^n $$`, confirm it renders.
- TikZ: open a note with a `luatikz` block, wait 2–3s, confirm SVG in reading mode.
- Zotero bridge: Zotero Integration hotkey (e.g. `Cmd+Shift+O`) → search → import
  → confirm a note appears under `literatures/` with title/abstract/annotations.
- Full build: `cd <thesis-root> && ./scripts/build-thesis.sh` → PDF is produced.

## Completion criteria

- Zotero auto-updates `references.bib`.
- Zotero Integration generates literature notes from your import template.
- Markdown drafts export through Pandoc with citations resolved (superscript).
- Math and TikZ render inside Obsidian.
- `.tex` files open and edit directly in Obsidian.

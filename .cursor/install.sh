#!/usr/bin/env bash
# Idempotent dependency setup for the buaa-skills thesis build pipeline
# (Pandoc -> Lua filters -> XeLaTeX (buaa.cls) -> PDF).
set -euo pipefail

echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  texlive-xetex texlive-lang-chinese texlive-latex-extra texlive-latex-recommended \
  texlive-fonts-recommended texlive-fonts-extra texlive-science texlive-pictures \
  texlive-plain-generic lmodern ghostscript poppler-utils ttf-mscorefonts-installer

# Pandoc must be >= 3.2: apt ships 3.1.3, which crashes scripts/full-width-tables.lua
# (pandoc.utils.stringify only accepts a table Cell in newer Pandoc).
if ! command -v pandoc >/dev/null 2>&1 || \
   dpkg --compare-versions "$(pandoc --version | head -1 | awk '{print $2}')" lt 3.2; then
  ARCH=$(dpkg --print-architecture)
  PANDOC_TAG=$(curl -fsSL https://api.github.com/repos/jgm/pandoc/releases/latest | grep -oP '"tag_name": "\K[^"]+')
  curl -fsSL "https://github.com/jgm/pandoc/releases/download/${PANDOC_TAG}/pandoc-${PANDOC_TAG}-1-${ARCH}.deb" -o /tmp/pandoc-latest.deb
  sudo dpkg -i /tmp/pandoc-latest.deb
fi

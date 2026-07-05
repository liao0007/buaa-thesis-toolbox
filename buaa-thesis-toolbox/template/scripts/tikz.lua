local function is_tikz_block(classes)
  for _, class in ipairs(classes) do
    if class == "tikz" or class == "luatikz" then
      return true
    end
  end
  return false
end

local function get_attribute(attributes, key)
  for _, pair in ipairs(attributes) do
    if pair[1] == key then
      return pair[2]
    end
  end
  return nil
end

local function latex_escape(text)
  local replacements = {
    ["\\"] = "\\textbackslash{}",
    ["{"] = "\\{",
    ["}"] = "\\}",
    ["#"] = "\\#",
    ["$"] = "\\$",
    ["%"] = "\\%",
    ["&"] = "\\&",
    ["_"] = "\\_",
    ["^"] = "\\textasciicircum{}",
    ["~"] = "\\textasciitilde{}",
  }
  return (text:gsub("[\\{}#%%$&_^~]", replacements))
end

local function strip_document_wrappers(text)
  -- The blocks carry a full `standalone` preamble so Obsidian's tikzjax/luatikz
  -- can render a preview. For the PDF build these must go: the thesis preamble
  -- already loads tikz + the required libraries (arrows.meta, positioning, fit,
  -- backgrounds, incl. the `background` layer), and \documentclass / \usepackage
  -- are only valid before \begin{document}.
  text = text:gsub("\\documentclass%s*%b[]%s*%b{}", "")
  text = text:gsub("\\documentclass%s*%b{}", "")
  text = text:gsub("\\usepackage%s*%b[]%s*%b{}", "")
  text = text:gsub("\\usepackage%s*%b{}", "")
  text = text:gsub("\\usetikzlibrary%s*%b{}", "")
  text = text:gsub("\\begin%s*{%s*document%s*}", "")
  text = text:gsub("\\end%s*{%s*document%s*}", "")
  return text
end

local function strip_float_wrappers(text)
  text = text:gsub("\\begin%s*{%s*center%s*}\n?", "")
  text = text:gsub("\n?\\end%s*{%s*center%s*}", "")
  text = text:gsub("\\begin%s*{%s*figure%s*}%b{}", "")
  text = text:gsub("\\end%s*{%s*figure%s*}", "")
  text = text:gsub("\\centering\n?", "")
  text = text:gsub("\\caption%s*%b{}", "")
  text = text:gsub("\\label%s*%b{}", "")
  return text:match("^%s*(.-)%s*$")
end

-- Optional PDF-only metadata at the top of the block (LaTeX comments keep Obsidian preview working):
--   % caption: 图题
--   % label: fig:my-diagram
local function extract_leading_metadata(text)
  local caption, label

  while true do
    local matched = false

    local cap, rest = text:match("^%%?%s*caption:%s*(.-)\n(.*)$")
    if cap then
      caption = cap
      text = rest
      matched = true
    end

    local lbl, rest2 = text:match("^%%?%s*label:%s*(.-)\n(.*)$")
    if lbl then
      label = lbl
      text = rest2
      matched = true
    end

    if not matched then
      break
    end
  end

  return caption, label, text
end

local function already_figure(text)
  return text:match("\\begin%s*{%s*figure")
end

function CodeBlock(elem)
  if not is_tikz_block(elem.classes) then
    return nil
  end

  if already_figure(elem.text) then
    return pandoc.RawBlock("latex", strip_document_wrappers(elem.text))
  end

  local text = elem.text
  local attr_caption = get_attribute(elem.attributes, "caption")
  local label = elem.identifier
  if label == "" then
    label = nil
  end

  local line_caption, line_label
  line_caption, line_label, text = extract_leading_metadata(text)
  text = strip_document_wrappers(text)
  text = strip_float_wrappers(text)

  local caption = attr_caption or line_caption
  label = label or line_label

  if caption or label then
    local parts = {
      "\\begin{figure}[htbp]",
      "\\centering",
      text,
    }
    if caption then
      table.insert(parts, "\\caption{" .. latex_escape(caption) .. "}")
    end
    if label then
      table.insert(parts, "\\label{" .. label .. "}")
    end
    table.insert(parts, "\\end{figure}")
    return pandoc.RawBlock("latex", table.concat(parts, "\n"))
  end

  return pandoc.RawBlock("latex", "\\begin{center}\n" .. text .. "\n\\end{center}")
end

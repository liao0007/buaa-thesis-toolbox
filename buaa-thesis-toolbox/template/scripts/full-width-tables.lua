local function display_width(text)
  local width = 0
  text = text:gsub("%s+", " ")

  for char in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    if #char == 1 then
      width = width + 1
    else
      width = width + 2
    end
  end

  return width
end

local function add_row_widths(widths, row)
  if not row or not row.cells then
    return
  end

  for index, cell in ipairs(row.cells) do
    local text = pandoc.utils.stringify(cell)
    widths[index] = math.max(widths[index] or 0, display_width(text))
  end
end

local function collect_widths(tbl, column_count)
  local widths = {}

  for index = 1, column_count do
    widths[index] = 1
  end

  if tbl.head and tbl.head.rows then
    for _, row in ipairs(tbl.head.rows) do
      add_row_widths(widths, row)
    end
  end

  for _, body in ipairs(tbl.bodies or {}) do
    for _, row in ipairs(body.body or {}) do
      add_row_widths(widths, row)
    end
  end

  if tbl.foot and tbl.foot.rows then
    for _, row in ipairs(tbl.foot.rows) do
      add_row_widths(widths, row)
    end
  end

  return widths
end

function Table(tbl)
  local column_count = #tbl.colspecs
  if column_count == 0 then
    return tbl
  end

  local measured_widths = collect_widths(tbl, column_count)
  local total = 0

  for index = 1, column_count do
    -- Keep very short columns readable while preventing one long cell from
    -- taking the entire page width.
    measured_widths[index] = math.max(6, math.min(measured_widths[index], 50))
    total = total + measured_widths[index]
  end

  for index, colspec in ipairs(tbl.colspecs) do
    tbl.colspecs[index] = { colspec[1], measured_widths[index] / total }
  end

  return tbl
end

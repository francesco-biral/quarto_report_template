-- HTML only: adds an organisation footer (logo, name, unit, address, website,
-- licence) and applies org.primary-color / org.accent-color to the CSS palette.
-- All values come from the `org:` and `license:` metadata; nothing is hard-coded.

local function str(v)
  if v == nil then return nil end
  local s = pandoc.utils.stringify(v)
  if s == "" then return nil end
  return s
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

function Pandoc(doc)
  if not quarto.doc.is_format("html") then return doc end
  local org = doc.meta.org or {}
  local lic = doc.meta.license or {}

  -- Palette override
  local primary, accent = str(org["primary-color"]), str(org["accent-color"])
  local css = {}
  if primary then table.insert(css, "--navy:#" .. primary:gsub("^#", "") .. ";") end
  if accent then table.insert(css, "--orange:#" .. accent:gsub("^#", "") .. ";") end
  if #css > 0 then
    quarto.doc.include_text("in-header", "<style>:root{" .. table.concat(css) .. "}</style>")
  end

  -- Footer
  local left = {}
  local logo = str(org["cover-logo"])
  if logo then table.insert(left, '<img class="org-logo" src="' .. esc(logo) .. '" alt="">') end
  local lines = {}
  if str(org.name) then table.insert(lines, "<strong>" .. esc(str(org.name)) .. "</strong>") end
  if str(org.unit) then table.insert(lines, esc(str(org.unit))) end
  if str(org.address) then table.insert(lines, esc(str(org.address))) end
  if str(org.website) then
    local w = esc(str(org.website))
    table.insert(lines, '<a href="' .. w .. '">' .. w .. "</a>")
  end
  if #lines > 0 then table.insert(left, '<div class="org-text">' .. table.concat(lines, "<br>") .. "</div>") end

  local right = {}
  if lic["show-logo"] == true and str(lic.logo) then table.insert(right, '<img class="license-logo" src="' .. esc(str(lic.logo)) .. '" alt="">') end
  if str(lic.text) then table.insert(right, "<div>" .. esc(str(lic.text)) .. "</div>") end

  if #left + #right == 0 then return doc end
  local html = '<footer class="org-footer"><div class="org-left">' .. table.concat(left)
    .. '</div><div class="org-right">' .. table.concat(right) .. "</div></footer>"
  doc.blocks:insert(pandoc.RawBlock("html", html))
  return doc
end

-- split a string
function split_string(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  
  local t = {}
  
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end

  return t
end

-- get ink r, g, b
function GetInkRGB(i)
	if i < 0 or i > game_data.max_inks - 1 then return 0, 0, 0 end
	
	local hexacolor = game_data.inks_palette[i + 1]
	local r = tonumber(string.sub(hexacolor, 1, 2), 16) / 255.0
	local g = tonumber(string.sub(hexacolor, 3, 4), 16) / 255.0
	local b = tonumber(string.sub(hexacolor, 5, 6), 16) / 255.0
	
	return r, g, b
end

-- get pen r, g, b
function GetPenRGB(p)
	if p < 0 or p > game_data.max_pens - 1 then return 0, 0, 0 end

	local hexacolor = game_data.inks_palette[game_data.pens_palette[p + 1] + 1]
	local r = tonumber(string.sub(hexacolor, 1, 2), 16) / 255.0
	local g = tonumber(string.sub(hexacolor, 3, 4), 16) / 255.0
	local b = tonumber(string.sub(hexacolor, 5, 6), 16) / 255.0
	
	return r, g, b
end

--[[----------------------------------------------------------------------------

FilmPresets.lua
Film Emulation Plugin for Adobe Lightroom
Registry for film stock presets - dynamically loads from subfolders

------------------------------------------------------------------------------]]

local FilmPresets = {}

-- List of available preset modules (add new film stocks here)
local presetModules = {
  'portra-400.preset',
  -- Add future presets here:
  -- 'ektar-100.preset',
  -- 'tri-x-400.preset',
}

-- Load all preset modules
local loadedPresets = {}

for _, modulePath in ipairs(presetModules) do
  local success, preset = pcall(require, modulePath)
  if success and preset and preset.id then
    loadedPresets[preset.id] = preset
  end
end

-- Get preset by ID
function FilmPresets.getPresetById(id)
  return loadedPresets[id]
end

-- Get list of all presets for UI
function FilmPresets.getPresetList()
  local list = {}
  for id, preset in pairs(loadedPresets) do
    list[#list + 1] = {
      id = preset.id,
      name = preset.name,
    }
  end
  -- Sort alphabetically by name
  table.sort(list, function(a, b) return a.name < b.name end)
  return list
end

return FilmPresets

--[[----------------------------------------------------------------------------

FilmEmulationDialog.lua
Film Emulation Plugin for Adobe Lightroom
Main dialog for selecting and applying film presets

------------------------------------------------------------------------------]]

local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'
local LrProgressScope = import 'LrProgressScope'

-- Import film presets
local FilmPresets = require 'FilmPresets'

-- Build popup menu items from presets
local function getPresetMenuItems()
  local presetList = FilmPresets.getPresetList()
  local items = {}
  for i, preset in ipairs(presetList) do
    items[i] = { title = preset.name, value = preset.id }
  end
  return items
end

-- Apply relative adjustments using quickDevelop methods
local function applyRelativeAdjustments(photo, relativeSteps)
  -- Apply tonal adjustments (relative - preserves user edits)
  if relativeSteps.Highlights and relativeSteps.Highlights ~= 0 then
    photo:quickDevelopAdjustImage('Highlights', relativeSteps.Highlights)
  end
  if relativeSteps.Shadows and relativeSteps.Shadows ~= 0 then
    photo:quickDevelopAdjustImage('Shadows', relativeSteps.Shadows)
  end
  if relativeSteps.Whites and relativeSteps.Whites ~= 0 then
    photo:quickDevelopAdjustImage('Whites', relativeSteps.Whites)
  end
  if relativeSteps.Blacks and relativeSteps.Blacks ~= 0 then
    photo:quickDevelopAdjustImage('Blacks', relativeSteps.Blacks)
  end
  if relativeSteps.Contrast and relativeSteps.Contrast ~= 0 then
    photo:quickDevelopAdjustImage('Contrast', relativeSteps.Contrast)
  end

  -- Apply white balance adjustments (relative)
  if relativeSteps.Temperature and relativeSteps.Temperature ~= 0 then
    photo:quickDevelopAdjustWhiteBalance('Temperature', relativeSteps.Temperature)
  end
  if relativeSteps.Tint and relativeSteps.Tint ~= 0 then
    photo:quickDevelopAdjustWhiteBalance('Tint', relativeSteps.Tint)
  end
end

-- Apply the selected film preset to photos
local function applyFilmPreset(presetId, photos, warmthOverride, tintOverride)
  local preset = FilmPresets.getPresetById(presetId)
  if not preset then
    LrDialogs.message(
      LOC "$$$/FilmEmulation/Error/Title=Error",
      LOC "$$$/FilmEmulation/Error/PresetNotFound=The selected film preset could not be found.",
      "critical"
    )
    return
  end

  local progress = LrProgressScope {
    title = LOC("$$$/FilmEmulation/Progress/Applying=Applying ^1...", preset.name),
  }
  progress:setCancelable(true)

  local catalog = LrApplication.activeCatalog()

  catalog:withWriteAccessDo(
    LOC "$$$/FilmEmulation/ApplyPreset/OperationName=Apply Film Preset",
    function()
      for i, photo in ipairs(photos) do
        if progress:isCanceled() then break end
        progress:setPortionComplete(i - 1, #photos)

        -- 1. Apply absolute settings (HSL, Tone Curve, Color Grading, Grain)
        photo:applyDevelopSettings(preset.absoluteSettings)

        -- 2. Create a copy of relative steps with any overrides
        local relativeSteps = {}
        for k, v in pairs(preset.relativeSteps) do
          relativeSteps[k] = v
        end

        -- Apply warmth/tint overrides if provided
        if warmthOverride ~= nil then
          relativeSteps.Temperature = warmthOverride
        end
        if tintOverride ~= nil then
          relativeSteps.Tint = tintOverride
        end

        -- 3. Apply relative adjustments
        applyRelativeAdjustments(photo, relativeSteps)
      end
      progress:setPortionComplete(#photos, #photos)
    end
  )

  progress:done()

  local photoCount = #photos
  local photoWord = photoCount == 1 and "photo" or "photos"
  LrDialogs.message(
    LOC "$$$/FilmEmulation/Applied/Title=Film Preset Applied",
    LOC("$$$/FilmEmulation/Applied/Message=^1 has been applied to ^2 ^3.", preset.name, photoCount, photoWord),
    "info"
  )
end

-- Main dialog function
local function showDialog()
  LrFunctionContext.callWithContext("showFilmEmulationDialog", function(context)
    local f = LrView.osFactory()
    local properties = LrBinding.makePropertyTable(context)

    -- Get preset menu items
    local presetMenuItems = getPresetMenuItems()

    -- Set defaults
    properties.selectedPresetId = presetMenuItems[1] and presetMenuItems[1].value or nil
    properties.useCustomWarmth = false
    properties.customWarmth = 15     -- Default from Portra 400
    properties.useCustomTint = false
    properties.customTint = 8        -- Default from Portra 400

    -- Update defaults when preset changes
    properties:addObserver('selectedPresetId', function(props, key, value)
      local preset = FilmPresets.getPresetById(value)
      if preset and preset.relativeSteps then
        props.customWarmth = preset.relativeSteps.Temperature or 15
        props.customTint = preset.relativeSteps.Tint or 8
      end
    end)

    local contents = f:column {
      bind_to_object = properties,
      spacing = f:control_spacing(),
      fill = 1,

      -- Film preset selection
      f:row {
        f:static_text {
          title = LOC "$$$/FilmEmulation/Dialog/SelectPreset=Film Stock:",
          alignment = 'right',
          width = 100,
        },

        f:popup_menu {
          value = LrView.bind 'selectedPresetId',
          items = presetMenuItems,
          fill_horizontal = 1,
        },
      },

      f:separator { fill_horizontal = 1 },

      -- White Balance adjustments section
      f:static_text {
        title = LOC "$$$/FilmEmulation/Dialog/WBSection=White Balance Adjustments (Relative)",
        font = "<system/bold>",
      },

      f:static_text {
        title = LOC "$$$/FilmEmulation/Dialog/WBDescription=Override the default warmth/tint values for this film stock.",
        width_in_chars = 50,
        height_in_lines = 2,
      },

      -- Temperature override
      f:row {
        f:checkbox {
          title = LOC "$$$/FilmEmulation/Dialog/CustomWarmth=Custom warmth:",
          value = LrView.bind 'useCustomWarmth',
          width = 130,
        },
        f:edit_field {
          value = LrView.bind 'customWarmth',
          width_in_chars = 6,
          enabled = LrView.bind 'useCustomWarmth',
          min = -100,
          max = 100,
          increment = 1,
          precision = 0,
        },
        f:static_text {
          title = LOC "$$$/FilmEmulation/Dialog/WarmthHint=(steps, e.g. +15 = warmer)",
          enabled = LrView.bind 'useCustomWarmth',
        },
      },

      -- Tint override
      f:row {
        f:checkbox {
          title = LOC "$$$/FilmEmulation/Dialog/CustomTint=Custom tint:",
          value = LrView.bind 'useCustomTint',
          width = 130,
        },
        f:edit_field {
          value = LrView.bind 'customTint',
          width_in_chars = 6,
          enabled = LrView.bind 'useCustomTint',
          min = -100,
          max = 100,
          increment = 1,
          precision = 0,
        },
        f:static_text {
          title = LOC "$$$/FilmEmulation/Dialog/TintHint=(steps, e.g. +8 = magenta)",
          enabled = LrView.bind 'useCustomTint',
        },
      },

      f:separator { fill_horizontal = 1 },

      f:static_text {
        title = LOC "$$$/FilmEmulation/Dialog/Note=Note: This will be applied to all selected photos.",
        font = "<system/small>",
      },
    }

    local result = LrDialogs.presentModalDialog {
      title = LOC "$$$/FilmEmulation/Dialog/Title=Apply Film Emulation",
      contents = contents,
      actionVerb = LOC "$$$/FilmEmulation/Dialog/Apply=Apply",
    }

    if result == 'ok' then
      -- Get selected photos
      local catalog = LrApplication.activeCatalog()
      local photos = catalog:getTargetPhotos()

      if not photos or #photos == 0 then
        LrDialogs.message(
          LOC "$$$/FilmEmulation/NoPhoto/Title=No Photos Selected",
          LOC "$$$/FilmEmulation/NoPhoto/Message=Please select one or more photos before applying a film preset.",
          "info"
        )
        return
      end

      -- Determine overrides
      local warmthOverride = properties.useCustomWarmth and properties.customWarmth or nil
      local tintOverride = properties.useCustomTint and properties.customTint or nil

      -- Apply preset in async task
      LrTasks.startAsyncTask(function()
        applyFilmPreset(properties.selectedPresetId, photos, warmthOverride, tintOverride)
      end)
    end
  end)
end

-- Entry point for the menu item
showDialog()

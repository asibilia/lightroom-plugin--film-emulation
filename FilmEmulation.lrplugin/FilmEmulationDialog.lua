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

-- Film presets available
local filmPresets = {
	{
		name = "Kodak Portra 400",
		id = "kodak_portra_400",
	},
	-- Additional presets will be added here in the future
}

-- Build a list of preset names for the popup menu
local function getPresetNames()
	local names = {}
	for i, preset in ipairs(filmPresets) do
		names[i] = preset.name
	end
	return names
end

-- Apply the selected film preset
local function applyFilmPreset(presetId)
	local catalog = LrApplication.activeCatalog()
	local targetPhoto = catalog:getTargetPhoto()
	
	if not targetPhoto then
		LrDialogs.message(
			LOC "$$$/FilmEmulation/NoPhoto/Title=No Photo Selected",
			LOC "$$$/FilmEmulation/NoPhoto/Message=Please select a photo before applying a film preset.",
			"info"
		)
		return
	end
	
	-- Placeholder for actual preset application
	-- In a full implementation, this would apply develop settings
	catalog:withWriteAccessDo(
		"Apply Film Preset",
		function()
			-- This is where we would apply the actual develop settings
			-- For now, this is just a shell
			LrDialogs.message(
				LOC "$$$/FilmEmulation/Applied/Title=Film Preset Applied",
				string.format(
					LOC "$$$/FilmEmulation/Applied/Message=The %s preset would be applied here.",
					presetId
				),
				"info"
			)
		end
	)
end

-- Main dialog function
local function showDialog()
	LrFunctionContext.callWithContext("showFilmEmulationDialog", function(context)
		
		local f = LrView.osFactory()
		local properties = LrBinding.makePropertyTable(context)
		
		-- Set default selection to the first preset
		properties.selectedPresetIndex = 1
		
		local contents = f:column {
			bind_to_object = properties,
			spacing = f:control_spacing(),
			fill = 1,
			
			f:row {
				f:static_text {
					title = LOC "$$$/FilmEmulation/Dialog/SelectPreset=Select a film preset:",
					alignment = 'right',
				},
				
				f:popup_menu {
					value = LrView.bind 'selectedPresetIndex',
					items = getPresetNames(),
					fill_horizontal = 1,
				},
			},
			
			f:row {
				f:static_text {
					title = LOC "$$$/FilmEmulation/Dialog/Description=This will apply the selected film emulation to the current photo.",
					fill_horizontal = 1,
					width_in_chars = 50,
					height_in_lines = 2,
				},
			},
		}
		
		local result = LrDialogs.presentModalDialog {
			title = LOC "$$$/FilmEmulation/Dialog/Title=Apply Film Emulation",
			contents = contents,
			actionVerb = LOC "$$$/FilmEmulation/Dialog/Apply=Apply",
		}
		
		if result == 'ok' then
			local selectedIndex = properties.selectedPresetIndex
			local selectedPreset = filmPresets[selectedIndex]
			if selectedPreset then
				applyFilmPreset(selectedPreset.id)
			end
		end
		
	end)
end

-- Entry point for the menu item
showDialog()

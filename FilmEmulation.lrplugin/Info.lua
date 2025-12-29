--[[----------------------------------------------------------------------------

Info.lua
Film Emulation Plugin for Adobe Lightroom
Main plugin information and configuration file

------------------------------------------------------------------------------]]

return {
	
	LrSdkVersion = 5.0,
	LrSdkMinimumVersion = 5.0,
	
	LrToolkitIdentifier = 'com.asibilia.lightroom.filmemulation',
	LrPluginName = LOC "$$$/FilmEmulation/PluginName=Film Emulation",
	
	LrPluginInfoUrl = "https://github.com/asibilia/lightroom-plugin--film-emulation",
	
	LrPluginInfoProvider = 'PluginInfoProvider.lua',
	
	LrLibraryMenuItems = {
		{
			title = LOC "$$$/FilmEmulation/ApplyFilmPreset=Apply Film Preset",
			file = "FilmEmulationDialog.lua",
		},
	},
	
	VERSION = { major=1, minor=0, revision=0, build=0 },

}

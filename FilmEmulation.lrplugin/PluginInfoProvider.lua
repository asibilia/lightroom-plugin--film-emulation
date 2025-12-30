--[[----------------------------------------------------------------------------

PluginInfoProvider.lua
Film Emulation Plugin for Adobe Lightroom
Provides plugin information to Lightroom Plugin Manager

------------------------------------------------------------------------------]]

local LrView = import 'LrView'

return {

  sectionsForTopOfDialog = function(f, propertyTable)
    return {
      {
        title = LOC "$$$/FilmEmulation/PluginInfo/Title=Film Emulation Plugin",

        f:row {
          f:static_text {
            title = LOC "$$$/FilmEmulation/PluginInfo/Description=This plugin allows you to apply film emulation presets to your photos.",
            fill_horizontal = 1,
          },
        },

        f:row {
          f:static_text {
            title = LOC "$$$/FilmEmulation/PluginInfo/Version=Version 1.0.0",
            fill_horizontal = 1,
          },
        },
      },
    }
  end,

}

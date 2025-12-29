# lightroom-plugin--film-emulation
Film Emulation effect LR plugin

## Overview
This Adobe Lightroom plugin allows you to apply film emulation presets to your photos directly from within Lightroom.

## Features
- Select from a list of classic film presets
- Currently available: Kodak Portra 400
- Easy-to-use dialog interface

## Installation

1. Download or clone this repository
2. In Adobe Lightroom, go to: **File > Plug-in Manager**
3. Click the **Add** button
4. Navigate to and select the `FilmEmulation.lrplugin` folder
5. Click **Done**

## Usage

1. Select a photo in Lightroom's Library module
2. Go to: **Library > Plug-in Extras > Apply Film Preset**
3. Choose a film preset from the dropdown menu
4. Click **Apply**

## Available Presets

- **Kodak Portra 400** - Classic portrait film with warm tones and smooth skin rendering

## Development

This plugin is written in Lua and uses the Adobe Lightroom SDK. The main files are:

- `Info.lua` - Plugin manifest and configuration
- `FilmEmulationDialog.lua` - Main dialog for preset selection
- `PluginInfoProvider.lua` - Plugin information display

## Version

Current version: 1.0.0

## License

See LICENSE file for details.

--[[----------------------------------------------------------------------------

portra-400/preset.lua
Kodak Portra 400 Film Emulation Preset
Based on research in README.md

------------------------------------------------------------------------------]]

return {
  id = "kodak_portra_400",
  name = "Kodak Portra 400",

  -- Relative adjustments (via quickDevelop - preserves user edits)
  -- These are applied as incremental steps, not absolute values
  relativeSteps = {
    Temperature = 15, -- Warm golden glow
    Tint = 8,         -- Slight magenta for peachy skin
    Highlights = -25, -- Soft highlight rolloff
    Shadows = 30,     -- Open shadows, film latitude
    Whites = -15,     -- Preserve highlight detail
    Blacks = 10,      -- Lifted/faded blacks
    Contrast = -10,   -- Medium/low contrast
  },

  -- Absolute settings (defines the "look")
  -- These are applied via applyDevelopSettings
  absoluteSettings = {
    -- HSL Hue adjustments
    HueAdjustmentGreen = -10, -- Olive greens (shift toward yellow)
    HueAdjustmentYellow = 5,  -- Warm olive tones in foliage
    HueAdjustmentBlue = -8,   -- Cyan-shifted blues (soft skies)

    -- HSL Saturation adjustments
    SaturationAdjustmentGreen = -20, -- Muted foliage
    SaturationAdjustmentBlue = -10,  -- Soft skies
    SaturationAdjustmentOrange = -8, -- Natural skin tones
    SaturationAdjustmentRed = -5,    -- Subdued reds, no neon

    -- Tone Curve (parametric) - lifted blacks, soft highlights
    ParametricShadows = 10,     -- Lift shadows for faded look
    ParametricHighlights = -10, -- Soft highlight rolloff

    -- Color Grading (split toning) - subtle warmth
    SplitToningShadowHue = 30,          -- Orange shadows
    SplitToningShadowSaturation = 6,    -- Very subtle
    SplitToningHighlightHue = 50,       -- Yellow highlights
    SplitToningHighlightSaturation = 4, -- Very subtle
    SplitToningBalance = 0,             -- Neutral balance

    -- Grain - fine, organic texture
    GrainAmount = 20,
    GrainSize = 20,
    GrainFrequency = 50, -- Roughness
  },
}

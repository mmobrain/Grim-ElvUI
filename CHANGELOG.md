# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v6.14] - 2026-02-22

### Fixed
- **Shaman Totem Bar Crash Bug:** Fixed a typo in the `MultiCastActionBar_Update` hook introduced in v6.12 that caused the entire ActionBars module to crash upon initialization for Shamans. The hook now correctly targets `MultiCastActionBarFrame_Update`.
- **Microbar Enhancement Compatibility:** Added fail-safe logic to `ElvUI_MicrobarEnhancement` to ensure it falls back gracefully if the internal `ElvUI_MicroBar` frame has been renamed (e.g. to `ElvUI_Ebonhold_MicroBar`), preventing a critical initialization crash.

## [v6.13] - 2026-02-22

### Fixed
- **Shaman Totem Bar Anchoring:** Fixed an issue where Shaman totems would anchor to the center of the screen instead of the Totem Bar mover due to a silent parent-frame failure in ElvUI's internal `Point()` wrapper.
- **Shaman Totem Textures:** Fixed a bug where Blizzard's default action button textures would return and overlay the totem icons after totem updates or summons.

## [v6.12] - 2026-02-20

### Fixed
- **Shaman Totem Bar Scaling Bug:** Added missing hook to `MultiCastActionBar_Update` logic so that whenever a Shaman learns a new totem, ElvUI properly applies sizing boundaries to the newly unlocked slot frame. This prevents the newly unlocked totem texture from infinitely stretching across the entire game window.

## [v6.11] - 2026-02-18

### Added
- Included Masque and various Masque skins to the pack.
- Added custom packaging workflow for easier release management.

### Changed
- Updated installation instructions to clarify folder naming requirements.
- Improved documentation on resolving merge conflicts and restart requirements.
- Fixed version check logic to prevent unnecessary popups.

## [v1.0.1] - Legacy

### Fixed
- Critical fixes for Minimap Freeze issues.
- Recursive loop fixes for SwingBar and Ebonhold Skin.
- Disabled annoying version check popup.

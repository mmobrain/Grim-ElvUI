# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v6.19] - 2026-02-23

### Fixed
- **Shaman Totem Bar Click Bugs:** Shrunk the hit rectangles (`HitRectInsets`) of Totem action buttons to 0 so they properly clip their interaction bounds to visual coordinates when `ElvUI_BarTotem` scales downwards. Increased the base `FrameLevel` of the action buttons by 2 over their slot buttons so their tooltips and click events properly capture the mouse.
- **Restore Totem Bar Option Fails:** Fixed an issue where the `Restore Bar` button inside `ElvUI_OptionsUI` failed to find the Totem Bar mover because the localization string `L[TUTORIAL_TITLE47]` was mistakenly set as a string literal instead of evaluating the WoW global variable.

## [v6.18] - 2026-02-22

### Fixed
- **Shaman Totem Edge Cases:** Fixed an issue where MultiCastActionButtons would drift and overlap their slot buttons when learning new totems or leveling up. Also cleaned up combat-lockdown deferral events to ensure the Totem layout consistently applies as soon as the Shaman drops combat, preventing the bar from becoming unclickable or misaligned.

## [v6.17] - 2026-02-22

### Fixed
- **Shaman Totem Taint Bug:** Removed a direct secure hook on `ShowMultiCastActionBar` that was triggering an `ADDON_ACTION_BLOCKED: ElvUI tried to call the protected function MultiCastActionBarFrame:Show()` when entering or leaving combat, switching stances, or clicking flyout menus. The action bar sizing and positioning are now solely handled by the safe `MultiCastActionBarFrame_Update` hook.

## [v6.16] - 2026-02-22

### Fixed
- **Shaman Totem Infinite Scaling Bug:** Resolved the underlying cause of the "viewport infinite scaling" bug for Shamans. When a totem slot became inactive (e.g. switching Totem pages or unlearning), ElvUI's internal anchor hooks (`SetAllPoints`) would receive a `nil` slot target, causing the invisible action button to default to `UIParent` and stretch enormously across the entire game screen. The anchors are now safely guarded to prevent this out-of-bounds scaling.

## [v6.15] - 2026-02-22

### Fixed
- **Shaman Totem Texture Scaling Bug:** Enforced a lockdown on Shaman Totem Action Button textures and MultiCastSlotButton texture coordinates. This prevents Blizzard's internal `MultiCastActionButton_Update` function from resetting the icons and border overlays to their un-skinned, default states—which caused them to look visually mis-scaled or squished.

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

This repository contains the ElvUI compatibility modification tailored for **Grimfall WoW**.

It is based on Qt (RosemyneH) and Xurkon's modification of Ascension 3.3.5a ElvUI, which includes numerous fixes and backwards compatibility for Project Ebonhold. For upstream details, check [Xurkon's repository](https://github.com/Xurkon/PE-ElvUI).

## Key Features & Changes

*   **Multiple Resource Tracking:** Added simultaneous tracking for Energy and Rage on **Player** and **Party** unit frames to accurately reflect Grimfall WoW's classless mechanics.


> **Configuration Required:** You must manually enable and configure the "Energy" and "Rage" bars within the ElvUI Options menu (`/ec` -> UnitFrames -> Player / Party).

## Installation

1. Download the latest `.zip` archive from the [Releases](https://github.com/mmobrain/Grim-ElvUI/releases) page.
2. Extract the contents into your `World of Warcraft\Interface\AddOns` folder.
3. **Restart WoW:** You must completely restart the World of Warcraft client for the new addons to hook into the engine. A simple UI reload (`/reload`) is **not sufficient** for newly installed directories.

## Credits

- **[Qt (RosemyneH)](https://github.com/RosemyneH/ElvUI_Ebonhold)** - Initial compatibility fixes for Ebonhold.
- **Xurkon** - Stability fixes, freeze resolutions, and pack maintenance.
- **Ascension WoW** - Base `PowerEnergy.lua` and `PowerRage.lua` scripts.
- **Skulltrail** - Modified (this) version featuring Grimfall WoW compatibility, multi-resource tracking, and UI engine fixes.
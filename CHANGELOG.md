# Changelog

All notable changes to VoidxV2 will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-01-29

### Added
- **Event System** - `Library:On()` and `Library:Emit()` for hooking into library events
- **State Management** - `Library.State:Set()`, `Library.State:Get()`, `Library.State:Watch()`
- **Key System Pro** - Rate limiting, lifecycle events (`OnChecking`, `OnSuccess`, `OnFailed`, `OnRateLimited`)
- **Theme Override System** - `Library:CreateTheme()`, `Library:OverrideTheme()`
- **Error Handling** - TypeCheck, Assert, Log functions with debug mode
- **Version Info** - `Library.Version`, `Library.Author`, `Library.GitHub`
- **Debug Mode** - `Library:SetDebug(true)` for verbose logging
- **Destroy Method** - `Library:Destroy()` cleans up all resources

### Changed
- Toggle component now supports optional `stateKey` for auto state registration
- All components now return objects with `Get()` method

### Fixed
- ColorPicker upgraded to HSV + RGB with full color control
- Settings tab now fixed at bottom of sidebar with ⚙ icon
- Loading screen redesigned as compact centered box with blur overlay

## [2.0.0] - 2026-01-29

### Added
- Complete library rewrite
- 7 theme presets (Purple, Blue, Red, Green, Orange, Pink, Dark)
- Built-in Settings tab with theme selection
- Loading screen with animated progress
- Anti-duplicate GUI system
- Notification system (info, success, warning, error)

### Components
- Button
- Toggle
- Slider
- Dropdown
- Input
- Keybind
- ColorPicker (HSV + RGB)
- Section (collapsible)
- Label
- Paragraph

## [1.0.0] - Initial Release

### Added
- Basic UI library functionality
- Simple components

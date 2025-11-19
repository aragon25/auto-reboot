# Changelog

All notable changes to this project will be documented in this file.

## [1.5-1] - TESTING

### Added
- bindings to Raspberry Pi again

### Changed
- renamed state file from {APP-NAME}_poweroff to {APP-NAME}_reboot
- state file logic swaped. now: file exists -> reboot before: file not exists -> reboot 
(better compatibility with initramfs-imgldr)

### Removed


## [1.4-3] - 2025-11-20

### Changed
- first release for github

### Removed
- bindings to Raspberry Pi

## [1.4-2] - 2025-07-06

### Fixed
- bugfix '/STATIC' folder detection

## [1.4-1] - 2025-07-01

### Fixed
- Moved and renamed statefile from /boot to /STATIC or /etc folder
- other small bugfixes

### Removed
- all bootfs relations

## [1.3-2] - 2025-02-25

### Fixed
- small bugfix

## [1.3-1] - 2024-11-22

### Fixed
- sync bugfix

## [1.2-1] - 2024-11-20

### Fixed
- small bugfixes

## [1.1-1] - 2024-11-18

### Fixed
- small bugfixes

## [1.0-1] - 2024-11-18

### Added
- First stable release

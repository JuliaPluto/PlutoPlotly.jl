# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [0.6.6] - 2026-06-04
### Fixed
- Internal refactor to use the official AbstractPlutoDingetjes API for `published_to_js` instead of relying on internals which are now deprected since Pluto v1.0, enabling support for Pluto v1.0

### Changed
- Dropped support for 1.9, with 1.10 being the earliest supported julia version
- Added compat to HypertextLiteral 1

## [0.6.5] - 2025-10-06
### Changed
This release simply bumped the Colors compat to include 0.13.

## [0.6.4] - 2025-07-17
This is the first release we track in the changelog. Changes are with respect to 0.6.3

### Fixed
- Fixed a bug in the preprocess which was not correctly handing nested object of type `Plotly.HasFields`
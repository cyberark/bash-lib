# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.1] - 2020-02-19
### Added
- Github issue related functions via the `hub` cli

### Changed
- Helpers lib now uses bash-lib logging functions

### Fixed
- Ensured that all variables used within bash-lib functions are declared as local

## [2.0.0] - 2020-01-17
### Added
- Logging Functions, with basic log level support
- Retry Constant function for when you want to retry but don't want increasing
  backoff.

### Changed
- Prefixed all function names with bl_ to prevent name clashes with builtins
  and other libraries.
- Libraries are now loaded by the init script, so they don't need to be
  sourced individually.

## [1.0.0] - 2019-11-20
### Added
- filehandling, git, helpers, k8s, logging and test-utils libraries
- Test Suite
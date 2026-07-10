# Changelog

All notable changes to this repository are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Root `.gitignore` covering macOS artifacts, editor files, secrets, and per-skill
  `CLAUDE.md` dev notes.
- Top-level `README.md` skill catalog with installation, requirements, and repository
  structure.
- `CONTRIBUTING.md` documenting the required skill structure and authoring conventions.
- `scripts/validate_skills.sh` — structural validation for every skill.
- GitHub Actions workflow that runs the validator on pull requests and pushes to `main`.
- `LICENSE` (MIT).

### Changed
- Standardized naming: lowercase `readme.md` files renamed to `README.md`; the
  `priorities` example renamed from `example_output.md` to `sample_output.md`.
- Consolidated three per-skill `.gitignore` files into the root `.gitignore`.

### Fixed
- `deadlines` sample output now matches its template: added the Deadline Source column
  and the Overdue/Upcoming split.
- Removed the dangling "adding more details later" placeholder from the `blockers`
  README and the reference to a non-existent skill-creator skill in the main README.

### Removed
- Seven committed `.DS_Store` files.

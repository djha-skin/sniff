# Changelog

This page mirrors the canonical [CHANGELOG.md](../CHANGELOG.md) at
the repository root — that file is the source of truth. All
notable changes to sniff are documented there, in Keep a Changelog
format, following Semantic Versioning.

## [Unreleased]

### Added

- **Documentation for every binding.** Docstrings on all six
  functions in `src/init.janet` (`system-config-path`,
  `home-config-path`, `from-environment`, `from-cli`,
  `resolve-expansions`, `load-options`), plus project-level
  documentation in `project.janet`.
- **A docs site.** A `docs/` folder with an overview, install
  guide, quickstart, a longer worked example, a contributing
  guide, and a changelog, published with GitHub Pages. The API
  reference (`docs/api.md`) is generated from the docstrings with
  Documentarian.
- **A root `README.md`** introducing the project and linking to
  the documentation.
- **Documentarian as a dependency.** `jpm -l deps` now installs
  Documentarian into the local tree, and a `doc` task
  (`jpm -l run doc`) regenerates `docs/api.md`.
- **A root `CHANGELOG.md`** in Keep a Changelog format.

### Changed

- **The `test` task now works.** `jpm -l test` was failing because
  the project declared an executable whose entry was a vector
  with no `main` function. The unused `declare-executable` block
  was removed, and the default `test` rule was pointed at the
  `test/` directory explicitly. sniff is a library: options are
  gathered with `load-options`, and there is no `execute-program`.
- **Project description.** `project.janet` now describes what
  sniff does instead of the placeholder `SNIFF`.

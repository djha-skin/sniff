# Install

sniff is a Janet library built with
[jpm](https://github.com/janet-lang/jpm). Add it to a project's
`:dependencies` and let jpm do the rest.

## Prerequisites

- **Janet (≥ 1.36)** — sniff itself needs only a normal Janet
  install, but the docs build uses
  [Documentarian](https://github.com/pyrmont/documentarian),
  whose current release requires the `bundle/*` module that landed
  in janet 1.36. On Fedora, `dnf install janet` is enough for
  running programs that use sniff; build janet from source only if
  you also want to build native modules or executables.

## Install from a git URL

Add sniff to the `:dependencies` list of a `project.janet`:

```janet
(declare-project
  :name "my-program"
  :description "A program that uses sniff."
  :version "0.1.0"
  :author "You"
  :license "MIT"
  :dependencies [{:url "https://github.com/djha-skin/sniff"}])
```

Then install the dependencies into the project-local tree:

```bash
jpm -l deps
```

## Build from source

To work on sniff itself, clone the repository and install its
dependencies:

```bash
git clone https://github.com/djha-skin/sniff
cd sniff
jpm -l deps
```

## Building the docs

The API reference (`docs/api.md`) is generated from the docstrings
with [Documentarian](https://github.com/pyrmont/documentarian),
which `jpm -l deps` installs into the local tree as a regular
dependency:

```bash
jpm -l run doc      # regenerates docs/api.md
```

The `doc` task locates the locally installed `documentarian`
under `jpm_tree/lib/bin` and runs it with `JANET_PATH` pointing at
`./jpm_tree/lib`. The other docs pages are hand-written Markdown
and need no build step.

## Check the installation

From the repository root, load the library and gather options
from an empty command line:

```bash
janet -e '(import ./src) (pp (src/load-options "probe" {} @[]))'
```

```janet
[{} @[]]
```

An empty options table and an empty arguments array, because
`probe` has no configuration files, no environment variables, and
no command line. Once a program, its configuration files, and its
environment exist, the same call returns the gathered options
tower.

## Notes

- The build is reproducible: dependencies live in the
  project-local `./jpm_tree`, never in a global install.
- sniff is a pure-Janet library; there is nothing to compile, so
  no C toolchain or `libjanet.a` is needed to use it.

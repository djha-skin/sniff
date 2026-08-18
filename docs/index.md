# sniff

sniff gathers a program's options from configuration files, the
environment, and the command line into a single table — an
"options tower". Instead of writing the same configuration-loading
code for every program, you call one function, `load-options`, and
get back one table of options and the leftover command-line
arguments. It is a Janet port of the Common Lisp
[CLIFF](https://github.com/djha-skin/cliff) library, heavily
simplified: options are gathered, never declared or validated.

The mental model is small:

- **Four sources of options.** The system-wide configuration file,
  the per-user configuration file, the project configuration file,
  environment variables, and the command line — each one layered
  on top of the last. Later sources win: a command-line option
  beats an environment variable, which beats any configuration
  file.
- **Configuration is NRDL.** Every configuration file and every
  option value is written in [NRDL](https://github.com/djha-skin/nrdl)
  (Nestable Readable Document Language), a JSON superset. Options
  arrive already typed: numbers as numbers, booleans as booleans,
  keywords as keywords, strings as strings, and whole tables and
  arrays where a value calls for them.
- **Short flags are expansions.** There is no option parser to
  teach. A mapping from shorthand terms (like `-h`) to full terms
  (like `--set-help true`) is applied to the command line before
  options are gathered.
- **One function to call.** `load-options` returns `[options
  arguments]` — the gathered options as a table, and the leftover
  arguments as an array. What you do with them is up to you.

## How it fits

sniff pairs well with the rest of the ecosystem:

- **NRDL** — the format of every configuration file and option
  value. sniff depends on it and uses its parser directly.
- **CLIFF** — the Common Lisp library sniff ports. Where CLIFF
  declares options with NRDL, validates them, and runs a
  subcommand dispatch (`execute-program`), sniff stops earlier: it
  gathers options and returns, and the calling program decides
  what they mean.
- **Any jpm-built CLI tool** — a program built with
  [jpm](https://github.com/janet-lang/jpm) can import sniff and
  get its configuration loading in one call.

## What it does not do

sniff is deliberately small:

- **It does not declare options.** There is no schema: any
  option that arrives from any source is kept, whether or not the
  program knows about it.
- **It does not validate options.** Types are whatever NRDL
  parsed them as; nothing checks that `:port` is a number or that
  `:verbose` is a boolean.
- **It does not dispatch.** There is no `execute-program`, no
  subcommand machinery. `load-options` returns `[options
  arguments]` and stops; the program does its own dispatch.
- **It does not generate help.** No `--help` handling, no usage
  text. Expansions can map `-h` to whatever a program wants it to
  mean.

## Where to go next

- [Install](install.html) — get sniff into your project.
- [Quickstart](quickstart.html) — a five-minute tour that builds
  a small CLI with options from every source.
- [A longer example](a-longer-example.html) — a complete program
  with expansions, three configuration layers, environment
  variables, and command-line options, showing precedence end to
  end.
- [Contributing](contributing.html) — how to help.
- [Changelog](changelog.html) — what changed, version by version.
- [API reference](api.html) — generated from the docstrings.

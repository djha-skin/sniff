# sniff API

  sniff gathers a program's options from configuration files, the
  environment, and the command line into a single table — an
  "options tower". It is a Janet port of the Common Lisp CLIFF
  library, simplified to gather options without declaring or
  validating them.

  Options come from, in increasing order of precedence: the
  system-wide configuration file, the per-user configuration file,
  the project configuration file, environment variables, and the
  command line. Configuration files and option values are written
  in NRDL, so options arrive already typed — numbers as numbers,
  booleans as booleans, keywords as keywords.
  

## src/init

[from-cli](#from-cli), [from-environment](#from-environment), [home-config-path](#home-config-path), [load-options](#load-options), [resolve-expansions](#resolve-expansions), [system-config-path](#system-config-path)

## from-cli

**function**  | [source][1]

```janet
(from-cli cli)
```

Parse the command line CLI into options and arguments.

A term of the form `--set-<option>` consumes the following term
as the value of the option `:option`, parsed as an NRDL
document. Every other term is an argument, including `--` terms
that are not `--set-` options. Returns `[options arguments]`,
where OPTIONS is a table of option keywords to values and
ARGUMENTS is an array of the remaining terms. Signals an error
when a `--set-` option is the last term, with no value after it.

[1]: src/init.janet#L98


## from-environment

**function**  | [source][2]

```janet
(from-environment program-name env)
```

Gather options from the environment table ENV.

Every variable named `<PROGRAM-NAME>_<option>`, where the program
name is upper-cased and the option part is lower-cased,
contributes the option `:option`. The value of the variable is
parsed as an NRDL document, so numbers, booleans, keywords,
strings, arrays, and tables all arrive already typed. Returns a
table mapping option keywords to values.

[2]: src/init.janet#L73


## home-config-path

**function**  | [source][3]

```janet
(home-config-path program-name env which)
```

Return the path to the per-user configuration file for
PROGRAM-NAME.

The path depends on the operating system and on the user's
environment, read from ENV:

* `:windows` — `%LOCALAPPDATA%\<program-name>\config.nrdl`,
  falling back to
  `%USERPROFILE%\AppData\Local\<program-name>\config.nrdl`
* `:macos` — `$HOME/Library/Preferences/<program-name>/config.nrdl`
* `:linux` — `$XDG_CONFIG_HOME/<program-name>/config.nrdl`,
  falling back to `$HOME/.config/<program-name>/config.nrdl`

Signals an error when the environment does not define the
variable the chosen location depends on.

[3]: src/init.janet#L29


## load-options

**function**  | [source][4]

```janet
(load-options program-name expansions &opt cli env cwd which process check)
```

Gather the options for PROGRAM-NAME from the configuration
files, the environment, and the command line.

The options tower is built from, in increasing order of
precedence:

1. The system-wide configuration file
   (`system-config-path`).
2. The per-user configuration file
   (`home-config-path`).
3. The project configuration file,
   `<cwd>/<program-name>.nrdl`.
4. The environment (`from-environment`).
5. The command line (`from-cli`), with EXPANSIONS applied first
   (`resolve-expansions`).

Each configuration file is parsed as an NRDL object; only files
that exist are read, using CHECK to test and PROCESS to read
them. Later sources overwrite earlier ones, so a command-line
option beats an environment variable, which beats any
configuration file.

CLI defaults to `*args*`, ENV to `(os/environ)`, CWD to
`(os/cwd)`, WHICH to `(os/which)`, PROCESS to `slurp`, and CHECK
to `os/stat`. Signals an error when PROGRAM-NAME is empty.
Returns `[options arguments]`: the gathered options as a table
of keywords to values, and the leftover command-line arguments
as an array.

[4]: src/init.janet#L147


## resolve-expansions

**function**  | [source][5]

```janet
(resolve-expansions expansions cli)
```

Expand shorthand terms in CLI using the EXPANSIONS table.

Each key of EXPANSIONS is a term; when that term appears in CLI,
it is replaced in place by the key's value, an array of terms.
Terms that are not keys of EXPANSIONS pass through unchanged.
Returns a new array of terms.

[5]: src/init.janet#L130


## system-config-path

**function**  | [source][6]

```janet
(system-config-path program-name which)
```

Return the path to the system-wide configuration file for
PROGRAM-NAME.

The path depends on the operating system, as reported by WHICH:

* `:linux` — `/etc/<program-name>/config.nrdl`
* `:macos` — `/Library/Preferences/<program-name>/config.nrdl`
* `:windows` — `C:\ProgramData\<program-name>\config.nrdl`

The file may or may not exist; the path is returned either way.

[6]: src/init.janet#L8


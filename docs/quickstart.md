# Quickstart

This is a five-minute tour: build a tiny program called `goose`
that gathers its options with sniff, then feed it options from a
configuration file, an environment variable, and the command line
— and watch the later sources win. Run the commands in a scratch
directory to follow along.

By the end you will have:

- A program whose options come from three different sources.
- An understanding of how those sources layer into a tower.
- A working `load-options` call you can copy into a real program.

## Write the program

Put this in a file called `goose.janet`:

```janet
(import sniff)

(defn main [& args]
  (def [options arguments]
    (sniff/load-options
      "goose"
      {"-n"  ["--set-name"]
       "-l"  ["--set-loud" "true"]}
      args))
  (def greeting (string "Hello, " (or (options :name) "world") "!"))
  (print (if (options :loud) (string/ascii-upper greeting) greeting))
  (print "leftover arguments: " (string/join arguments " ")))
```

Run it with no options at all:

```bash
janet goose.janet
```

```text
Hello, world!
leftover arguments:
```

`load-options` returned `[options arguments]`; there were no
options and no arguments, so the program fell back to its defaults.

## Add a configuration file

sniff looks for `<cwd>/<program-name>.nrdl` — a project
configuration file in the current directory. Create `goose.nrdl`:

```janet
{
  name "Grayson"
  loud true
}
```

Run the program again:

```bash
janet goose.janet
```

```text
HELLO, GRAYSON!
leftover arguments:
```

Both options came from the configuration file, parsed as NRDL:
`name` became the string `"Grayson"` and `loud` became the
boolean `true`.

## Add an environment variable

Environment variables use the pattern
`<PROGRAM-NAME>_<option>`, with the program name upper-cased and
the option lower-cased. Set one and run:

```bash
GOOSE_NAME="Fern" janet goose.janet
```

```text
HELLO, FERN!
leftover arguments:
```

The environment variable `GOOSE_NAME` set the `:name` option,
overwriting the value from the configuration file. The `:loud`
option still came from `goose.nrdl`.

## Add the command line

Command-line options use the `--set-<option>` form, and the
`expansions` table gives them short aliases. Pass one:

```bash
GOOSE_NAME="Fern" janet goose.janet -n "Sofia" extra words
```

```text
HELLO, SOFIA!
leftover arguments: extra words
```

The expansion `-n` became `--set-name "Sofia"`, so the
command-line option overwrote the environment variable. The
options tower, from weakest to strongest:

1. System-wide configuration file.
2. Per-user configuration file.
3. Project configuration file (`goose.nrdl`).
4. Environment variables (`GOOSE_NAME`).
5. Command line (`-n "Sofia"`).

Each source overwrites the sources below it, so the final `:name`
was `"Sofia"` — and `extra` and `words` came back as arguments,
untouched.

## What's next

- The [longer example](a-longer-example.html) builds a complete
  program with all three configuration layers, expansions, and
  precedence worked out end to end.
- The [API reference](api.html) documents `load-options` and the
  helpers it is built from, generated from the docstrings.

# sniff

Do you want your Janet program to look at configuration files, the
environment, and the command line to get its options, without
having to *code* any of that stuff? Feel bogged down writing the
same old I/O code for every program?

Then sniff is for you!

sniff gathers a program's options into a single table — an
"options tower" — from, in increasing order of precedence:

1. The system-wide configuration file
   (`/etc/<program>/config.nrdl`).
2. The per-user configuration file
   (`~/.config/<program>/config.nrdl`).
3. The project configuration file (`<cwd>/<program>.nrdl`).
4. Environment variables (`<PROGRAM>_<option>`).
5. The command line (`--set-<option>`).

Configuration files and option values are written in
[NRDL](https://github.com/djha-skin/nrdl), a JSON superset, so
options arrive already typed. It is a Janet port of the Common
Lisp [CLIFF](https://github.com/djha-skin/cliff) library,
simplified to gather options without declaring or validating them.

## Use it

```janet
(import sniff)

(defn main [& args]
  (def [options arguments]
    (sniff/load-options
      "my-program"
      {"-h" ["--set-help" "true"]
       "-p" ["--set-port"]}
      args))
  ...)
```

## Get it

Add sniff to your project's `:dependencies` in `project.janet`
and run `jpm -l deps`:

```janet
{:url "https://github.com/djha-skin/sniff"}
```

## Documentation

Documentation including installation, a quickstart, a longer
worked example, and the API reference can be found
[here](https://djha-skin.github.io/sniff).

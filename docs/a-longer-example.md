# A Longer Example

The quickstart showed the whole loop with one configuration file.
This page builds a complete program — a small deployment tool
called `carillon` — and works through every source of options
sniff gathers: the system-wide configuration file, the per-user
configuration file, the project configuration file, environment
variables, and the command line. Along the way it shows how the
sources layer into a tower, how expansions turn short flags into
full options, and how the leftover arguments come back untouched.

## The scenario

A team deploys a web application called `bellhop` to a handful of
regions. Each machine that deploys has a system-wide `carillon`
configuration written by ops; each engineer has a per-user
configuration with their own preferences; and each checkout of
the application carries a project configuration describing the
app. Options should come from all of these, with the most
specific source winning.

## The configuration files

Ops writes the machine-wide defaults to
`/etc/carillon/config.nrdl`:

```janet
{
  host "deploy.bellhop.example"
  port 2222
  region "us-east-1"
  timeout 300
}
```

Each engineer's home configuration lives at
`~/.config/carillon/config.nrdl` (on Linux, where
`XDG_CONFIG_HOME` is unset):

```janet
{
  user "grayson"
  verbose false
}
```

And each checkout of the application carries
`bellhop/carillon.nrdl` — the project configuration, read from
the current working directory:

```janet
{
  app "bellhop"
  workers 4
  timeout 600
}
```

Note that `timeout` appears in both the system configuration and
the project configuration. The project file wins.

## The program

`carillon.janet` gathers its options with one call:

```janet
(import sniff)

(defn main [& args]
  (def [options arguments]
    (sniff/load-options
      "carillon"
      {"-h"         ["--set-help" "true"]
       "--help"     ["--set-help" "true"]
       "-r"         ["--set-region"]
       "--region"   ["--set-region"]
       "-v"         ["--set-verbose" "true"]
       "--no-verbose" ["--set-verbose" "false"]
       "-n"         ["--set-dry-run" "true"]
       "--dry-run"  ["--set-dry-run" "true"]}
      args))
  (when (options :help)
    (print "usage: carillon [options] <environment>")
    (os/exit 0))
  (printf "deploying %s to %s as %s"
          (or (options :app) "bellhop")
          (or (options :region) "us-east-1")
          (or (options :user) (os/getenv "USER")))
  (printf "  host %s:%d, %d workers, timeout %ds"
          (options :host "deploy.bellhop.example")
          (options :port 2222)
          (options :workers 1)
          (options :timeout 300))
  (printf "  verbose=%s dry-run=%s"
          (options :verbose false)
          (options :dry-run false))
  (unless (empty? arguments)
    (print "  environment: " (string/join arguments " "))))
```

There is no option-parsing code anywhere in the program. The
`expansions` table maps every shorthand — `-h`, `-r`, `-v`, `-n`
and their long forms — to `--set-` options; the environment
variables and configuration files need no code at all.

## Run one: everything at once

An engineer deploys from the `bellhop` checkout, overriding the
region and asking for a dry run:

```bash
CARILLON_VERBOSE=true \
  janet carillon.janet -r eu-west-1 -n production
```

```text
deploying bellhop to eu-west-1 as grayson
  host deploy.bellhop.example:2222, 4 workers, timeout 600s
  verbose=true dry-run=true
  environment: production
```

Reading the tower from the bottom up:

| Option    | Sys | Home | Proj | Env             | CLI           | Winner |
|-----------|-----|------|------|-----------------|---------------|--------|
| `host`    | ✓   |      |      |                 |               | system |
| `port`    | ✓   |      |      |                 |               | system |
| `user`    |     | ✓    |      |                 |               | home   |
| `app`     |     |      | ✓    |                 |               | proj   |
| `workers` |     |      | ✓    |                 |               | proj   |
| `timeout` | ✓   |      | ✓    |                 |               | proj   |
| `region`  | ✓   |      |      |                 | `-r`          | cli    |
| `verbose` |     | ✓    |      | `CARILLON_VERBOSE` | `-v`       | cli    |
| `dry-run` |     |      |      |                 | `-n`          | cli    |
| `help`    |     |      |      |                 | `-h`/`--help` | cli    |

Each source filled in what the sources below it left unset, and
overwrote what they set: the project `timeout` beat the system
`timeout`, and the command line beat everything.

## Run two: the arguments come back

Options and arguments are gathered together but returned apart.
The arguments — here, the environment to deploy to — are whatever
was left after the `--set-` options consumed their values:

```bash
janet carillon.janet staging canary
```

```text
deploying bellhop to us-east-1 as grayson
  host deploy.bellhop.example:2222, 4 workers, timeout 600s
  verbose=false dry-run=false
  environment: staging canary
```

With no `-r` or `-v` on the command line, `region` falls back to
the system value and `verbose` to the home value. `staging` and
`canary` were never options, so both came back in `arguments`.

## Run three: what the options tower is not

Because sniff only gathers, nothing stops a value from being the
wrong type. If the project configuration said `workers "four"`,
`:workers` would arrive as the string `"four"`, and `%d` in the
program would print it as-is (or the program could error on its
own). sniff's job is to collect, not to judge:

```bash
CARILLON_WORKERS=8 janet carillon.janet
```

```text
deploying bellhop to us-east-1 as grayson
  host deploy.bellhop.example:2222, 8 workers, timeout 600s
  verbose=false dry-run=false
```

`CARILLON_WORKERS=8` — the environment variable — overwrote the
project's `workers 4`, because the environment sits above the
project configuration in the tower. If that is not what the team
wants, the program can always validate after gathering; sniff
will not stop it.

## What's next

- The [API reference](api.html) documents `load-options` and the
  helpers it is built from.
- [Install](install.html) covers adding sniff to a real project.
- The [quickstart](quickstart.html) is the shorter, five-minute
  version of this walkthrough.

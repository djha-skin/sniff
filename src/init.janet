# src/init.janet
#
# sniff — gather options from configuration files, environment
# variables, and the command line into a single options table.

(import nrdl)

(defn system-config-path
  ```
  Return the path to the system-wide configuration file for
  PROGRAM-NAME.

  The path depends on the operating system, as reported by WHICH:

  * `:linux` — `/etc/<program-name>/config.nrdl`
  * `:macos` — `/Library/Preferences/<program-name>/config.nrdl`
  * `:windows` — `C:\ProgramData\<program-name>\config.nrdl`

  The file may or may not exist; the path is returned either way.
  ```
  [program-name which]
  (match which
    :linux (string/join ["/etc" program-name "config.nrdl"] "/")
    :macos (string/join ["/Library" "Preferences" program-name
                         "config.nrdl"] "/")
    :windows (string/join ["C:" "ProgramData" program-name
                           "config.nrdl"] "\\")))

(defn home-config-path
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
  ```
  [program-name env which]
  (match which
    :windows (let [local-app-data (env "LOCALAPPDATA")]
               (if local-app-data
                 (string/join [local-app-data program-name "config.nrdl"] "\\")
                 (let [userprof (env "USERPROFILE")]
                   (if userprof
                     (string/join [userprof "AppData" "Local" program-name
                                   "config.nrdl"] "\\")
                     (error "USERPROFILE not defined in the environment.")))))
    :macos (let [home (env "HOME")]
             (if (not home)
               (error "HOME not defined in the environment.")
               (string/join [home "Library" "Preferences" program-name
                             "config.nrdl"] "/")))
    :linux (let [xdg-config-home
                 (env "XDG_CONFIG_HOME")]
             (if (not xdg-config-home)
               (let [home (env "HOME")]
                 (if (not home)
                   (error "HOME not defined in the environment.")
                   (string/join [home ".config" program-name "config.nrdl"]
                                "/")))
               (string/join [xdg-config-home program-name "config.nrdl"]
                            "/")))))

(defn from-environment
  ```
  Gather options from the environment table ENV.

  Every variable named `<PROGRAM-NAME>_<option>`, where the program
  name is upper-cased and the option part is lower-cased,
  contributes the option `:option`. The value of the variable is
  parsed as an NRDL document, so numbers, booleans, keywords,
  strings, arrays, and tables all arrive already typed. Returns a
  table mapping option keywords to values.
  ```
  [program-name env]
  (let [b ~{:und "_"
            :name ,(string/ascii-upper program-name)
            :option (replace (capture (any (range "az" "AZ")))
                             ,string/ascii-lower)
            :main (sequence :name :und :option)}
        results @{}]
    (loop [[var val] :pairs env]
      (let [matches (peg/match b var)]
        (when matches
          (loop [mtch :in matches]
            (put results (keyword mtch) (nrdl/parse-from val))))))
    results))

(defn from-cli
  ```
  Parse the command line CLI into options and arguments.

  A term of the form `--set-<option>` consumes the following term
  as the value of the option `:option`, parsed as an NRDL
  document. Every other term is an argument, including `--` terms
  that are not `--set-` options. Returns `[options arguments]`,
  where OPTIONS is a table of option keywords to values and
  ARGUMENTS is an array of the remaining terms. Signals an error
  when a `--set-` option is the last term, with no value after it.
  ```
  [cli]
  (var i 0)
  (def arguments @[])
  (def options @{})
  (while (< i (length cli))
    (let [term (get cli i)]
      (cond
        (< (length term) 6) (array/push arguments term)
        (= (string/slice term 0 6) "--set-")
        (let [opt (string/slice term 6)]
          (++ i)
          (if (= i (length cli))
            (error (string/format
                     "Given option `%s` but no value for it"
                     opt))
            (put options (keyword opt) (nrdl/parse-from (get cli i)))))
        (array/push arguments term)))
    (++ i))
  [options arguments])

(defn resolve-expansions
  ```
  Expand shorthand terms in CLI using the EXPANSIONS table.

  Each key of EXPANSIONS is a term; when that term appears in CLI,
  it is replaced in place by the key's value, an array of terms.
  Terms that are not keys of EXPANSIONS pass through unchanged.
  Returns a new array of terms.
  ```
  [expansions cli]
  (def resultant-cli @[])
  (loop [term :in cli]
    (if-let [expansion (get expansions term)]
      (array/concat resultant-cli expansion)
      (array/push resultant-cli term)))
  resultant-cli)

(defn load-options
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
  ```
  [program-name expansions &opt cli env cwd which process check]
  (default cli *args*)
  (default env (os/environ))
  (default cwd (os/cwd))
  (default which (os/which))
  (default process slurp)
  (default check os/stat)
  (unless (and program-name (not (empty? program-name)))
    (error "Need a non-empty program name"))
  (let [results @{}
        [options subcommands]
        (from-cli (resolve-expansions expansions cli))
        configs [(system-config-path program-name which)
                 (home-config-path program-name env which)
                 (string/join
                   [cwd
                    (string/join [program-name "nrdl"] ".")]
                   (match which
                     :windows "\\"
                     _ "/"))]]
    (loop [config :in configs]
      (when (check config)
        (merge-into results (nrdl/parse-from (process config)))))
    [(merge
       results
       (from-environment program-name env)
       options)
     subcommands]))

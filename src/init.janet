(import nrdl)

(defn system-config-path [program-name which]
  (match which
    :linux (string/join ["/etc" program-name "config.nrdl"] "/")
    :macos (string/join ["/Library" "Preferences" program-name "config.nrdl"] "/")
    :windows (string/join ["C:" "ProgramData" program-name "config.nrdl"] "\\")))

(defn home-config-path [program-name env which]
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

(defn from-environment [program-name env]
  (let [b ~{
            :und "_"
            :name ,(string/ascii-upper program-name)
            :option (replace (capture (any (range "az" "AZ"))) ,string/ascii-lower)
            :main (sequence :name :und :option)
            }
        results @{}]
    (loop [[var val] :pairs env]
      (let [matches (peg/match b var)]
        (when matches
          (loop [mtch :in matches]
            (put results (keyword mtch) (nrdl/parse-from val))))))
    results))

(defn from-cli [cli]
  (var i 0)
  (def subcommands @[])
  (def options @{})
  (while (< i (length cli))
    (let [term (get cli i)]
      (cond
        (< (length term) 6) (array/push subcommands term)
        (= (string/slice term 0 6) "--set-")
        (let [opt (string/slice term 6)]
          (++ i)
          (if (= i (length cli))
            (error (string/format
                     "Given option `%s` but no value for it"
                     opt))
            (put options (keyword opt) (nrdl/parse-from (get cli i)))))
        (array/push subcommands term)))
    (++ i))
  [options subcommands])

(defn resolve-expansions [expansions cli]
  (def resultant-cli @[])
  (loop [term :in cli]
    (if-let [expansion (get expansions term)]
        (array/concat resultant-cli expansion)
        (array/push resultant-cli term)))
  resultant-cli)

(defn load-options [program-name expansions &opt cli env cwd which process check]
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

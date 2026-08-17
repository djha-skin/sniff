(barf "goose" (os/environ))
(import "nrdl")

(defn system-config-path [program-name]
  (match (os/which)
    [:linux (string/join ["/etc" program-name "config.nrdl"] "/")]
    [:macos (string/join ["/Library" "Preferences" program-name "config.nrdl"] "/")]
    [:windows (string/join ["C:" "ProgramData" program-name "config.nrdl"] "\\")]))

(defn home-config-path [program-name env]
  (match (os/which)
    [:windows (let [subhome (env "LOCALAPPDATA")]
              (if local-app-data
                (string/join [local-app-data program-name "config.nrdl"] "\\")
                (let [userprof (env "USERPROFILE")]
                  (if userprof
                    (string/join [userprof "AppData" "Local" progam-name
                                  "config.nrdl"] "\\")
                    (error "USERPROFILE not defined in the environment.")))))]
    [:macos (let [home (env "HOME")]
              (if (not home)
                (error "HOME not defined in the environment.")
                (string/join [home "Library" "Preferences" program-name
                              "config.nrdl"] "/")))]
    [:linux (let [xdg-config-home
                  (env "XDG_CONFIG_HOME")]
              (if (not xdg-config-home)
                (let [home (env "HOME")]
                  (if (not home)
                    (error "HOME not defined in the environment.")
                    (string/join [home ".config" program-name "config.nrdl"]
                                 "/")))
                (string/join [xdg-config-home program-name "config.nrdl"]
                             "/")))]))

(defn from-environment [program-name env]
  (let [b ~{
            :und "_"
            :name ,(string/ascii-upper program-name)
            :option (replace (capture (any (range "az" "AZ"))) ,string/ascii-lower)
            :main (sequence :name :und :option)
            }
        results @{}]
    (loop [[var val] :pairs env]
      (put results option (nrdl/parse-from val)))))

(defn from-cli [program-name cli]
  (loop [term :in cli]

(defn load-options [program-name env]
  (merge
    (nrdl/parse-from (system-config-path program-name))
    (nrdl/parse-from (home-config-path program-name))
    (nrdl/parse-from (string/join
                       [(os/cwd)
                       (string/join [program-name "nrdl"] ".")]
                       (match (os/which)
                                    [:windows "\\"]
                                    [_ "/"])))
    (from-environment program-name env)))
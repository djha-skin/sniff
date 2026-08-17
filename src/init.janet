(import nrdl)
(use judge)

(defn system-config-path [program-name which]
  (match which
    :linux (string/join ["/etc" program-name "config.nrdl"] "/")
    :macos (string/join ["/Library" "Preferences" program-name "config.nrdl"] "/")
    :windows (string/join ["C:" "ProgramData" program-name "config.nrdl"] "\\")))

(test (system-config-path "goose" :linux) "/etc/goose/config.nrdl")
(test (system-config-path "goose" :macos) "/Library/Preferences/goose/config.nrdl")
(test (system-config-path "goose" :windows) "C:\\ProgramData\\goose\\config.nrdl")


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

# Error cases
(test-error (home-config-path "foo" {} :linux) "HOME not defined in the environment.")
(test-error (home-config-path "foo" {} :macos) "HOME not defined in the environment.")
(test-error (home-config-path "foo" {} :windows) "USERPROFILE not defined in the environment.")

# These should work, but barely
(test (home-config-path "foo" {"HOME" "/home/foo"} :linux) "/home/foo/.config/foo/config.nrdl")
(test (home-config-path "foo" {"HOME" "/home/foo"} :macos) "/home/foo/Library/Preferences/foo/config.nrdl")
(test (home-config-path "foo" {"USERPROFILE" "C:\\Users\\foo"} :windows) "C:\\Users\\foo\\AppData\\Local\\foo\\config.nrdl")

# These should super seriously work
(test (home-config-path "foo" {"XDG_CONFIG_HOME" "/home/foo/.config"} :linux) "/home/foo/.config/foo/config.nrdl")
(test (home-config-path "foo" {"USERPROFILE" "C:\\Users\\foo\\AppData\\Local"} :windows) "C:\\Users\\foo\\AppData\\Local\\AppData\\Local\\foo\\config.nrdl")

# TODO This is _all kinds_ of messed up
#(defn from-environment [program-name env which
#  (let [b ~{
#            :und "_"
#            :name ,(string/ascii-upper program-name)
#            :option (replace (capture (any (range "az" "AZ"))) ,string/ascii-lower)
#            :main (sequence :name :und :option)
#            }
#        results @{}]
#    (loop [[var val] :pairs env]
#      (put results (keyword option)
#           (nrdl/parse-from val)))))
#
#(defn from-cli [program-name cli]
#  (def i 0)
#  (def subcommands @[])
#  (def options @{})
#  (while (< i (length cli))
#    (let [term (get cli i)]
#      (cond
#        (< (length term) 1) (array/push subcommands term)
#        (= (string/slice term 0 1) "-")
#        (let [opt (string/slice term 1)]
#          (++ i)
#          (if (= i (length cli))
#            (error (string/format
#                     "Given option `%s` but no value for it"
#                     opt))
#            (put options (keyword opt) (nrdl/parse-from (get cli i)))))
#        (array/push subcommands term)))
#    (++ i))
#  [options subcommands])
#
#(defn resolve-expansions [cli aliases]
#  (def resultant-cli @[])
#  (loop [term :in cli]
#    (let [expansion (get aliases term)]
#      (if expansion
#        (array/concat resultant-cli expansion)
#        (array/push resultant-cli term))))
#  resultant-cli)
#
#(defn load-options [program-name expansions cli env os]
#  (let [[options subcommands] (from-cli cli)]
#    [(merge
#       (nrdl/parse-from (system-config-path program-name))
#       (nrdl/parse-from (home-config-path program-name))
#       (nrdl/parse-from (string/join
#                          [(os/cwd)
#                           (string/join [program-name "nrdl"] ".")]
#                          (match (os/which)
#                            [:windows "\\"]
#                            [_ "/"])))
#       (from-environment program-name env)
#       options)
#     subcommands]))

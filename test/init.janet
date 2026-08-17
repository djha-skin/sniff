(use ../src)
(use judge)

(deftest system-config-path
  (test (system-config-path "goose" :linux)
        "/etc/goose/config.nrdl")
  (test (system-config-path "goose" :macos)
        "/Library/Preferences/goose/config.nrdl")
  (test (system-config-path "goose" :windows)
        "C:\\ProgramData\\goose\\config.nrdl"))

# Error cases
(deftest home-config-path
  (test-error (home-config-path "foo" {} :linux)
              "HOME not defined in the environment.")
  (test-error (home-config-path "foo" {} :macos)
              "HOME not defined in the environment.")
  (test-error (home-config-path "foo" {} :windows)
              "USERPROFILE not defined in the environment.")

  # These should work, but barely
  (test (home-config-path "foo" {"HOME" "/home/foo"} :linux)
        "/home/foo/.config/foo/config.nrdl")
  (test (home-config-path "foo" {"HOME" "/home/foo"} :macos)
        "/home/foo/Library/Preferences/foo/config.nrdl")
  (test (home-config-path "foo" {"USERPROFILE" "C:\\Users\\foo"} :windows)
        "C:\\Users\\foo\\AppData\\Local\\foo\\config.nrdl")

  # These should super seriously work
  (test (home-config-path "foo" {"XDG_CONFIG_HOME" "/home/foo/.config"} :linux)
        "/home/foo/.config/foo/config.nrdl")
  (test (home-config-path "foo" {"USERPROFILE" "C:\\Users\\foo\\AppData\\Local"} :windows)
        "C:\\Users\\foo\\AppData\\Local\\AppData\\Local\\foo\\config.nrdl"))

(deftest from-environment
  (test (from-environment "fydo"
                        {
                         "FYDO_NUMBER" "1"
                         "FYDO_STRING" "\"butwhy\""
                         "FYDO_SYMBOL" "barf"
                         "FYDO_BOOL" "true"
                         "FYDO_MAP" "{:a 1 :b 2 :c 3}"
                         "FYDO_LIST" "[4 5 6]"
                         "ACHE" "bake"})
    @{:bool true
      :list @[4 5 6]
      :map @{:a 1 :b 2 :c 3}
      :number 1
      :string "butwhy"
      :symbol :barf})
  # Stuff shouldn't work if it's not upper case
  (test (from-environment "fydo"
                        {
                         "fydo_NUMBER" "1"
                         "fydo_STRING" "\"butwhy\""
                         "fydo_SYMBOL" "barf"
                         "fydo_BOOL" "true"
                         "fydo_MAP" "{:a 1 :b 2 :c 3}"
                         "fydo_LIST" "[4 5 6]"
                         "acHe" "bake"})
    @{})

  # Stuff shouldn't work if there's no environment
  (test (from-environment "fydo" {}) @{}))

(deftest from-cli
  (test (from-cli ["--set-elegance" "9001"
                   "for" "honor"])
        [@{:elegance 9001} @["for" "honor"]])
  (test (from-cli []) [@{} @[]])
  (test (from-cli ["--set-this" "true"
                   "--set-that" "false"
                   "--set-this-love" "toll"
                   # This is _obnoxious_
                   "--set-why-not" "\"BECAUSE\""
                   "--set-men-on-dead-mans-chest" "15"
                   "brian" "you're an imbecile"])
        [@{:men-on-dead-mans-chest 15
           :that false
           :this true
           :this-love :toll
           :why-not "BECAUSE"}
         @["brian" "you're an imbecile"]])

  (test (from-cli ["--this" "true"
                   "--that" "false"
                   "--this-love" "toll"
                   # This is _obnoxious_
                   "--why-not" "\"BECAUSE\""
                   "--men-on-dead-mans-chest" "15"
                   "brian" "you're an imbecile"])
        [@{}
         @["--this"
           "true"
           "--that"
           "false"
           "--this-love"
           "toll"
           "--why-not"
           "\"BECAUSE\""
           "--men-on-dead-mans-chest"
           "15"
           "brian"
           "you're an imbecile"]]))

(deftest resolve-expansions
  (test (resolve-expansions {"-h" ["help"]
                             "--this" ["--set-this" "true"]
                             "--no-this" ["--set-this" "false"]
                             "--that" ["--set-that" "jousts" "you fart bag"]
                             }
                            ["-h" "--this" "--that" "--no-this"])
        @["help"
          "--set-this"
          "true"
          "--set-that"
          "jousts"
          "you fart bag"
          "--set-this"
          "false"])
  (test (resolve-expansions {} ["-h" "--this" "--that" "--no-this"])
        @["-h" "--this" "--that" "--no-this"]))

(deftest load-options
  (test
    (let [config-fixture
          {
           "/home/skinner/.config/dystopia/config.nrdl"
           "{ a 1 b 2 c 3}"
           "/home/skinner/Code/dystopia.nrdl"
           "{ d 4 c 4}"
           "/etc/dystopia/config.nrdl"
           "{ x a y a z b}"
           }]
      (load-options "dystopia"
                    {"-h" ["help" "me"]
                     "-b" ["--set-bytes" "15"]
                     "-r" ["--set-zygotes" "\"buddy\""]}
                    ["-h" "-b" "but" "why"]
                    {"HOME" "/home/skinner"
                     "DYSTOPIA_LINES" "[ \"a\" \"b\" \"c\" ]"}
                    "/home/skinner/Code"
                    :linux
                    config-fixture
                    config-fixture))
    [@{:a 1
       :b 2
       :bytes 15
       :c 4
       :d 4
       :lines @["a" "b" "c"]
       :x :a
       :y :a
       :z :b}
     @["help" "me" "but" "why"]]))

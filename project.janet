# project.janet
#
# sniff — gather options from configuration files, environment
# variables, and the command line.

(declare-project
  :name "sniff"
  :description `
  Gather options from configuration files, environment variables,
  and the command line.
  `
  :version "0.1.0"
  :author "Daniel Jay Haskin"
  :license "MIT"
  :doc `
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
  `
  :dependencies [{:url "git@github.com:djha-skin/nrdl.git"
                  :tag "janet-0.1.1"}
                 {:url "https://github.com/ianthehenry/judge.git"
                  :tag "v2.11.0"}
                 {:url "https://github.com/pyrmont/documentarian"}])

(declare-source
  :prefix "sniff"
  :source ["src/init.janet"])

# Regenerate docs/api.md from the docstrings in the source with
# Documentarian (installed into the local tree via :dependencies).
# jpm's task PATH only includes jpm_tree/bin, but the bundle
# install puts documentarian under jpm_tree/lib/bin, so locate it
# explicitly.
(task "doc" []
      (def doc-bin
        (or (find |(= :file (os/stat $ :mode))
                  ["jpm_tree/bin/documentarian"
                   "jpm_tree/lib/bin/documentarian"])
            (error (string "documentarian is not installed; run:"
                           " jpm -l deps"))))
      (def env (merge (os/environ)
                      @{"JANET_PATH" (string (os/cwd) "/jpm_tree/lib")}))
      (def code (os/execute [(string (os/cwd) "/" doc-bin)
                             "-l" "-o" "docs/api.md"] :e env))
      (when (not= 0 code)
        (error (string "documentarian failed with exit code " code))))

# Point the default `test` rule (registered by declare-project) at
# the test/ directory. The `task` macro would only append another
# thunk to the existing rule's recipe, so clear it and add our own
# instead.
(def test-rule (get (dyn :rules) "test"))
(array/clear (get test-rule :recipe))
(array/push (get test-rule :recipe) (fn [] (run-tests "test")))

# project.janet
#
# NRDL (Nestable Readable Document Language) Janet package.

(declare-project
  :name "sniff"
  :description "SNIFF"
  :version "0.1.0"
  :author "Daniel Jay Haskin"
  :license "MIT"
  :dependencies [{:url "git@github.com:djha-skin/nrdl.git"
                  :tag "janet-0.1.1"}
                 {:url "https://github.com/ianthehenry/judge.git"
                  :tag "v2.11.0"}])

(declare-source
  :prefix "sniff"
  :source ["src/init.janet"])

(declare-executable
  :name "sniff"
  :entry ["src/init.janet"])

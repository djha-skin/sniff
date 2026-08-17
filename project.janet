# project.janet
#
# NRDL (Nestable Readable Document Language) Janet package.

(declare-project
  :name "sniff"
  :description "SNIFF"
  :version "0.1.0"
  :author "Daniel Jay Haskin"
  :license "MIT"
  :dependencies ["git@github.com:djha-skin/nrdl.git"])

(declare-source
  :prefix "sniff"
  :source ["src/main.janet"])


(barf "goose" (os/environ))


(defn barf [program-name env]
      (let [b ~{
                :und "_"
                :verb (choice "CONTEXT" "LIST" "MAP" "FLAG" "VALUE")
                :name ,(string/ascii-upper program-name)
                :noun (replace (capture (any (range "az" "AZ"))) ,string/ascii-lower)
                :main (sequence :name :und :verb :und :noun)
                }
            results @{}]
        (loop [[var val] :pairs env]
          (printf "Var: `%s` Val: `%s`" var val)

          (put results
               (peg/match b var) val))
        results))
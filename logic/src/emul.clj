(ns emul)

; (slurp "bsforth.bin")


(defn read-file [filename]
  (with-open [rdr (java.io.BufferedReader. (java.io.FileReader. filename))]
    (apply str (line-seq rdr))))

(read-file "rand.bin")


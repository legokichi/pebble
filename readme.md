Pebble
======================
  Pebble is a dialect of the Lisp programming language translated to JavaScript.

Function
----------
    (def square (fn [x] (* x x)))

    (defn square [x] (* x x))

    (square 4)

    ((fn [x] (* x x)) 4)

if
----------
    (if true  :alway
        false :never
        (alert :andDefault))

let
----------
    (let [a 1
          b 1]
      (+ a b))

loop/recur
----------
    (loop [i 0]
      (if (> i 10) i
        (recur
          (do
            (console.log i)
            (+ i 1)))))


do
----------
#### Pebble
    (def i 0)
    
    (def j (do
      (console.log i)
      (+ i 1)))


namespace
----------
    (module math
      (def deg 10)
      (export pi 3.24)
      (export sum #(+ (:0 _) (:1 _))

     (.sum math 0 1)
     (. math sum 0 1)
     ((. math sum) 0 1)

class
----------
    (defclass Hoge
      (fn [x] 
        (do
          (private a a)
          ..)
      (public a )
      ..)

    (new Hoge 0)


try/catch/finally
----------
    (try
      ..
      (catch e ..)
      (finally ..))

macro
----------
    (defmacro unless [test t f]
      `(if ~test ~f ~t))

Demo
----------
* https://dl.dropboxusercontent.com/u/265158/GitHub/pebble/index.html

Dependence
----------
* coffee-script.js <[cofee-script](https://github.com/jashkenas/coffee-script/)>

License
----------
Creative Commons [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/)

Copyright &copy; 2013 Legokichi Duckscallion

Author
----------
Legokichi Duckscallion
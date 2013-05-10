Pebble
======================
  Pebble is a dialect of the Lisp programming language translated to JavaScript.


Demo
----------
* [REPL](https://dl.dropboxusercontent.com/u/265158/GitHub/pebble/index.html)


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
          [b c d] [0 1 2]
          {:e} {:e "uha"}]
      (+ a b))


loop/recur
----------
    (loop [i 0]
      (if (> i 10) i
        (recur
          (do
            (console.log i)
            (+ i 1)))))


for
----------
    (for [x lst] x)


do
----------
    (def i 0)
    
    (def j (do
      (console.log i)
      (+ i 1)))


namespace
----------
    (module math
      (def deg 10)
      (export pi 3.24)
      (export sum #(+ (:0 _) (:1 _))))

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


Operators
----------
. ..
== !=
> >= < <=
+ - * / %
& | ^ ~ << >> >>>
and or not ?
delete of typeof instanceof


Embedded CofeeScript/JavaScript
----------
    (.log console
      ((coffee "
        do ->
          title = document.title
          `function(script){
            return [title, 'Hello ' + script].join(': ');
          }`
       ") 
       "CoffeeScript/JavaScript"))


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

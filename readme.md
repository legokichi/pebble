Pebble
======================
* Pebble is a dialect of the Lisp programming language translated to JavaScript.
* Pebble likes Clojure and ClojureScript, but something different.


Demo
----------
* [REPL](https://dl.dropboxusercontent.com/u/265158/GitHub/pebble/index.html)


def/fn
----------
    ;(def name val)
    ;(fn param body)

    (def square (fn [x] (* x x)))

    (square 4)

    ((fn [x] (* x x)) 4)

    (.map [0 1 2] #(- _0 1))
    (.map [0 1 2] (fn [_0 _1 _2 _3 _4 _5] (- _0 1)))


let
----------
    ;(let bindings body)

    (let [a 1
          [b c d] [0 1 2]
          {:e} {:e "uha"}]
      (+ a b))

do
----------
    ;(do & bodys)

    (def i 
      (do
        (console.log i)
        (+ i 1)))


if
----------
    ;(if & clauses)

    (if true  "alway"
        false "never"
        false "and more"
        "default")


loop/recur
----------
    ;(loop name? bindings body)

    (loop [i 0]
      (if (> i 10) i
        (recur
          (do
            (console.log i)
            (+ i 1)))))

    ;nested loop
    (loop recur1 [m m]
      ...
      (loop recur2 [n n]
        ...
        (recur1 ...) ...) ...)


throw/try/catch/finally
----------
    (try
      (throw "hoge")
      ..
      (catch e ..)
      (finally ..))


Object/Array/PropertyAccess/Keyword
----------
    (def obj {:a 0 :b 1 :c 2 :fn #(_0)})
    (def a "a")

    (. obj a)
    (. obj "a")
    (. obj "fn" "hello")

    (.fn obj)
    (.fn obj "hello")

    (:a obj)

    (def ary [1 9 8 4])

    (. ary 0)
    (:1 ary)

    (. console log :helloPebble)
    (.log console :helloPebble)


Operators
----------
    set!
    .
    new
    == !=
    > >= < <=
    + - * / %
    & | ^ ~ << >> >>>
    and or not ?
    of typeof instanceof


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
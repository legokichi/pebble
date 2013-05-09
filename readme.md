Pebble
======================
  Pebble is a dialect of the Lisp programming language translated to CoffeeScript.

Function
----------
    (def square (fn [x] (* x x)))
    
    (defn square [x] (* x x))
    
    (square 4)
    
    ((fn [x] (* x x)) 4)
translates to the following CoffeeScript:
    square = ((x)->
      (x * x))

    square = (x)->
      (x * x)

    square(4)
    ((x)->
      (x * x))(4)

if
----------
    (if true  :alway
        false :never
        (alert :andDefault))
becomes:
    if true
      "alway"
    else if false
      "never"
    else
      alert("andDefault")

let
----------
    (let [a 1
          b 1]
      (+ a b))


loop/recur
----------
    (loop [i 0]
      (if (> i 10) i
        (recur (+ i 1) (+ j 1))))
translates to the following CoffeeScript:
  do ->
    i = 0
    __recur__ = (args)->
      i = args[0]
    while true
      return if (i > 10)
        i
      else
        __recur__([(i + 1), (j + 1)])
        continue
      break

do
----------
#### Pebble
    (def i 0)
    
    (def j (do
      (console.log i)
      (+ i 1)))
translates to:
    i = 0
    
    j = (do ->
      console.log(i)
      (i + 1))

namespace
----------
    (namespace name
      ..)

class
----------
    (defclass name
      ..)

try/catch/finally
----------
    (try
      ..
      (catch e ..)
      (finally ..))

Demo
----------
* https://dl.dropboxusercontent.com/u/265158/GitHub/pebble/index.html

License
----------
Creative Commons [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/)

Copyright &copy; 2013 Legokichi Duckscallion

Author
----------
Legokichi Duckscallion
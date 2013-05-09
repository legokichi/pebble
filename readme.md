Pebble
======================
  Pebble is a dialect of the Lisp programming language translated to JavaScript.

Function
----------
    (def square (fn [x] (* x x)))

    (defn square [x] (* x x))

    (square 4)

    ((fn [x] (* x x)) 4)

translates to the following JavaScript:

    var square;

    square = (function(x) {
      return x * x;
    });

    square = (function(x) {
      return x * x;
    });

    square = (x)->
      (x * x)

    square(4)

    (function(x) {
      return x * x;
    })(4);

if
----------
    (if true  :alway
        false :never
        (alert :andDefault))

becomes:

    if (true) {
      "alway";
    } else if (false) {
      "never";
    } else {
      alert("default");
    }

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

translates to the following JavaScript:

    (function() {
      var i, __recur__;
      i = 0;
      __recur__ = function(args) {
        return i = args[0];
      };
      while (true) {
        if (i > 10) {
          return i;
        } else {
          __recur__([
            (function() {
              console.log(i);
              return i + 1;
            })()
          ]);
          continue;
        }
        break;
      }
    })();

do
----------
#### Pebble
    (def i 0)
    
    (def j (do
      (console.log i)
      (+ i 1)))

translates to:

    var i, j;

    i = 0;

    j = (function() {
      console.log(i);
      return i + 1;
    })();

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
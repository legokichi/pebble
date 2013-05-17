# define


global = @


global.PebbleScript = do ->


  "use strict"


  ws = (i)-> [0..i].map(->"").join("  ")


  class Environment
    constructor: (@stack={})->
    has: (key)-> @stack[key]?
    get: (key)-> @stack[key]
    set: (key, val)->
      o = Object.create(@stack)
      o[key] = val
      new Environment(o)
    extend:(obj)->
      o = Object.create(@stack)
      o[key] = val for key, val of obj
      new Environment(o)


  type = (x)-> Object.prototype.toString.apply(x)


  js2ps = (x)->
    if            x instanceof Expression   then x
    else if type(x) is "[object Undefined]" then new Symbol("undefined")
    else if type(x) is "[object Null]"      then new Symbol("null")
    else if type(x) is "[object Boolean]"   then new Symbol("#{x}")
    else if type(x) is "[object Number]"    then new Numeral(x)
    else if type(x) is "[object String]"    then new Text(x)
    else if type(x) is "[object Function]"  then new Lambda(x)
    else if type(x) is "[object Array]"
      new Call x.map (y,i)->
        if y["__SPLICE__"]?
          Array.prototype.splice.apply x, [i,1].concat y["__SPLICE__"]
          console.dir x
        else js2ps(y)
    else
      for key, val of x
        x[key] = js2ps(val)
      new Hash(x)



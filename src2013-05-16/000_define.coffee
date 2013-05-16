# define


global = @


global.PebbleScript = do ->


  "use strict"


  ws = (i)-> [0..i].map(->"").join("  ")


  type = (x)-> Object.prototype.toString.apply(x)


  inherit = (s)->
    f = ->
    f.prototype = s
    new f


  js2ps = (x)->
    if      type(x) is "[object Undefined]" then return new Symbol("undefined")
    else if type(x) is "[object Null]"      then return new Symbol("null")
    else if type(x) is "[object Boolean]"   then return new Symbol("#{x}")
    else if type(x) is "[object Number]"    then return new Numeral(x)
    else if type(x) is "[object String]"    then return new Text(x)
    else if type(x) is "[object Function]"  then return new Lambda(x)
    else if type(x) is "[object Array]"     then return new Call(x)
    else                                         return new Hash(x)


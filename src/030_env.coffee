#


  class Environment
    clone = (s)->
      f = ->
      f.prototype = s
      new f
    constructor: (obj)->
      @stack = obj
    has: (key)->
      @stack[key]?
    get: (key)->
      if @stack[key]? then @stack[key]
      else
        console.dir @
        throw "ReferenceError: #{key} is not defined"
    set: (key, val)->
      o = clone(@stack)
      o[key] = val
      new Environment(o)
    extend:(obj)->
      o = clone(@stack)
      o[key] = val for key, val of obj
      new Environment(o)
    createClosure: (keys, vals)->
      o = clone(@stack)
      o[key] = vals[i] for key, i in keys
      new Environment(o)



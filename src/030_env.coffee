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


#

  macroEnv =
    defmacro: new Special
      apply: (args, env)->
        _env = env
        if args.length isnt 3
          throw """
          MacroExpandError: \"defmacro\" needs 3 arguments
          (defmacro name [params*] body)
          """
        [name, params, body] = args
        _env = _env.set(name, new Macro(params, body)) # !! side effect !!
        [new Void(), _env]
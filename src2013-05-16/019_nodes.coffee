# nodes


  class Nodes
    constructor: (@expressions)->
    run: ->
      mee = new Environment(macroEvalEnv)
      @expressions.map (exp)->
        [exp, mee] = exp.eval(mee) # !! side effect !!
        exp



  class UnMacroExpandedNodes extends Nodes
    expandMacros: ->
      mse = new Environment(macroSeachEnv)
      exps = @expressions.map (exp)->
        #[exp, mse] = exp.macroexpand(mse) # !! side effect !!
        exp
      new MacroExpandedNodes(exps)


  class MacroExpandedNodes extends Nodes
    compileToCoffeeScript: ->
      cnv = new Environment(compileSpecialEnv).extend(compileBuiltinEnv)
      @expressions.map((exp)->
        [cscode, cnv] = exp.toCoffeeScript(cnv, 0) # !! side effect !!
        cscode
      ).join("\n\n")


# environment class


  class Environment
    constructor: (@stack={}, @failback=->)->
    has: (key)->
      if @stack[key]? then return true
      try val = @failback(key)
      if val? then return true
      else         return false
    get: (key)->
      if @stack[key]? then return @stack[key]
      try val = @failback(key)
      if val? then return val
      throw "ReferenceError: #{key} is not defined"
    set: (key, val)->
      o = inherit(@stack)
      o[key] = val
      new Environment(o)
    extend:(obj)->
      o = inherit(@stack)
      o[key] = val for key, val of obj
      new Environment(o)
    createClosure: (keys, vals)->
      o = inherit(@stack)
      o[key] = vals[i] for key, i in keys
      new Environment(o)



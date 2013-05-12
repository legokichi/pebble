#


  class Hash extends Expression
    constructor: (@value={})->
    set: (key, val)->
      obj = @toObject()
      obj[key] = val
      new @constructor(obj)
    get: (key)->
      @value[key]
    toObject: ->
      obj = {}
      obj[key] = val for key, val of @value
      obj
    toCoffeeScript: (env, i)->
      _env = env
      _bodies = (for key, val of @value
        [code, _env] = val.toCoffeeScript(_env, i+1) # !! side effect !!
        "#{ws(i+1)}#{key}: #{code}"
      ).join("\n")
      ["""
      {
      #{_bodies}
      #{ws(i)}}
      """, env]


  class Vector extends Hash
    constructor: (@value=[])->
    append: (exp)->
      new @constructor(@value.concat(exp))
    toArray: -> @value.slice(0)
    toCoffeeScript: (env, i)->
      _env = env
      _bodies = @value.map((exp)->
        [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
        "#{ws(i+1)}#{code}"
      ).join("\n")
      ["""
      [
      #{_bodies}
      #{ws(i)}]
      """, env]


  class Call extends Vector
    toCoffeeScript: (env, i)->
      _env = env
      ary = @toArray()
      [operator, operands...] = ary
      if !operator?
        throw "CompileError: call form needs operator"
      else if operator.isProperty()
        if operands.length < 1
          throw """
          CompileError: member access needs 1 or more arguments
          (.member obj)
          (.member obj & args)
          """
        [_prop, _env] = operator.toCoffeeScript(_env, i) # !! side effect !!
        [_obj, _env] = operands[0].toCoffeeScript(_env, i) # !! side effect !!
        args = operands.slice(1).map (exp)->
          [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
          code
        _args = args.join(", ")
        ["#{_obj}.#{_prop}(#{_args})", env]
      else if operator.isKeyword()
        if operands.length isnt 1
          throw """
          CompileError: property access needs only 2 arguments
          (:keyword obj)
          """
        [_obj, _env] = operands[0].toCoffeeScript(_env, i) # !! side effect !!
        [_key, _env] = operator.toCoffeeScript(_env, i+1) # !! side effect !!
        if isFinite(num = Number(operator.toString()))
          _key = num # !! side effect !!
        ["#{_obj}[#{_key}]", env]
      else if env.has(operator)
        builtin = env.get(operator)
        builtin.toCoffeeScript(env, i, operands)
      else
        [_fn, _env] = operator.toCoffeeScript(_env, i) # !! side effect !!
        args = operands.map (exp)->
          [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
          code
        _args = args.join(", ")
        ["#{_fn}(#{_args})", env]
    ###
    eval: (env)->
      [head, tail...]  = @toArray()
      [operator, _env] = head.eval(env)
      if operator.isSpecial() or
         operator.isMacro() or
         operator.isLambda()
        operator.apply(tail, _env)
      else if operator.isProperty()
        [something, args] = tail
        [hsh, __env] = something.eval(_env)
        callable = hsh.get(operator)
        callable.apply(tail, __env)
      else if operator.isKeyword()
        something = tail[0]
        [hsh, __env] = something.eval(_env)
        [hsh.get(operator), __env]
      else
        console.error "EvaluationError: #{operator} is not callable."
        console.dir @
        debugger
    macroexpand: (env)->
      [operator, operands...] = @toArray()
      if operator.isSymbol() and
         env.has(operator)
        env.get(operator)
           .apply(tail, env)
      else
        [exp, env]
    ###



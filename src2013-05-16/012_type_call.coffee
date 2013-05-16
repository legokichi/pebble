# call form collection types


  class Call extends Vector
    toCoffeeScript: (env, i)->
      _env = env
      [operator, operands...] = ary = @toArray()
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
    eval: (mee)->
      _mee = mee
      [head, tail...] = ary = @toArray()
      if head.isSymbol() and _mee.has(head) and
         (operator = _mee.get(head); true) and
         operator.isSpecial()
        operator.apply(tail, _mee)
      else
        [operator, operands...] = ary.map (exp)->
          try [_exp, _mee] = exp.eval(_mee) # !! side effect !!
          _exp or exp
        params = operands.map (exp, i)-> new Symbol("arguments[#{i}]")
        call = new Call([operator].concat(params))
        cnv = new Environment(compileSpecialEnv).extend(compileBuiltinEnv)
        [cscore, _cnv] = call.toCoffeeScript(cnv, 1)
        cscode = "(->\n#{ws(1)}#{cscore}\n).apply(this, arguments)"
        jscore = CoffeeScript.compile(cscode, {bare:true})
        jscode = jscore.replace("(function() {", "return (function() {")
        jsargs = operands.map (exp)-> exp.toJavaScript()
        fn = Function(jscode)
        console.log fn.toString()
        result = fn.apply(null, jsargs)
        console.log result
        [js2ps(result), mee]
    macroexpand: (mse)->
      _mse = mse
      [operator, operands...] = ary = @toArray()
      if operator.isSymbol() and _mse.has(operator) and
         (val = _mse.get(operator); true) and
         (val.isSpecial() or val.isMacro())
        val.apply(operands, _mse)
      else
        exps = []
        for exp in ary # !! side effect !!
          if exp.isCall()
            [exp, _mse] = exp.macroexpand(_mse) # !! side effect !!
          if exp.isSplicing() and exp.value.isVector()
            exps = exps.concat(exp.value.toArray()) # !! side effect !!
          else
            exps.push(exp) # !! side effect !!
        [new Call(exps), mse]
    ###


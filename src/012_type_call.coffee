#


  class Call extends List
    toCoffeeScript: (env, i)->
      [operator, operands...] = @value
      if !operator? then "[]"
      else if operator.isProperty()
        if operands.length < 1
          throw """
          CompileError: member access needs 1 or more arguments
          (.member obj)
          (.member obj & args)
          """
        _method = operator.toCoffeeScript(env, i)
        [obj, args...] = operands
        _obj = obj.toCoffeeScript(env, i)
        _args = args.map (exp)->
            exp.toCoffeeScript(env, i+1)
        "#{_obj}.#{_method}(#{_args.join(", ")})"
      else if operator.isKeyword()
        if operands.length isnt 1
          throw """
          CompileError: property access needs only 2 arguments
          (:keyword obj)
          """
        _obj = operands[0].toCoffeeScript(env, i)
        _key = operator.toCoffeeScript(env, i+1)
        _key = num if isFinite(num = Number(operator.toString())) # !! side effect !!
        "#{_obj}[#{_key}]"
      else if env.has(operator)
        env.get(operator).toCoffeeScript(env, i, operands)
      else
        _fn = operator.toCoffeeScript(env, i)
        _args = operands.map((exp)->
          exp.toCoffeeScript(env, i+1)
        ).join(", ")
        "#{_fn}(#{_args})"



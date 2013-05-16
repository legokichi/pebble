#


  compileBuiltinEnv = do ->
    nthOp = (op)-> (env, i, args)->
      _env = env
      if args.length < 2
        throw """
        CompileError: \"#{op}\" needs 2 or more arguments
        (#{op} x y)
        (#{op} x y & more)
        """
      _body = args.map((exp)->
        [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
        code
      ).join(" #{op} ")
      ["(#{_body})", env]
    ".": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length < 2
          throw """
          CompileError: \".\" needs 2 or more arguments
          (. object key)
          (. object key & args)
          """
        [obj, tail...] = args
        [_obj, _env] = obj.toCoffeeScript(_env, i)
        [_prop, _argus...] = tail.map (exp)->
          [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
          code
        _code = "#{_obj}.#{_prop}"
        if _argus.length isnt 0
          _code += "("+_argus.join(", ")+")" # !! side effect !!
        [_code, env]
    ":": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 2
          throw """
          CompileError: \":\" needs 2 arguments
          (: object key)
          """
        [obj, key] = args
        [_obj, _env] = obj.toCoffeeScript(_env, i) # !! side effect !!
        [_key, _env] = key.toCoffeeScript(_env, i) # !! side effect !!
        ["#{_obj}[#{_key}]", env]
    new: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length < 2
          throw """
          CompileError: \"new\" needs 1 or more arguments
          (new class)
          (new class & args)
          """
        [klass, argus...] = args
        [_class, _env] = klass.toCoffeeScript(_env, i) # !! side effect !!
        _argus = argus.map((exp)->
          [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
          code
        ).join(", ")
        ["new #{_class}(#{_argus})", env]
    "set!": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 2
          throw """
          CompileError: \"set!\" needs 2 arguments
          (set! name val)
          """
        [_name, _val] = args.map (exp)->
          [code, _env] = exp.toCoffeeScript(_env, i) # !! side effect !!
          code
        ["#{_name} = #{_val}", env]
    "==": new Special
      toCoffeeScript: nthOp("==")
    "!=": new Special
      toCoffeeScript: nthOp("!=")
    ">": new Special
      toCoffeeScript: nthOp(">")
    ">=": new Special
      toCoffeeScript: nthOp(">=")
    "<": new Special
      toCoffeeScript: nthOp("<")
    "<=": new Special
      toCoffeeScript: nthOp("<=")
    "+": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length < 2
          args.unshift(new Numeral(0)) # !! side effect !!
        nthOp("+")(env, i, args)
    "-": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length < 2
          args.unshift(new Numeral(0)) # !! side effect !!
        nthOp("-")(env, i, args)
    "*": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length < 2
          args.unshift(new Numeral(1)) # !! side effect !!
        nthOp("*")(env, i, args)
    "/": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length < 2
          args.unshift(new Numeral(1)) # !! side effect !!
        nthOp("/")(env, i, args)
    "%": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 2
          throw """
          CompileError: \"%\" needs 2 arguments
          (% num div)
          """
        nthOp("%")(env, i, args)
    "&": new Special
      toCoffeeScript: nthOp("&")
    "|": new Special
      toCoffeeScript: nthOp("|")
    "^": new Special
      toCoffeeScript: nthOp("^")
    "~": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 1
          throw """
          CompileError: \"~\" needs 1 argument
          (~ x)
          """
        [_x, _env] = args[0].toCoffeeScript(_env, i+1) # !! side effect !!
        ["(~#{_x})", env]
    "<<": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 2
          throw """
          CompileError: \"<<\" needs 2 arguments
          (<< x n)
          """
        nthOp("<<")(env, i, args)
    ">>": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 2
          throw """
          CompileError: \">>\" needs 2 arguments
          (>> x n)
          """
        nthOp(">>")(env, i, args)
    ">>>": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 2
          throw """
          CompileError: \">>>\" needs 2 arguments
          (>>> x n)
          """
        nthOp(">>>")(env, i, args)
    and: new Special
      toCoffeeScript: nthOp("and")
    or : new Special
      toCoffeeScript: nthOp("or")
    not: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 1
          throw """
          CompileError: \"not\" needs 1 argument
          (not x)
          """
        [_x, _env] = args[0].toCoffeeScript(_env, i+1) # !! side effect !!
        ["not(#{_x})", env]
    "?": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 1
          throw """
          CompileError: \"?\" needs 1 argument
          (? x)
          """
        [_x, _env] = args[0].toCoffeeScript(_env, i+1) # !! side effect !!
        ["(#{_x})?", env]
    "typeof": new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 1
          throw """
          CompileError: \"typeof\" needs 1 argument
          (typeof x)
          """
        [_x, _env] = args[0].toCoffeeScript(_env, i+1) # !! side effect !!
        ["typeof(#{_x})", env]
    of: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 2
          throw """
          CompileError: \"of\" needs 2 arguments
          (of obj key)
          """
        [_obj, _env] = args[0].toCoffeeScript(_env, i+1) # !! side effect !!
        [_key, _env] = args[1].toCoffeeScript(_env, i+1)  # !! side effect !!
        ["(#{_key} of #{_obj})", env]
    instanceof: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 2
          throw """
          CompileError: \"instanceof\" needs 2 arguments
          (instanceof class x)
          """
        [_class, _env] = args[0].toCoffeeScript(_env, i+1) # !! side effect !!
        [_x, _env] = args[1].toCoffeeScript(_env, i+1)  # !! side effect !!
        ["(#{_x} instanceof #{_class})", env]



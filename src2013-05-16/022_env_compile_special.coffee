#


  compileSpecialEnv =
    quote: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 1
          throw """
          CompileError: \"quote\" needs 1 argument
          (quote expression)
          'expression
          """
        console.log args[0]
        if args[0].isCall()
          [code, _env] = Vector.prototype.toCoffeeScript.call(args[0], _env, i) # !! side effect !!
        else if args[0].isSymbol()
          [code, _env] = Text.prototype.toCoffeeScript.call(args[0], _env, i) # !! side effect !!
        else
          [code, _env] = args[0].toCoffeeScript(_env, i) # !! side effect !!
        [code, env]
    def: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 2
          throw """
          CompileError: \"def\" needs 2 arguments
          (def name val)
          """
        [_name, _val] = args.map (exp)->
          [code, _env] = exp.toCoffeeScript(_env, i) # !! side effect !!
          code
        ["#{_name} = #{_val}", env]
    fn: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length is 2
          [params, body] = args
        else
          throw """
          CompileError: \"fn\" needs 1 or more arguments
          (fn [params*] body)
          """
        if !params? and Array.isArray(params)
          throw "SyntaxErorr: function needs parameters"
        if !body?   then throw "SyntaxErorr: function needs body"
        _params = params.toArray().map((exp)->
          [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
          code
        ).join(", ")
        [_body, _env] = body.toCoffeeScript(_env, i+1) # !! side effect !!
        ["""
        ((#{_params})->
        #{ws(i+1)}#{_body}
        #{ws(i)})
        """, env]
    do: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length < 1
          throw """
          CompileError: \"do\" needs 1 or more arguments
          (do & body)
          """
        _bodies = args.map((exp)->
          [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
          "#{ws(i+1)}#{code}"
        ).join("\n")
        ["""
        (
        #{_bodies}
        #{ws(i)})
        """, env]
    let: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length is 2
          [params, body] = args
        else
          throw """
          CompileError: \"let\" needs 2 arguments
          (let [bindings*] body)
          """
        ary = params.toArray().map (exp)->
          [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
          code
        _defs = (for x, j in ary by 2
          "#{ws(i+1)}#{x} = #{ary[j+1]}"
        ).join("\n")
        [_body, _env] = body.toCoffeeScript(_env, i+1) # !! side effect !!
        ["""
        (do ->
        #{_defs}
        #{ws(i+1)}#{_body}
        #{ws(i)})
        """, env]
    if: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length < 2
          throw """
          CompileError: \"if\" needs 2 or more arguments
          (if & clauses)
          """
        [_test, _body, tail...] = args.map (exp)->
          [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
          code
        _code = """
        if #{_test}
        #{ws(i+1)}#{_body}\n
        """
        while true
          [_test, _body, tail...] = tail # !! side effect !!
          if _test? and _body?
            _code += """
            #{ws(i)}else if #{_test}
            #{ws(i+1)}#{_body}\n
            """ # !! side effect !!
          else if _test? and !_body?
            _code += """
            #{ws(i)}else
            #{ws(i+1)}#{_test}
            """ # !! side effect !!
          else break
        [_code, env]
    loop: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length is 2
          [params, body] = args
          name = "recur"
        else if args.length is 3
          [name, params, body] = args
        else
          throw """
          CompileError: \"loop\" needs 3 or 4 arguments
          (loop name? [bindings*] body)
          """
        ary = params.toArray().map (exp)->
          [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
          code
        _defs = (for x, j in ary by 2
          "#{ws(i+1)}#{x} = #{ary[j+1]}"
        ).join("\n")
        _env = _env.set name, new Special # !! side effect !!
          toCoffeeScript: (env, i, args)->
            _env = env
            _args = args.map (exp)->
              [code, _env] = exp.toCoffeeScript(_env, i) # !! side effect !!
              code
            _redefs = (for x, j in ary by 2
              "#{x} = #{_args[j]}"
            ).join("\n#{ws(i)}")
            ["""
            #{_redefs}
            #{ws(i)}`continue #{name}`
            #{ws(i)}undefined""", env]
        [_body, _env] = body.toCoffeeScript(_env, i+2) # !! side effect !!
        ["""
        (do ->
        #{_defs}
        #{ws(i+1)}false && "label statement hack"
        #{ws(i+1)}`#{name}: //`
        #{ws(i+1)}while true
        #{ws(i+2)}return #{_body}
        #{ws(i+2)}break
        #{ws(i  )})
        """, env]
    throw: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 1
          throw """
          CompileError: \"throw\" needs only 1 argument
          (throw exception)
          """
        [_exc, env] = args[0].toCoffeeScript(_env, i) # !! side effect !!
        ["throw #{_exc}", env]
    try: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length < 1
          throw """
          CompileError: \"try\" needs 1 or more arguments
          (try & body (catch e & body)? (finally & body)?)
          """
        _bodies = args.map((exp)->
          if exp.isCall() and
             (symb = exp.get(0))? and
             symb.isSymbol() and
             (symb.value is "catch" or
              symb.value is "finally")
            if symb.value is "catch"
              [err, catches...] = exp.toArray().slice(1)
              [_err, _env] = err.toCoffeeScript(_env, i)
              _catches = catches.slice(1).map((exp)->
                [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
                "#{ws(i+1)}#{code}"
              ).join("\n")
              """
              #{ws(i)}catch #{_err}
              #{_catches}\n
              """
            else
              _finallies = exp.toArray().slice(1).map((exp)->
                [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
                "#{ws(i+1)}#{code}"
              ).join("\n")
              """
              #{ws(i)}finally
              #{_finallies}\n
              """
          else
            [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
            "#{ws(i+1)}#{code}"
        ).join("\n")
        ["""
        try
        #{_bodies}
        #{ws(i)}
        """, env]
    coffee: new Special
      toCoffeeScript: (env, i, args)->
        _env = env
        if args.length isnt 1
          throw """
          CompileError: \"coffee\" needs only 1 argument
          (coffee code)
          """
        _bodies = args[0]
          .toString()
          .split("\n")
          .map((line)-> "#{ws(i+1)}#{line}")
         　.join("\n")
        ["""
        (do ->
        #{_bodies}
        #{ws(i)})
        """, env]



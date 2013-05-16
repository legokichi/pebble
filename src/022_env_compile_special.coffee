#


  compileEnv = do ->


    multiOp = (op)-> (env, i, args)->
      if args.length < 2
        throw """
        CompileError: \"#{op}\" needs 2 or more arguments
        (#{op} x y)
        (#{op} x y & more)
        """
      _bodies = args.map (exp)-> exp.toCoffeeScript(env, i+1)
      "(#{_bodies.join(" #{op} ")})"


    twinOp = (op)-> (env, i, args)->
        if args.length isnt 2
          throw """
          CompileError: \"#{op}\" needs 2 arguments
          (#{op} x n)
          """
        multiOp(op)(env, i, args)


    singleOp = (op)-> (env, i, args)->
      if args.length isnt 1
        throw """
        CompileError: \"#{op}\" needs 1 argument
        (#{op} x)
        """
      "#{op}(#{args[0].toCoffeeScript(env, i+1)})"


    quote: new Special
      toCoffeeScript: (env, i, args)->
        if args.length isnt 1
          throw """
          CompileError: \"quote\" needs 1 argument
          (quote expression)
          'expression
          """
        args[0].quote().toCoffeeScript(env, i)
    def: new Special
      toCoffeeScript: (env, i, args)->
        if args.length isnt 2
          throw """
          CompileError: \"def\" needs 2 arguments
          (def name val)
          """
        _name = args[0].toCoffeeScript(env, i)
        _val  = args[1].toCoffeeScript(env, i)
        "#{_name} = #{_val}"
    fn: new Special
      toCoffeeScript: (env, i, args)->
        if args.length isnt 2 or !args[0].isList()
          throw """
          CompileError: \"fn\" needs 1 or more arguments
          (fn [params*] body)
          """
        _params = args[0].value.map (exp)->
          exp.toCoffeeScript(env, i+1)
        _body = args[1].toCoffeeScript(env, i+1)
        """
        ((#{_params.join(", ")})->
        #{ws(i+1)}#{_body}
        #{ws(i)})
        """
    do: new Special
      toCoffeeScript: (env, i, args)->
        if args.length < 1
          throw """
          CompileError: \"do\" needs 1 or more arguments
          (do & body)
          """
        _bodies = args.map (exp)->
          "#{ws(i+1)}#{exp.toCoffeeScript(env, i+1)}"
        """
        (
        #{_bodies.join("\n")}
        #{ws(i)})
        """
    if: new Special
      toCoffeeScript: (env, i, args)->
        if args.length < 2
          throw """
          CompileError: \"if\" needs 2 or more arguments
          (if & clauses)
          """
        [_test, _body, tail...] = args.map (exp)->
          exp.toCoffeeScript(env, i+1)
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
        _code
    loop: new Special
      toCoffeeScript: (env, i, args)->
        if args.length is 2
          [params, body] = args
          name = new Symbol("recur")
        else if args.length is 3
          [name, params, body] = args
        if args.length < 2 or 3 < args.length or
           !name.isSymbol() or !params.isList()
          throw """
          CompileError: \"loop\" needs 3 or 4 arguments
          (loop name? [bindings*] body)
          """
        ary = params.value.map (exp)-> exp.toCoffeeScript(env, i+1)
        _defs = ("#{ws(i+1)}#{x} = #{ary[j+1]}" for x, j in ary by 2)
        _env = env.set name, new Special
          toCoffeeScript: (env, i, args)->
            _args = args.map (exp)-> exp.toCoffeeScript(env, i)
            _redefs = ("#{x} = #{_args[j]}" for x, j in ary by 2)
            """
            #{_redefs.join("\n#{ws(i)}")}
            #{ws(i)}`continue #{name}`
            #{ws(i)}"__LABEL__HACK__"
            """
        _body = body.toCoffeeScript(_env, i+2)
        """
        (do ->
        #{_defs.join("\n")}
        #{ws(i+1)}"__LABEL__HACK__"
        #{ws(i+1)}`#{name}: //`
        #{ws(i+1)}while true
        #{ws(i+2)}return #{_body}
        #{ws(i+2)}break
        #{ws(i  )})
        """
    throw: new Special
      toCoffeeScript: (env, i, args)->
        if args.length isnt 1
          throw """
          CompileError: \"throw\" needs only 1 argument
          (throw exception)
          """
        "throw #{args[0].toCoffeeScript(env, i)}"
    try: new Special
      toCoffeeScript: (env, i, args)->
        if args.length < 1
          throw """
          CompileError: \"try\" needs 1 or more arguments
          (try & body (catch e & body)? (finally & body)?)
          """
        _bodies = args.map (exp)->
          if exp.isCall() and
             (symb = exp.get(0))? and symb.isSymbol() and
             (symb.value is "catch" or symb.value is "finally")
            if symb.value is "catch"
              [err, catches...] = exp.value.slice(1)
              _err = err.toCoffeeScript(env, i)
              _catches = catches.map (exp)->
                "#{ws(i+1)}#{exp.toCoffeeScript(env, i+1)}"
              """
              #{ws(i)}catch #{_err}
              #{_catches.join("\n")}
              """
            else
              _finallies = exp.value.slice(1).map (exp)->
                "#{ws(i+1)}#{exp.toCoffeeScript(env, i+1)}"
              """
              #{ws(i)}finally
              #{_finallies.join("\n")}
              """
          else
            "#{ws(i+1)}#{exp.toCoffeeScript(env, i+1)}"
        """
        try
        #{_bodies.join("\n")}
        """
    coffee: new Special
      toCoffeeScript: (env, i, args)->
        if args.length isnt 1 or !args[0].isText()
          throw """
          CompileError: \"coffee\" needs only 1 argument
          (coffee "CoffeeScript")
          """
        _bodies = args[0]
          .toString().split("\n")
          .map((line)-> "#{ws(i+1)}#{line}")
        """
        (do ->
        #{_bodies.join("\n")}
        #{ws(i)})
        """


#


    ".": new Special
      toCoffeeScript: (env, i, args)->
        if args.length < 2
          throw """
          CompileError: \".\" needs 2 or more arguments
          (. object key)
          (. object key & args)
          """
        [head, tail...] = args
        _obj = head.toCoffeeScript(env, i)
        [_prop, _args...] = tail.map (exp)->
          exp.toCoffeeScript(env, i+1)
        if _args.length is 0
          "#{_obj}.#{_prop}"
        else
          "#{_obj}.#{_prop}(#{_args.join(", ")})"
    ":": new Special
      toCoffeeScript: (env, i, args)->
        if args.length isnt 2
          throw """
          CompileError: \":\" needs 2 arguments
          (: object key)
          """
        _obj = args[0].toCoffeeScript(env, i)
        _key = args[1].toCoffeeScript(env, i+1)
        "#{_obj}[#{_key}]"


#


    new: new Special
      toCoffeeScript: (env, i, args)->
        if args.length < 2
          throw """
          CompileError: \"new\" needs 1 or more arguments
          (new class)
          (new class & args)
          """
        [klass, argz...] = args
        _class = klass.toCoffeeScript(env, i)
        _args = argz.map (exp)-> exp.toCoffeeScript(env, i+1)
        "new #{_class}(#{_args.join(", ")})"
    delete: new Special
      toCoffeeScript: singleOp("delete")
    typeof: new Special
      toCoffeeScript: singleOp("typeof")
    of: new Special
      toCoffeeScript: twinOp("of")
    instanceof: new Special
      toCoffeeScript:  twinOp("instanceof")
    "?": new Special
      toCoffeeScript: (env, i, args)->
        if args.length isnt 1
          throw """
          CompileError: \"#{op}\" needs 1 argument
          (#{op} x)
          """
        "(#{args[0].toCoffeeScript(env, i+1)})?"


#


    and: new Special
      toCoffeeScript: multiOp("and")
    or : new Special
      toCoffeeScript: multiOp("or")
    not: new Special
      toCoffeeScript: singleOp("not")


#


    "==": new Special
      toCoffeeScript: multiOp("==")
    "!=": new Special
      toCoffeeScript: multiOp("!=")
    ">": new Special
      toCoffeeScript: multiOp(">")
    ">=": new Special
      toCoffeeScript: multiOp(">=")
    "<": new Special
      toCoffeeScript: multiOp("<")
    "<=": new Special
      toCoffeeScript: multiOp("<=")


#


    "+": new Special
      toCoffeeScript: (env, i, args)->
        if args.length < 2 then args.unshift(new Numeral(0)) # !! side effect !!
        multiOp("+")(env, i, args)
    "-": new Special
      toCoffeeScript: (env, i, args)->
        if args.length < 2 then args.unshift(new Numeral(0)) # !! side effect !!
        multiOp("-")(env, i, args)
    "*": new Special
      toCoffeeScript: (env, i, args)->
        if args.length < 2 then args.unshift(new Numeral(1)) # !! side effect !!
        multiOp("*")(env, i, args)
    "/": new Special
      toCoffeeScript: (env, i, args)->
        if args.length < 2 then args.unshift(new Numeral(1)) # !! side effect !!
        multiOp("/")(env, i, args)
    "%": new Special
      toCoffeeScript: (env, i, args)->
        if args.length isnt 2
          throw """
          CompileError: \"%\" needs 2 arguments
          (% num div)
          """
        multiOp("%")(env, i, args)


#


    "&": new Special
      toCoffeeScript: multiOp("&")
    "|": new Special
      toCoffeeScript: multiOp("|")
    "^": new Special
      toCoffeeScript: multiOp("^")
    "~": new Special
      toCoffeeScript: singleOp("~")
    "<<": new Special
      toCoffeeScript: twinOp("<<")
    ">>": new Special
      toCoffeeScript: twinOp(">>")
    ">>>": new Special
      toCoffeeScript: twinOp(">>>")



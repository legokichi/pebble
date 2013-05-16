#


  macroSeachEnv =
    defmacro: new Special
      apply: (args, env)->
        if args.length isnt 3
          throw """
          MacroExpandError: \"defmacro\" needs 3 arguments
          (defmacro name [params*] body)
          """
        [name, params, body] = args
        macroSeachEnv[name] = new Macro(params, body) # !! side effect !!
        [new Void(), env]


#


  macroEvalEnv =
    def: new Special
      apply: (args, env)->
        if args.length isnt 2
          throw """
          CompileError: \"def\" needs 2 arguments
          (def name val)
          """
        name = args[0]
        [val, _env]  = args[1].eval(env)
        [undefined, _env.set(name, val)]
    fn: new Special
      apply: (args, env)->
        if args.length isnt 2
          throw """
          MacroExpandError: \"fn\" needs 1 or more arguments
          (fn [params*] body)
          """
        [params, body] = args
        new Lambda(params, body)
    gensym: do ->
      i = 0
      new Special
        apply: (args, env)->
          [new Symbol(""+(i++)), env]
    quote: new Special
      apply: (args, env)->
        if args.length isnt 1
          throw """
          MacroExpandError: \"quote\" needs 1 argument
          (quote expression)
          'expression
          """
        [args[0], env]
    "syntax-quote": new Special
      apply: (args, env)->
        mee = env
        if args.length isnt 1
          throw """
          MacroExpandError: \"syntax-quote\" needs 1 argument
          (syntax-quote expression)
          `expression
          """
        sqe = new Environment
          "unquote-splicing": new Special
            apply: (args, env)->
              if args.length isnt 1
                throw """
                MacroExpandError: \"unquote-splicing\" needs 1 argument
                (unquote-splicing expression)
                ,@expression
                """
              [_exp, _mee] = args[0].eval(mee)
              [new Splicing(_exp), env]
          "unquote": new Special
            apply: (args, env)->
              if args.length isnt 1
                throw """
                MacroExpandError: \"unquote\" needs 1 argument
                (unquote expression)
                ,expression
                """
              [_exp, _mee] = args[0].eval(mee)
              [_exp, env]
        [exp, _sqe] = args[0].macroexpand(sqe)
        [exp, env]



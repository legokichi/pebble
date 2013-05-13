#


  emitter = do ->


    coffee = (code)->
      mnv = new Environment(macroEnv)
      nodes = reader.parse(code)
      exps = nodes.expressions.map (exp)->
        [exp, mnv] = exp.macroexpand(mnv) # !! side effect !!
        exp
      env = new Environment(specialEnv)
      env = env.extend(builtinEnv) # !! side effect !!
      codes = exps.map (exp)->
        [code, env] = exp.toCoffeeScript(env, 0) # !! side effect !!
        code
      codes.join("\n\n")


    compile = (code)->
      CoffeeScript.compile(coffee(code))


    evaluation = (code)->
      CoffeeScript.run(coffee(code))


    return {
      coffee:  coffee
      compile: compile
      eval:    evaluation
    }



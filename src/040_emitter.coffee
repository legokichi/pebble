#


  emitter = do ->


    coffee = (code)->
      env = new Environment(specialEnv)
      env = env.extend(builtinEnv) # !! side effect !!
      nodes = reader.parse(code)
      codes = nodes.expressions.map (exp)->
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



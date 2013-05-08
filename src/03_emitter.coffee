# 03 emitter


  emitter = do ->


    coffee = (code)->
      if typeof code isnt "string" then debugger
      nodes = reader.parse(code)
      ary = nodes.expressions.map (exp)->
        exp.toCoffeeScript()
      ary.join("\n\n")
         .split("\n\n")
         .join("\n")

    compile = (code)->
      CoffeeScript.compile(coffee(code))


    evaluation = (code)->
      CoffeeScript.run(coffee(code))


    return {
      coffee:  coffee
      compile: compile
      eval:    evaluation
    }



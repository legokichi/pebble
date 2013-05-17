#


  class Nodes
    constructor: (@expressions)->
    toCS: ->
      macroNameSpace = {} # !! side effect !!
      env = new Environment(compileEnv)
      @expressions.map((exp)->
        exp.toCoffeeScript(env, 0)
      ).join("\n\n")
    toJS: ->
      CoffeeScript.compile(@toCS(), {bare: true})


#


  return {
    nodes:(pscode)-> reader.parse(pscode)
    toCS: (pscode)-> @nodes(pscode).toCS()
    toJS: (pscode)-> @toCS(pscode).toJS()
    run:  (pscode)-> Function(@toJS(pscode))()
  }



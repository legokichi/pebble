#


  class Nodes
    constructor: (@expressions)->
    macro: -> @
    toCS: ->
      env = new Environment(compileEnv)
      @expressions.map((exp)->
        exp.toCoffeeScript(env, 0)
      ).join("\n\n")
    toJS: ->
      CoffeeScript.compile(@toCS(), {bare: true})


#


  return {
    nodes:(pscode)-> reader.parse(pscode)
    macro:(pscode)-> @nodes(pscode).macro()
    toCS: (pscode)-> @macro(pscode).toCS()
    toJS: (pscode)-> @toCS(pscode).toJS()
    run:  (pscode)-> Function(@toJS(pscode))()
  }



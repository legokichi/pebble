#

  ###
  class Macro extends Expression
    constructor: (params, @body)->
      @params = params.toArray()
    apply: (args, env)->
      


  class Lambda extends Hash
    constructor: (params, @body, @closure)->
      @params = params.toArray()
    apply: (args, env)->


  class BuiltIn extends Lambda
    constructor: (o)->
      @[key] = val for key, val of o
  ###

  class Special extends Expression
    constructor: (o)->
      @[key] = val for key, val of o



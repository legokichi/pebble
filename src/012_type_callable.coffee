#


  class Macro extends Expression
    constructor: (params, @body)->
      @params = params.toArray()
    apply: (args, env)->
      _env = env
      _env = _env.createClosure(@params, args)
      _env = _env.extend
        quote: new Special
          apply: (args, env)-> [args[0], env]
        "syntax-quote": new Special
          apply: (args, env)->
            _env = env
            SQEnv = new Environment
              "unquote-splicing": new Special
                apply: (args, env)->
                  #[exp, _env] = args[0].eval(env)
                  [args[0], env]
              "unquote": new Special
                apply: (args, env)->
                  console.log "UUUUUUUUUUUUUU"
                  console.dir args
                  [exp, _env] = args[0].eval(_env)
                  [exp, env]
            [exp, SQEnv] = args[0].macroexpand(SQEnv)
            [exp, env]
      [exp, _env] = @body.eval(_env)
      [exp, env]


  ###
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



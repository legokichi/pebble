# expression root type


  class Expression
    isSpecial:-> @ instanceof Special
    isMacro:->   @ instanceof Macro
    isLambda:->  @ instanceof Lambda
    isSymbol: -> @ instanceof Symbol
    isNumeral:-> @ instanceof Numeral
    isText:   -> @ instanceof Text
    isRegular:-> @ instanceof Regular
    isProperty:->@ instanceof Property
    isKeyword:-> @ instanceof Keyword
    isLogical:-> @ instanceof Logical
    isUndef:  -> @ instanceof Undef
    isVoid:   -> @ instanceof Void
    isSplicing:->@ instanceof Splicing
    isHash:   -> @ instanceof Hash
    isVector: -> @ instanceof Vector
    isCall:   -> @ instanceof Call
    constructor: (@value)->
    error = (that, msg)->
      debugger
      throw msg
    toString: ->
      if @value? then @value.toString()
      else error @, "TypeError: it cannot convert to String"
    macroexpand: (mse)-> [@, mse]
    apply: -> error @, "EvaluationError: it is not callable type"
    eval: (mee)-> [@, mee]
    toJavaScript: ->
      if @value? then @value
      else error @, "TranslateError: it cannot translate to JavaScript"
    toCoffeeScript: (env, i)->
      if @value? then [@toString(), env]
      else error @, "TranslateError: it cannot translate to CoffeeScript"


# primitive atom types


  class Numeral extends Expression


  class Text extends Expression
    toCoffeeScript: (env, i)->
      console.log @value
      str = @value.replace("\\","\\\\")
      console.log "\"#{str}\""
      ["\"#{str}\"", env]


  class Regular extends Expression


  class Hash extends Expression
    constructor: (@value={})->
    set: (key, val)-> @value[key] = val; @ # !! side effect !!
    get: (key)-> @value[key]
    toObject: -> @value
    toCoffeeScript: (env, i)->
      _env = env
      _bodies = (for key, val of @value
        [code, _env] = val.toCoffeeScript(_env, i+1) # !! side effect !!
        "#{ws(i+1)}#{key}: #{code}"
      ).join("\n")
      ["""
      {
      #{_bodies}
      #{ws(i)}}
      """, env]


  class Vector extends Hash
    constructor: (@value=[])->
    append: (exp)-> @value.push(exp); @ # !! side effect !!
    toArray: -> @value
    toCoffeeScript: (env, i)->
      _env = env
      _bodies = @value.map((exp)->
        [code, _env] = exp.toCoffeeScript(_env, i+1) # !! side effect !!
        "#{code}"
      ).join(", ")
      ["[#{_bodies}]", env]


# evaluater, macroexpander and compiler's special types


  class Symbol extends Expression
    eval: (env)-> [env.get(@), env]


  class Property extends Symbol


  class Keyword extends Text


  class Void extends Expression
    value: "undefind"
    toCoffeeScript: (env, i)-> ["", env]


  class Splicing extends Expression


#


  class Special extends Expression
    constructor: (o)->
      @[key] = val for key, val of o

  ###
  class Macro extends Expression
    findSymbol = (args, symbol)->
      cnv = new Environment(compileSpecialEnv).extend(compileBuiltinEnv)
      call = new Call([new Symbol("fn"), @params, symbol])
      [cscore, _cnv] = call.toCoffeeScript(cnv, 0)
      cscode = "(#{cscore}).apply(this, arguments)"
      jscore = CoffeeScript.compile(cscode, {bare:true})
      jscode = jscore.replace("(function() {", "return (function() {")
      fn = Function(jscode) 
      console.log fn.toString()
      result = fn.apply(null, args)
      console.log result
      if result instanceof Expression then result
      else                                 js2ps(result)
    constructor: (@params, @body)->
    apply: (args, mse)->
      mee = new Environment(macroEvalEnv, findSymbol.bind(this, args))
      [exp, _mee] = @body.eval(mee)
      [exp, mse]


  class Lambda extends Expression
    constructor: (params, body)->
      cnv = new Environment(compileSpecialEnv).extend(compileBuiltinEnv)
      call = new Call([new Symbol("fn"), params, body])
      [cscore, _cnv] = call.toCoffeeScript(cnv, 0)
      cscode = "#{cscore}.apply(this, arguments)"
      jscore = CoffeeScript.compile(cscode, {bare:true})
      jscode = jscore.replace("(function() {", "return (function() {")
      @value = Function(jscode)
    apply: (args, mse)->
      [js2ps(@value.apply(null, args)), mse]
  ###


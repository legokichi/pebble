#


  class Expression
    isVoid:   -> @ instanceof Void
    isSymbol: -> @ instanceof Symbol
    isProperty:->@ instanceof Property
    isNumeral:-> @ instanceof Numeral
    isText:   -> @ instanceof Text
    isKeyword:-> @ instanceof Keyword
    isRegular:-> @ instanceof Regular
    isHash:   -> @ instanceof Hash
    isVector: -> @ instanceof Vector
    isCall:   -> @ instanceof Call
    isSpecial:-> @ instanceof Special
    isMacro:->   @ instanceof Macro
    #isLambda:->  @ instanceof Lambda
    #isBuiltIn:-> @ instanceof BuiltIn
    constructor: (@value)->
    toString: ->
      if @value? then @value.toString()
      else
        console.dir @
        debugger
        throw "TypeError: #{@} cannot convert to String"
    toCoffeeScript: (env, i)->
      if @value?
        [@value.toString(), env]
      else
        console.dir @
        debugger
        throw "TranslateError: #{@} cannot translate to CoffeeScript"
    eval: (env)-> [@, env]
    macroexpand: ->
      console.dir @
      debugger
      throw "MacroExpandError: #{@} is not call form"
    apply: ->
      console.dir @
      debugger
      throw "ApplyError: #{@} cannot apply."


#


  class Void extends Expression
    toCoffeeScript: (env, i)-> ["", env]


  class Symbol extends Expression
    eval: (env)->
      [env.get(@), env]


  class Property extends Symbol


  class Numeral extends Expression


  class Text extends Expression
    toCoffeeScript: (env, i)->
      str = @value.replace("\\","\\\\")
      ["\"#{str}\"", env]


  class Keyword extends Text



  class Regular extends Expression



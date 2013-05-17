#


  class Expression
    isCall:   -> @ instanceof Call
    isList:   -> @ instanceof List
    isHash:   -> @ instanceof Hash
    isText:   -> @ instanceof Text
    isNumeral:-> @ instanceof Numeral
    isKeyword:-> @ instanceof Keyword
    isSymbol: -> @ instanceof Symbol
    isProperty:->@ instanceof Property
    isRegular:-> @ instanceof Regular
    isSpecial:-> @ instanceof Special
    isMacro:  -> @ instanceof Macro
    isSplicing:->@ instanceof Splicing
    constructor: (@value)->
    toString: -> @value.toString()
    quote: -> @
    syntaxQuote: -> @
    toJavaScript: ->
      if @value? then @value
      else
        console.dir @
        throw "TranslateError: #{@} cannot translate to JavaScript"
    toCoffeeScript: (env, i)->
      if @value? then @value.toString()
      else
        console.dir @
        throw "TranslateError: #{@} cannot translate to CoffeeScript"


  class Numeral extends Expression


  class Regular extends Expression


  class Text extends Expression
    toCoffeeScript: (env, i)->
      "\"" + @value.split("\\").join("\\\\") + "\""


  class Keyword extends Text


  class Symbol extends Expression
    quote: ->
      new Call([
        new Symbol("new")
        new Symbol("Symbol")
        new Text("#{@value}")
      ])
    syntaxQuote:-> @quote()
    toCoffeeScript: (env, i)->
      @value
        .split("+").join("_PLUS_")
        .split("-").join("_MINUS_")
        .split("*").join("_STAR_")
        .split("/").join("_SLASH_")
        .split("%").join("_PER_")
        .split("&").join("_AND_")
        .split("|").join("_PIPE_")
        .split("^").join("_HAT_")
        .split("~").join("_TILDE_")
        .split("<").join("_LT_")
        .split(">").join("_GT_")
        .split("=").join("_EQ_")
        .split("!").join("_EXCLAM_")
        .split("?").join("_QUEST_")
        .split(":").join("_COLON_")


  class Property extends Symbol


  class Hash extends Expression
    constructor: (@value={})->
    set: (key, val)->
      @value[key] = val # !! side effect !!
      @
    get: (key)-> @value[key]
    quote: ->
      for key, val of @value
        @value[key] = val.quote() # !! side effect !!
      @
    syntaxQuote: ->
      for key, val of @value
        @value[key] = val.syntaxQuote() # !! side effect !!
      @
    toCoffeeScript: (env, i)->
      _bodies = (for _key, val of @value
        _val = val.toCoffeeScript(env, i+1)
        "#{ws(i+1)}\"#{_key}\": #{_val}")
      """
      {
      #{_bodies.join("\n")}
      #{ws(i)}}
      """


  class List extends Hash
    constructor: (@value=[])->
    push: (exp)->
      @value.push(exp) # !! side effect !!
      @
    syntaxQuote: ->
      new List @value.map (val)->
        val.syntaxQuote() # !! side effect !!
    quote: ->
      new List @value.map (val)->
        val.quote()
    toCoffeeScript: (env, i)->
      _bodies = @value.map((exp)->
        exp.toCoffeeScript(env, i+1)
      ).join(", ")
      "[#{_bodies}]"


#


  class Special extends Expression
    constructor: (o)->
      @[key] = val for key, val of o  # !! side effect !!


  class Macro extends Expression
    constructor: (args)->
      @value = new Call([new Symbol("fn")].concat(args))
    toCoffeeScript: (env, i, args)->
      fn = @value.compile(env)
      console.log fn
      console.log args
      result = fn(Symbol, args)
      console.log result
      console.log js2ps(result)
      js2ps(result).toCoffeeScript(env, i)



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
    isVoid:   -> @ instanceof Void
    constructor: (@value)->
    quote: -> @
    toString: -> @value.toString()
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
    quote: -> new Hash
      type: new Text("symbol")
      value: new Text(@value)
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
    map: (fn)-> new List @value.map(fn)
    quote: -> @map (val)-> val.quote()
    toCoffeeScript: (env, i)->
      _bodies = @value.map((exp)->
        exp.toCoffeeScript(env, i+1)
      ).join(", ")
      "[#{_bodies}]"


#


  class Void extends Expression
    constructor: (@value="")->


  class Splicing extends Expression


  class Special extends Expression
    constructor: (o)->
      @[key] = val for key, val of o  # !! side effect !!



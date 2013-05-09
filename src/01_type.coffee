# 01_type


  class Expression extends Object
    isHash:   -> @ instanceof Hash
    isVector: -> @ instanceof Vector
    isCall:   -> @ instanceof Call
    isSymbol: -> @ instanceof Symbol
    isProperty:-> @ instanceof Property
    isNumeral:-> @ instanceof Numeral
    isText:   -> @ instanceof Text
    isKeyword:-> @ instanceof Keyword
    constructor: (any)->
      @value = any
    toString: ->
      @value.toString()
    toCoffeeScript: ->
      throw "cannot convert to javascript from " + @value


  class Hash extends Expression
    constructor: (val)->
      @value = val or {}
    set: (key, val)->
      obj = @toObject()
      obj[key] = val
      new @constructor(obj)
    get: (key)->
      @value[key]
    toObject: ->
      obj = {}
      obj[key] = val for key, val of @value
      obj
    toCoffeeScript: (i=0)->
      _hsh = ([key, val] for key, val of @value)
        .map(([key, val])-> "#{ws(i+1)}#{key}: #{val.toCoffeeScript(i+1)}")
      """
      {\n
      #{_hsh}
      #{ws(i)}}
      """


  class Vector extends Hash
    constructor: (val)->
      @value = val or []
    append: (elm)->
      new @constructor(@value.concat(elm))
    toArray: ->
      @value.slice(0)
    toCoffeeScript: (i=0)->
      ary = @value.map (exp)-> exp.toCoffeeScript(i)
      str = "[" + ary.join(", ") + "]"
      str.replace(", ...", "...")
         .replace(", ..", "..")


  class Call extends Vector
    constructor: (val)->
      @value = val or []
    toCoffeeScript: (i=0)->
      [head, tail...] = @value
      [operator, operands...] = @value.map (exp)->
        exp.toCoffeeScript(i)
      if head.isProperty()
        operands[0] + operator + "(" + operands.slice(1).join(", ") + ")"
      else if head.isKeyword()
        if isFinite(Number(head.value))
          operands[0] + "["+ Number(head.value) + "]"
        else
          operands[0] + "["+ operator + "]"
      else if special[operator]?
        special[operator](tail, i)
      else
        operator + "(" + operands.join(", ") + ")"


  class Symbol extends Expression
    toCoffeeScript: (i=0)->
      @value.toString()

  class Property extends Symbol
    constructor: (@value)->
    toCoffeeScript: (i=0)->
      @value.toString()

  class Numeral extends Expression
    toCoffeeScript: (i=0)->
      @value.toString()


  class Text extends Expression
    toCoffeeScript: (i=0)->
      str = @value.replace("\\","\\\\")
      "\"" + str + "\""

  class Keyword extends Text
    constructor: (@value)->
    toCoffeeScript: (i=0)->
      str = @value.replace("\\","\\\\")
      "\"" + str + "\""

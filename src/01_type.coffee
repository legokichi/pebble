# 01_type


  class Expression extends Object
    isHash:   -> @ instanceof Hash
    isVector: -> @ instanceof Vector
    isCall:   -> @ instanceof Call
    isSymbol: -> @ instanceof Symbol
    isNumeral:-> @ instanceof Numeral
    isText:   -> @ instanceof Text
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
      ary = []
      for key, val of @value
        ary.push(ws(i+1) + key + ": " + val.toCoffeeScript(i+1))
      "{\n" +
       ary.join("\n") +
      ws(i) + "}\n"


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
      operator = head.toCoffeeScript(i)
      if special[operator]?
        special[operator](tail, i)
      else
        operands = tail.map (exp)-> exp.toCoffeeScript(i)
        operator + "(" + operands.join(", ") + ")"


  class Symbol extends Expression
    toCoffeeScript: (i=0)->
      if /^&/.test(@value) then @value.slice(1) + "..."
      else                      @value


  class Numeral extends Expression
    toCoffeeScript: (i=0)->
      @value.toString()


  class Text extends Expression
    toCoffeeScript: (i=0)->
      str = @value.replace("\\","\\\\")
      "\"" + str + "\""



#01_Type


  class Expression
    isPrimitive:-> not(@isCons() or @isSymbol())
    isSpecial:-> @ instanceof Special
    isMacro:  -> @ instanceof Macro
    isLambda: -> @ instanceof Lambda
    isCons:   -> @ instanceof Cons
    isSymbol: -> @ instanceof Symbol
    isNil:    -> @ instanceof Nil
    isLogical:-> @ instanceof Logical
    isText:   -> @ instanceof Text
    isNumeral:-> @ instanceof Numeral
    isRawString:-> @ instanceof RawString
    evalAll = (exps, env)-> #[Expression]
      _exps = exps.map (exp)->
        [exp, env] = exp.eval(env)
        exp
      [_exps, env]
    eval: (env)-> #[Expression, Environment]
      if      @isPrimitive() then [@, env]
      else if @isSymbol()    then [env.find(@toString()), env]
      else if @isCons()
        [operator, env] = @car.eval(env)
        #console.log [operator, @cdr]
        operands = @cdr.toArray()
        #console.log operator,operands
        if      operator.isSpecial() then operator.apply(operands, env)
        else if operator.isMacro()
          [exp, env] = operator.expand(operands, env)
          exp.eval(env)
        else if operator.isLambda()
          [exps, env] = evalAll(operands, env)
          operator.apply(exps, env)
        else throw "EvaluationError: Unknown form call " + @
      else throw "EvaluationError: Unknown expression type " + @
    toString: ->
      "[object " + JSON.stringify(@) + "]"


  class Special extends Expression
    constructor: (name, fn)-> #Special
      @name = name #String
      @primitive = fn #Function
    apply: (args, env)-> #Expression
      @primitive(args, env)
    toString: -> "(special () [" + @name + " naitve code])"


  class Macro extends Expression
    constructor: (params, exp, env)-> #Macro
      @parameters = params #[Symbol]
      @expression = exp    #Expression
      @closure    = env    #Environment
    expand: (args, env)-> #Expression
      keys = @parameters.map (symb)-> symb.toString()
      @expression.eval(@closure.createClosure(keys, args), env)
    toString: ->
      params = @parameters.map((symb)-> symb.toString()).join(" ")
      exp    = @expression.toString()
      "(macro (" + params + ") " + exp + ")"


  class Lambda extends Expression
    isFunction = (it)->
      Object.prototype.toString.call(it) is "[object Function]"
    constructor: (params, exp, env)-> #Lambda
      if arguments.length is 1
        @primitive  = params #Function
      else
        @parameters = params #[Symbol]
        @expression = exp    #Expression
        @closure    = env    #Environment
    apply: (args, env)-> #Expression
      if @primitive? then @primitive(args, env)
      else
        keys = @parameters.map (symb)-> symb.toString()
        @expression.eval(@closure.createClosure(keys, args), env)
    toString: ->
      if @primitive? then "(lambda () [naitve code])"
      else
        params = @parameters.map((symb)-> symb.toString()).join(" ")
        exp    = @expression.toString()
        "(lambda (" + params + ") " + exp + ")"


  class Cons extends Expression
    toArray = (cons)->
      ary = [] #!! side effect !!
      recur = (cons)->
        ary.push(cons.car) #!! side effect !!
        if not cons.cdr.isCons() then ary
        else                          recur(cons.cdr)
      recur(cons)
    constructor: (car, cdr)-> #Cons
      @car = car #Expression
      @cdr = cdr #Expression
    toArray: -> toArray(@)
    toString: ->
      toStringHead = (car)->
        "(" + car.toString()
      toStringTail = (exp)->
        if      exp.isNil()
          ")"
        else if exp.isCons()
          " " + exp.car.toString() + toStringTail(exp.cdr)
        else
          " . " + exp.toString() + ")"
      toStringHead(@car) + toStringTail(@cdr)


  class Symbol extends Expression
    constructor: (str)-> #Symbol
      @value = str #String
    toString: -> #String
      @value+""


  class Nil extends Expression
    toString: -> "null"


  class Logical extends Expression
    constructor: (bool)-> #Logical
      @value = bool
    isTrue:  -> not not @value
    isFalse: -> not @value
    toString: ->
      if @isTrue() then "true" else "false"


  class Text extends Expression
    constructor: (str)-> #Text
      @value = str
    toString: -> #String
      "\"" + @value + "\""


  class Numeral extends Expression
    constructor: (num)-> #Numeral
      @value = num
    toNumber: -> #Number
      Number(@value)
    toString:-> @value


  class RawString extends Expression
    constructor: (str)->
      @value = str
    toString: -> #String
      @value



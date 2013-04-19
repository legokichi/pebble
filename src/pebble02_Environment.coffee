#03_Environment


  globalEnv =
    nil: new Nil()
    true: new Logical(true)
    false: new Logical(false)
    car: new Lambda ([exp], env)-> #Expression
      if exp.isCons() then [exp.car, env]
      else throw "Uncaught TypeError: " + exp.car + " is not Cons"
    cdr: new Lambda ([exp], env)-> #Expression
      if exp.isCons() then [exp.cdr, env]
      else throw "Uncaught TypeError: " + exp.cdr + " is not Cons"
    cons: new Lambda ([car, cdr], env)-> #Cons
      [new Cons(car, cdr), env]
    eq: new Lambda (exps, env)-> #Logical
      recur = ([a, b...])->
        if b[0]?          then true
        else if a is b[0] then recur(b)
        else                   false
      [recur(exps), env]
    atom: new Lambda ([exp], env)-> #Logical
      [not(exp.isCons()), env]
    inline: new Lambda (exps, env)->
      ary = exps.map (exp)->
        if      exp.isSymbol()    then exp.toString()
        else if exp.isText()      then exp.value
        else if exp.isRawString() then exp.toString()
        else throw "Uncaught TypeError: inline"
      [new RawString(ary.join("")), env]
    def: new Special "def", ([symb, exp], env)->
      key = symb.toString()
      [val, env] = exp.eval(env)
      [new Nil(), env.extend(key, val)]
    if: new Special "if", ([cond, trueCase, falseCase], env)->
      [logic, env] = cond.eval(env)
      if logic.isTrue() then trueCase.eval(env)
      else                   falseCase.eval(env)
    lambda: new Special "lambda", ([params, exp], env)->
      [new Lambda(params.toArray(), exp, env) ,env]
    macro: new Special "macro", ([params, exp], env)->
      [new Macro(params.toArray(), exp, env) ,env]
    progn: new Special "progn", (exps, env)->
      _exps = exps.map (exp)->
        [exp, env] = exp.eval(env)
      result = _exps[_exps.length-1]
      [result, env]
    quote: new Special "quote", ([exp], env)-> #'
      [exp, env]
    quasiquote: new Special "quasiquote", ([exp], env)-> #`
      unquoteHead = (exp, env)->
        if exp.isCons()       and
           exp.car.isSymbol() and
           exp.car.toString() is "unquote"
          [rslt, env] = exp.cdr.car.eval(env)
          rslt
        else if exp.isCons()       and
                exp.car.isSymbol() and
                exp.car.toString() is "unquoteSplicing"
          [rslt, env] = exp.cdr.car.eval(env)
          if rslt.isCons()
            rslt.car
          else throw "Uncaught TypeError: " + exp + " is not Cons"
        else if exp.isCons()
          new Cons(
            exp.car,
            unquoteTail(exp.cdr, env))
        else exp
      unquoteTail = (exp, env)->
        if exp.isCons() and
           exp.car.isCons()
          new Cons(
            unquoteHead(exp.car, env),
            unquoteTail(exp.cdr, env))
        else if exp.isCons()
          new Cons(
            exp.car,
            unquoteTail(exp.cdr, env))
        else exp
      _exps = unquoteHead(exp, env)
      [_exps, env]
    unquote: new Special "unquote", ([exp], env)-> #,
      throw "Unexpected unquote Error"
    unquoteSplicing: new Special "unquoteSplicing", ([exp], env)-> #,@
      throw "Unexpected unquoteSplicing Error"


  class Environment
    constructor: (env)->
      @stack = [].concat(env)
    find: (key)-> #Expression
      val = @stack.reduce ((val, hash)-> val or hash[key]), null
      if val? then val
      else throw "ReferenceError: " + key + " is not defined"
    createClosure: (keys, vals)-> #Environment
      stack = @stack.slice() #!! side effect !!
      hash = {}              #!! side effect !!
      keys.forEach (key, i)->
        hash[key] = vals[i] #!! side effect !!
      stack.push(hash) #!! side effect !!
      new Environment(stack)
    extend: (key, val)-> #Environment
      @stack[@stack.length-1][key] = val
      @



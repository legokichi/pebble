# 00_define


global = @


global.Pebble = do ->


  "use strict"


  ws = (i)-> [0..i].map(->"").join("  ")


  special = do ->


    binOp = (op)-> (args, i)->
      [name, val] = args.map (exp)-> exp.toCoffeeScript(i)
      name + " " + op + " " + val + "\n"
    nthOp = (op)-> (args, i)->
      if args.length is 0 then args = [0] # !! side effect !!
      exps = args.map (exp)-> exp.toCoffeeScript(i+1)
      "(" + exps.join(" " + op + " ") + ")"
    bfrOp = (op)-> ([obj], i)->
      op + "(" + obj.toCoffeeScript(i) + ")"
    aftOp = (op)-> ([obj], i)->
      obj.toCoffeeScript(i) + op

    return {
      if: (args, i)->
        [test, t, f] = args.map (exp)-> exp.toCoffeeScript(i+1)
        "if " + test + "\n" +
        ws(i+1) + t + "\n" +
        ws(i) + "else\n" +
        ws(i+1) + f + "\n"
      for: ([param, bodys...], i)->
        [symb, lst] = param.toArray().map (exp)-> exp.toCoffeeScript(i+1)
        _bodys = bodys.map (exp)-> exp.toCoffeeScript(i+1)
        wsbodys = _bodys.slice(1).map (cs)-> ws(i+1) + cs
        "for " + symb + " in " + lst + "\n" +
        ws(i+1)+[].concat(_bodys[0],wsbodys).join("\n") + "\n"
      while: (args, i)->
        [test, bodys...] = args.map (exp)-> exp.toCoffeeScript(i+1)
        wsbodys = bodys.slice(1).map (cs)-> ws(i+1) + cs
        "while " + test + "\n" +
        ws(i+1)+[].concat(bodys[0],wsbodys).join("\n") + "\n"
      do:  (args, i)->
        bodys = args.map (exp)-> exp.toCoffeeScript(i)
        wsbodys = bodys.slice(1).map (cs)-> ws(i) + cs
        [].concat(bodys[0],wsbodys).join("\n") + "\n"

      fn: ([param, bodys...], i)->
        _params = param.toArray().map (exp)-> exp.toCoffeeScript(i+1)
        _bodys = bodys.map (exp)-> exp.toCoffeeScript(i+1)
        wsbodys = _bodys.slice(1).map (cs)-> ws(i+1) + cs
        "((" + _params.join(", ") + ")->\n" +
         ws(i+1)+[].concat(_bodys[0],wsbodys).join("\n") + ")"

      ".": (args, i)->
        [prop, obj] = args.map (exp)-> exp.toCoffeeScript(i)
        obj + "[\"" + prop + "\"]"

      "=":  binOp("=")
      "+=": binOp("+=")
      "-=": binOp("-=")
      "*=": binOp("*=")
      "/=": binOp("/=")
      "%=": binOp("%=")
      "<<=":  binOp("<<=")
      ">>=":  binOp(">>=")
      ">>>=": binOp(">>>=")
      "&=": binOp("&=")
      "^=": binOp("^=")
      "|=": binOp("|=")
      "?=": binOp("?=")

      is:   binOp("is")
      isnt: binOp("isnt")
      ">":  nthOp(">")
      ">=": nthOp(">=")
      "<":  nthOp("<")
      "<=": nthOp("<=")

      "+":  nthOp("+")
      "-":  nthOp("-")
      "*":  nthOp("*")
      "/":  nthOp("/")
      "%":  nthOp("%")

      "&":  nthOp("&")
      "|":  nthOp("|")
      "^":  nthOp("^")
      "~":  bfrOp("~")
      "<<":  nthOp("<<")
      ">>":  nthOp(">>")
      ">>>": nthOp(">>>")

      and:nthOp("and")
      or : nthOp("or")
      "!":  bfrOp("!")

      "?":  aftOp("?")

      new:    bfrOp("new")
      delete: bfrOp("delete")
      typeof: bfrOp("typeof")

      of:         binOp("of")
      instanceof: binOp("instanceof")

    }



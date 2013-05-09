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
      def:  binOp("=")

      fn: ([param, body], i)->
        _params = param.toArray().map (exp)-> exp.toCoffeeScript(i+1)
        body = body.toCoffeeScript(i+1)
        "((" + _params.join(", ") + ")->\n" +
        ws(i+1) + body + ")"

      defn: ([name, param, body], i)->
        _params = param.toArray().map (exp)-> exp.toCoffeeScript(i+1)
        body = body.toCoffeeScript(i+1)
        "#{name} = (" + _params.join(", ") + ")->\n" +
        ws(i+1) + body + "\n"

      do: ([bodys...], i)->
        _bodys = bodys.map (exp)-> exp.toCoffeeScript(i+1)
        wsbodys = _bodys.map (body)-> ws(i+1) + body
        "(do ->\n" +
         wsbodys.join("\n") + ")"

      if: (args, i)->
        _args = args.map (exp)-> exp.toCoffeeScript(i+1)
        code = ""
        [test, body, _args...] = _args
        code += "if #{test}\n#{ws(i+1)}#{body}\n"
        while true
          [test, body, _args...] = _args # !! side effect !!
          if test? and body?
            code += "#{ws(i)}else if #{test}\n#{ws(i+1)}#{body}\n"
          else if test? and !body?
            code += "#{ws(i)}else\n#{ws(i+1)}#{test}\n"
          else
            break
        code

      for: ([param, bodys...], i)->
        [symb, lst] = param.toArray().map (exp)-> exp.toCoffeeScript(i+1)
        _bodys = bodys.map (exp)-> exp.toCoffeeScript(i+1)
        wsbodys = _bodys.slice(1).map (cs)-> ws(i+1) + cs
        "for " + symb + " in " + lst + "\n" +
        ws(i+1)+[].concat(_bodys[0],wsbodys).join("\n") + "\n"

      forof: ([param, bodys...], i)->
        [symb, lst] = param.toArray().map (exp)-> exp.toCoffeeScript(i+1)
        _bodys = bodys.map (exp)-> exp.toCoffeeScript(i+1)
        wsbodys = _bodys.slice(1).map (cs)-> ws(i+1) + cs
        "for " + symb + " of " + lst + "\n" +
        ws(i+1)+[].concat(_bodys[0],wsbodys).join("\n") + "\n"

      loop: ([defs, body], i)->
        _defs = defs.toArray().map (exp)-> exp.toCoffeeScript(i+1)
        j = 0
        ary = []
        while true
          if _defs.length <= j
            break
          else
            ary.push([_defs[j++], _defs[j++]]) # !! side effect !!
        "do ->\n" +
        ary.map(([name, val])-> ws(i+1) + "#{name} = #{val}").join("\n") + "\n" +
        ws(i+1) + "__recur__ = (args)->\n" +
        ary.map(([name, val], k)-> ws(i+2) + "#{name} = args[#{k}]").join("\n") + "\n" +
        ws(i+1) + "while true\n" +
        ws(i+2) + "return " + body.toCoffeeScript(i+2) + "\n" +
        ws(i+2) + "break\n"

      recur: (args,i)->
        _args = args.map (exp)-> exp.toCoffeeScript(i+1)
        "__recur__(["+_args.join(", ")+"])\n" +
        ws(i) + "continue\n"

      ".": (args, i)->
        [prop, obj] = args.map (exp)-> exp.toCoffeeScript(i)
        obj + "[\"" + prop + "\"]"

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



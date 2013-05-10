# 00_define


global = @


global.PebbleScript = do ->


  "use strict"


  ws = (i)-> [0..i].map(->"").join("  ")

  extend = (parent, attr)->
    f = ->
      for key, val of attr
        @[key] = val
    f.prototype = attr
    new f()

  special = do ->

    nthOp = (op)-> (args, i)->
      if args.length < 2 then args.unshift(new Numeral(0)) # !! side effect !!
      _body = args.map((exp)-> exp.toCoffeeScript(i+1))
                  .join(" #{op} ")
      "(#{_body})"
    bfrOp = (op)-> ([arg], i)->
      _arg = arg.toCoffeeScript(i+1)
      "#{op}(#{_arg})"
    aftOp = (op)-> ([arg], i)->
      _arg = arg.toCoffeeScript(i+1)
      "(#{_arg})#{op}"

    return {
      def: (args, i)->
        [_name, _val] = args.map((exp)-> exp.toCoffeeScript(i))
        "#{_name} = #{_val}"

      defn: ([name, params, body], i)->
        _name = name.toCoffeeScript(i+1)
        _fn = @fn([params, body], i)
        "#{_name} = #{_fn}"

      fn: ([params, body], i)->
        _params = params.toArray()
                       .map((exp)-> exp.toCoffeeScript(i+1))
                       .join(", ")
        _body = body.toCoffeeScript(i+1)
        """
        ((#{_params})->
        #{ws(i+1)}#{_body}
        #{ws(i)})
        """

      do: (bodys, i)->
        _bodys = bodys.map((exp)-> exp.toCoffeeScript(i+1))
                      .map((body)-> "#{ws(i+1)}#{body}")
                      .join("\n")
        """
        (do ->
        #{_bodys}
        #{ws(i)})
        """

      let: ([params, body], i)->
        lst = params.toArray()
                    .map (exp)-> exp.toCoffeeScript(i+1)
        ziped = ([x, lst[j+1]] for x, j in lst by 2)
        _defs = ziped.map(([name, val])-> "#{ws(i+1)}#{name} = #{val}")
                     .join("\n")
        _body = body.toCoffeeScript(i+1)
        """
        (do ->
        #{_defs}
        #{ws(i+1)}#{_body}
        #{ws(i)})
        """

      module: ([name, bodys...], i)->
        _name = name.toCoffeeScript(i)
        _bodys = bodys.map((exp)-> exp.toCoffeeScript(i+1))
                      .map((_body)-> "#{ws(i+1)}#{_body}")
                      .join("\n")
        """
        #{_name} = (->
        #{_bodys}
        #{ws(i+1)}@
        #{ws(i)}).call(#{_name} or {})
        """

      export: (args, i)->
        [_name, _val] = args.map((exp)-> exp.toCoffeeScript(i))
        "@#{_name} = #{_val}"

      defclass: ([name, cnstr, bodys...], i)->
        _name = name.toCoffeeScript(i)
        _cnstr = cnstr.toCoffeeScript(i+1)
        _bodys = bodys.map((exp)-> exp.toCoffeeScript(i+1))
                      .map((_body)-> "#{ws(i+1)}#{_body}")
                      .join("\n")
        """
        class #{_name}
        #{ws(i+1)}#{_cnstr}
        #{_bodys}
        """

      public: (args, i)->
        [_name, _val] = args.map((exp)-> exp.toCoffeeScript(i))
        "#{_name}: #{_val}"

      private: -> @export.apply(this, arguments)

      if: (args, i)->
        [_test, _body, tail...] = args.map (exp)-> exp.toCoffeeScript(i+1)
        code = """
        if #{_test}
        #{ws(i+1)}#{_body}\n
        """
        while true
          [_test, _body, tail...] = tail # !! side effect !!
          if _test? and _body?
            code += """
            #{ws(i)}else if #{_test}
            #{ws(i+1)}#{_body}\n
            """ # !! side effect !!
          else if _test? and !_body?
            code += """
            #{ws(i)}else
            #{ws(i+1)}#{_test}
            """
          else break
        code

      for: ([params, body], i)->
        [_symb, _lst] = params.toArray()
                             .map (exp)-> exp.toCoffeeScript(i+1)
        _body = body.toCoffeeScript(i+1)
        "(do -> (#{_body}) for #{_symb} in #{_lst})"

      loop: ([params, body], i)->
        lst = params.toArray()
                    .map (exp)-> exp.toCoffeeScript(i+1)
        ziped = ([x, lst[j+1]] for x, j in lst by 2)
        _defs = ziped.map(([name, val])-> "#{ws(i+1)}#{name} = #{val}")
                     .join("\n")
        _redefs = ziped.map(([name, val], k)-> "#{ws(i+2)}#{name} = args[#{k}]")
                       .join("\n")
        _body = body.toCoffeeScript(i+2)
        """
        ((__recur__)->
        #{_defs}
        #{ws(i+1)}__recur__ = (args)->
        #{_redefs}
        #{ws(i+1)}while true
        #{ws(i+2)}return #{_body}
        #{ws(i+2)}break
        #{ws(i  )})(null)
        """

      recur: (args,i)->
        _args = args.map((exp)-> exp.toCoffeeScript(i+1))
                    .join(", ")
        "__recur__(#{_args}); continue"

      try: (args, i)->
        "try\n" +
        args.map((exp)->
          if exp.isCall() and
             (symb = exp.get(0))? and
             symb.isSymbol() and
             (symb.value is "catch" or symb.value is "finally")
            if symb.value is "catch"
              [err, bodys...] = exp.toArray().slice(1)
              _err = err.toCoffeeScript(i)
              _bodys = bodys.map((exp)-> ws(i+1) + exp.toCoffeeScript(i+1))
                            .join("\n")
              """
              #{ws(i)}catch #{_err}
              #{_bodys}\n
              """ # !! side effect !!
            else
              _bodys = exp.toArray().slice(1)
                          .map((exp)-> ws(i+1) + exp.toCoffeeScript(i+1))
                          .join("\n")
              """
              #{ws(i)}finally
              #{_bodys}\n
              """ # !! side effect !!
          else
            _body = exp.toCoffeeScript(i+1)
            "#{ws(i+1)}#{_body}\n"
        ).join("")


      ".": (args, i)->
        [obj, prop, argus...] = args
        [_obj, _prop, _argus...] = args.map (exp)-> exp.toCoffeeScript(i)
        if prop.isSymbol()
          code = "#{_obj}.#{_prop}"
        else
          code = "#{_obj}[#{_prop}]"
        if _argus.length isnt 0
          code += "("+_argus.join(", ")+")"
        code

      "..": ([obj, args...], i)->
        "#{obj}\n" +
        args.map((exp)->
          if exp.isCall()
            [_prop, _argus...] = exp.toArray()
                                    .map (exp)-> exp.toCoffeeScript(i+1)
            "#{ws(i+1)}.#{_prop}("+_argus.join(", ")+")\n"
          else
            _prop = exp.toCoffeeScript(i+1)
            "#{ws(i+1)}.#{_prop}\n"
        ).join("")

      new: ([klass, args...], i)->
        _class = klass.toCoffeeScript(i)
        _args = args.map((exp)-> exp.toCoffeeScript(i+1))
                    .join(", ")
        "new #{_class}(#{_args})\n"

      coffee: ([text], i)->
        _bodys = text.toString()
                     .split("\n")
                     .map((line)-> "#{ws(i+1)}#{line}")
                     .join("\n")
        """
        (do ->
        #{_bodys}\n
        #{ws(i)})
        """

      "set!": nthOp("=")

      "==": nthOp("is")
      "!=": nthOp("isnt")
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
      not:  bfrOp("!")

      "?":  aftOp("?")

      delete: bfrOp("delete")
      typeof: bfrOp("typeof")

      of:         nthOp("of")
      instanceof: nthOp("instanceof")

    }




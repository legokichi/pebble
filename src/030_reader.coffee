# reader


  reader = do ->


    parse = (pscode)->
      new Nodes(root(pscode, []))


    space = do ->
      wsReg = /^\s+|^(?:\s*\;[^\n]*(?:\n|$))+/
      (str)->
        if not wsReg.test(str) then str
        else
          n = wsReg.exec(str)[0];
          str.slice(n.length)


    split = (str)->
      [str[0], str.slice(1)]


    root = (str, exps)->
      _str = space(str)
      if _str.length is 0 then exps
      else
        [rstr, exp] = expr(_str)
        root(rstr, exps.concat(exp))


    expr = (str)->
      _str = space(str)
      if _str.length is 0 then throw "SyntaxError: Unexpected EOF"
      [head, tail] = split(_str)
      if head is "'"
        [rstr, exp] = expr(tail)
        [rstr, new Call([new Symbol("quote"), exp])]
      else if head is "`"
        [rstr, exp] = expr(tail)
        [rstr, new Call([new Symbol("syntax-quote"), exp])]
      else if head is "," and tail[0] is "@"
        [rstr, exp] = expr(tail.slice(1))
        [rstr, new Call([new Symbol("unquote-splicing"), exp])]
      else if head is ","
        [rstr, exp] = expr(tail)
        [rstr, new Call([new Symbol("unquote"), exp])]
      else if head is "(" then call(tail, new Call([]))
      else if head is "[" then list(tail, new List([]))
      else if head is "{" then hash(tail, new Hash({}))
      else                     atom(_str)


    call = (str, cal)->
      _str = space(str)
      [head, tail] = split(_str)
      if head is ")" then [tail, cal]
      else
        [rstr, exp] = expr(_str)
        call(rstr, cal.push(exp))


    list = (str, lst)-> # [String, Vector]
      _str = space(str)
      [head, tail] = split(_str)
      if head is "]" then [tail, lst]
      else if head is "&"
        [rstr, symb] = expr(space(tail))
        if not symb.isSymbol() then throw "SyntaxError: Unexpected \"&\" to #{symb}"
        symb.value += "..." # !! side effect !!
        list(rstr, lst.push(symb))
      else
        [rstr, exp] = expr(_str)
        list(rstr, lst.push(exp))


    hash = (str, hsh)->
      _str = space(str)
      [head, tail] = split(_str)
      if head is "}" then [tail, hsh]
      else
        [rstr1, key] = expr(_str)
        if not key.isText() then throw "SyntaxError: Unexpected #{_str}"
        rstr2 = space(rstr1)
        if rstr2[0] is "}"
          [rstr2.slice(1), hsh.set(key, new Symbol(String(key)))]
        else
          [rstr3, val] = expr(rstr2)
          hash(rstr3, hsh.set(key, val))


    atom = do ->
      textReg = /^\"((?:[^\"\\]|(?:\\(?:\"|\\|\/|b|f|n|r|t|u[0-9a-fA-F]{4})))*)\"/
      numeralReg = /^\-?(?:0|[1-9]\d*)(?:\.\d+)?(?:(?:e|E)(?:\+|\-)?\d+)?/
      keywordReg = /^\:([a-zA-Z0-9\_\$\+\-\*\/\%\&\|\~\^\<\>\=\!\?]+)/
      propReg = /^\.[a-zA-Z\_\$\+\-\*\%\&\|\~\^\/\<\>\=\!\?][a-zA-Z\_\$\d\+\-\*\/\%\&\|\~\^\<\>\=\!\?\:]*/
      symbolReg = /^[\.\:](?=[\s\;])|^[a-zA-Z\_\$\+\-\*\%\&\|\~\^\/\<\>\=\!\?][a-zA-Z\_\$\d\+\-\*\%\&\|\~\^\/\<\>\=\!\?\:\.*]*/
      regReg = /^\/((?:[^\s\/\\]|(?:\\[\/\:\\\^\$\*\+\?\.\(\)\:\=\!\|\{\}\,\[\]bBcdDfnrsStvwWn0xu]))*)\/([gimy]{0,4})?/
      (str)->
        _str = space(str)
        if textReg.test(_str)
          [mch, val] = textReg.exec(_str)
          [_str.slice(mch.length), new Text(String(val))]
        else if numeralReg.test(_str)
          val = numeralReg.exec(_str)[0]
          [_str.slice(val.length), new Numeral(Number(val))]
        else if keywordReg.test(_str)
          val = keywordReg.exec(_str)[0]
          [_str.slice(val.length), new Keyword(String(val.slice(1)))]
        else if propReg.test(_str)
          val = propReg.exec(_str)[0].slice(1)
          [_str.slice(val.length+1), new Property(String(val))]
        else if symbolReg.test(_str)
          val = symbolReg.exec(_str)[0]
          [_str.slice(val.length), new Symbol(String(val))]
        else if regReg.test(_str)
          val = regReg.exec(_str)[0]
          [mch, reg, atr] = regReg.exec(_str)
          [_str.slice(mch.length), new Regular(RegExp(reg, atr))]
        else
          throw "SyntaxError: Unexpected identifier #{_str}"


    return {
      parse: parse
    }



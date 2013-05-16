# reader


  reader = do ->


    parse = (pscode)->
      new UnMacroExpandedNodes(root(pscode, []))


    space = do ->
      wsReg = /^\s+|^(?:\s*\;[^\n]*(?:\n|$))+/
      (str)-> # String
        if wsReg.test(str)
          n = wsReg.exec(str)[0];
          str.slice(n.length)
        else
          str


    root = (str, ary)-> # [Expression]
      _str = space(str)
      if _str.length is 0 then ary
      else
        [rstr, exp] = expr(_str)
        _ary = ary.concat(exp)
        root(rstr, _ary)


    expr = (str)-> # [String, Expression]
      _str = space(str)
      if _str.length is 0
        throw "SyntaxError: Unexpected EOF"
      [head, tail] = [_str[0], _str.slice(1)]
      if head is "#"
        if tail[0] is "("
          [rstr1, call] = expr(tail)
          [rstr1, new Call([
            new Symbol("fn"),
            new Vector([
              new Symbol("_0"),
              new Symbol("_1"),
              new Symbol("_2"),
              new Symbol("_3"),
              new Symbol("_4"),
              new Symbol("_5")]),
              call])]
        else
          console.log head + tail
          throw "SyntaxError: Unexpected reader macro " + head
      else if head is "'"
        [rstr1, exp] = expr(tail)
        [rstr1, new Call([
          new Symbol("quote"),
          exp])]
      else if head is "`"
        [rstr1, exp] = expr(tail)
        [rstr1, new Call([
          new Symbol("syntax-quote"),
          exp])]
      else if head is ","
        if tail[0] is "@"
          [rstr1, exp] = expr(tail.slice(1))
          [rstr1, new Call([
            new Symbol("unquote-splicing"),
            exp])]
        else
          [rstr1, exp] = expr(tail)
          [rstr1, new Call([
            new Symbol("unquote"),
            exp])]
      else if head is "(" then form(tail, new Call([]))
      else if head is "[" then vect(tail, new Vector([]))
      else if head is "{" then hash(tail, new Hash({}))
      else                     atom(_str)


    form = (str, call)-> # [String, Call]
      _str = space(str)
      [head, tail] = [_str[0], _str.slice(1)]
      if head is ")" then [tail, call]
      else
        [rstr, exp1] = expr(_str)
        form(rstr, call.append(exp1))


    vect = (str, vct)-> # [String, Vector]
      _str = space(str)
      [head, tail] = [_str[0], _str.slice(1)]
      if head is "]" then [tail, vct]
      else if head is "&"
        [rstr, symb] = expr(space(tail))
        symb.value += "..." # !! side effect !!
        vect(rstr, vct.append(symb))
      else
        [rstr, exp] = expr(_str)
        vect(rstr, vct.append(exp))


    hash = (str, hsh)-> # [String, Hash]
      _str = space(str)
      [head, tail] = [_str[0], _str.slice(1)]
      if head is "}" then [tail, hsh]
      else
        [rstr1, exp1] = expr(_str)
        rstr2 = space(rstr1)
        if rstr2[0] is "}"
          [rstr2.slice(1), hsh.set(exp1, new Symbol(exp1.toString()))]
        else
          [rstr3, exp2] = expr(rstr2)
          hash(rstr3, hsh.set(exp1, exp2))


    atom = do ->
      textReg = /^\"((?:[^\"\\]|(?:\\(?:\"|\\|\/|b|f|n|r|t|u[0-9a-fA-F]{4})))*)\"/
      keywordReg = /^\:[^\s\"\'\`\,\@\#\;\(\)\[\]\{\}\:]+/
      numeralReg = /^\-?(?:0|[1-9]\d*)(?:\.\d+)?(?:(?:e|E)(?:\+|\-)?\d+)?/
      symbolReg = /^[^\s\"\'\`\,\@\;\(\)\[\]\{\}\d][^\s\"\'\`\,\@\;\(\)\[\]\{\}\:\/]*/
      propReg = /^\.[^\s\"\'\`\,\@\;\(\)\[\]\{\}\:\d\/\.][^\s\"\'\`\,\@\;\(\)\[\]\{\}\:\/]*/
      regReg = /^\/((?:[^\s\/\\]|(?:\\[\/\:\\\^\$\*\+\?\.\(\)\:\=\!\|\{\}\,\[\]bBcdDfnrsStvwWn0xu]))*)\/([gimy]{0,4})?/
      (str)-> # [String, Expression]
        _str = space(str)
        if propReg.test(_str)
          val = propReg.exec(_str)[0].slice(1)
          rstr = _str.slice(val.length+1)
          [rstr, new Property(val)]
        else if regReg.test(_str)
          val = regReg.exec(_str)[0]
          [mch, reg, atr] = regReg.exec(_str)
          rstr = _str.slice(mch.length)
          [rstr, new Regular(RegExp(reg, atr))]
        else if numeralReg.test(_str)
          val = numeralReg.exec(_str)[0]
          rstr = _str.slice(val.length)
          [rstr, new Numeral(Number(val))]
        else if keywordReg.test(_str)
          val = keywordReg.exec(_str)[0]
          rstr = _str.slice(val.length)
          [rstr, new Keyword(val.slice(1))]
        else if symbolReg.test(_str)
          val = symbolReg.exec(_str)[0]
          rstr = _str.slice(val.length)
          [rstr, new Symbol(val)]
        else if textReg.test(_str)
          [mch, val] = textReg.exec(_str)
          rstr = _str.slice(mch.length)
          [rstr, new Text(val)]
        else
          throw "SyntaxError: Unexpected identifier " + _str


    return {
      parse: parse
    }



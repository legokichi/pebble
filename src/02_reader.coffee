# 02_Reader


  reader = do ->


    parse = (code)->
      {expressions: root(code, [])}


    space = do ->
      wsReg = /(?:^;.*\n?)|(?:^\s+)/
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
        ary.push(exp) # !! side effect !!
        root(rstr, ary)


    expr = (str)-> # [String, Expression]
      _str = space(str)
      if _str.length is 0 then throw "SyntaxError: Unexpected EOF"
      [head, tail] = [_str[0], _str.slice(1)]
      if      head is "#"
        rstr1 = space(tail)
        if rstr1[0] is "("
          [rstr2, call] = expr(rstr1)
          [rstr2, new Call([
            new Symbol("fn"),
            new Vector([
              new Symbol("_...")]),
              call
          ])]
        else thorw  "SyntaxError: Unexpected reader macro " + head + tail
      else if head is "(" then form(tail, new Call([]))
      else if head is "[" then vect(tail, new Vector([]))
      else if head is "{" then hash(tail, new Hash({}))
      else                     atom(_str)


    form = (str, frm)-> # [String, Form]
      _str = space(str)
      [head, tail] = [_str[0], _str.slice(1)]
      if head is ")" then [tail, frm]
      else
        [rstr, exp1] = expr(_str)
        form(rstr, frm.append(exp1))


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
          [rstr2.slice(1), hsh.set(exp1, new Text(exp1))]
        else
          [rstr3, exp2] = expr(rstr2)
          hash(rstr3, hsh.set(exp1, exp2))


    atom = do ->
      textReg = /^\"((?:[^\"\\]|(?:\\(?:\"|\\|\/|b|f|n|r|t|u[0-9a-fA-F]{4})))*)\"/
      keywordReg = /^\:[^\s\"\'\`\,\@\#\;\(\)\[\]\{\}\:]+/
      numeralReg = /^\-?(?:0|[1-9]\d*)(?:\.\d+)?(?:(?:e|E)(?:\+|\-)?\d+)?/
      symbolReg = /^[^\s\"\'\`\,\@\;\(\)\[\]\{\}\:\d][^\s\"\'\`\,\@\;\(\)\[\]\{\}\:\/]*/
      propReg = /^\.[^\s\"\'\`\,\@\;\(\)\[\]\{\}\:\d\/\.][^\s\"\'\`\,\@\;\(\)\[\]\{\}\:\/]*/
      regReg = /^\/(?:[^\s\/\\]|(?:\\[\/\:\\\^\$\*\+\?\.\(\)\:\=\!\|\{\}\,\[\]bBcdDfnrsStvwWn0xu]))*\/(?:[gimy]{0,4})?/
      (str)-> # [String, Expression]
        _str = space(str)
        if propReg.test(_str)
          val = propReg.exec(_str)[0]
          rstr = _str.slice(val.length)
          [rstr, new Property(val)]
        else if regReg.test(_str)
          val = regReg.exec(_str)[0]
          rstr = _str.slice(val.length)
          [rstr, new Regular(val)]
        else if symbolReg.test(_str)
          val = symbolReg.exec(_str)[0]
          rstr = _str.slice(val.length)
          [rstr, new Symbol(val)]
        else if numeralReg.test(_str)
          val = numeralReg.exec(_str)[0]
          rstr = _str.slice(val.length)
          [rstr, new Numeral(val)]
        else if keywordReg.test(_str)
          val = keywordReg.exec(_str)[0]
          rstr = _str.slice(val.length)
          [rstr, new Keyword(val.slice(1))]
        else if textReg.test(_str)
          [mch, val] = textReg.exec(_str)
          rstr = _str.slice(mch.length)
          [rstr, new Text(val)]
        else throw "SyntaxError: Unexpected identifier " + _str


    return {
      parse: parse
    }



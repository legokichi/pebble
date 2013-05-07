# 02_Reader


  reader = do ->


    parse = (code)->
      {expressions: root(code, [])}


    space = (str)-> # String
      if /^\S/.test(str) or str.length is 0 then str
      else
        n = /^\s+/.exec(str)[0];
        str.slice(n.length)


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
      if      head is "(" then form(tail, new Call([]))
      else if head is "[" then vect(tail, new Vector([]))
      else if head is "{" then hash(tail, new Hash({}))
      else                atom(_str)


    form = (str, frm)-> # [String, Form]
      _str = space(str)
      [head, tail] = [_str[0], _str.slice(1)]
      if head is ")" then [tail, frm]
      else
        [rstr1, exp1] = expr(_str)
        form(rstr1, frm.append(exp1))


    vect = (str, vct)-> # [String, Vector]
      _str = space(str)
      [head, tail] = [_str[0], _str.slice(1)]
      if head is "]" then [tail, vct]
      else
        [rstr1, exp1] = expr(_str)
        vect(rstr1, vct.append(exp1))


    hash = (str, hsh)-> # [String, Hash]
      _str = space(str)
      [head, tail] = [_str[0], _str.slice(1)]
      if head is "}" then [tail, hsh]
      else
        [rstr1, exp1] = expr(_str)
        [rstr2, exp2] = expr(rstr1)
        hash(rstr2, hsh.set(exp1, exp2))


    atom = do ->
      textReg = /^\"((?:[^\"\\]|(?:\\(?:\"|\\|\/|b|f|n|r|t|u[0-9a-fA-F]{4})))*)\"/
      keywordReg = /^\:[^\s\"\'\`\,\@\#\;\(\)\[\]\{\}\:]+/
      numeralReg = /^\-?(?:0|[1-9]\d*)(?:\.\d+)?(?:(?:e|E)(?:\+|\-)?\d+)?/
      symbolReg = /^[^\s\"\'\`\,\@\;\(\)\[\]\{\}\:\d][^\s\"\'\`\,\@\;\(\)\[\]\{\}\:]*/
      (str)-> # [String, Expression]
        _str = space(str)
        if symbolReg.test(_str)
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
          [rstr, new Text(val.slice(1))]
        else if textReg.test(_str)
          [mch, val] = textReg.exec(_str)
          remainStr = _str.slice(mch.length)
          [remainStr, new Text(val)]
        else throw "SyntaxError: Unexpected identifier " + _str


    return {
      parse: parse
    }



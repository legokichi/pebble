#02_Parser


  class AbstractSyntaxTree
    constructor: -> #AbstractSyntaxTree
      @expressions = [] #!! side effect !!
    parse: (str)-> #AbstractSyntaxTree #!! side effect !!
      root(@, str)
    run: (fn)-> #[Expression]
      env = new Environment(globalEnv)
      @expressions.map (exp)->
        [exp, env] = exp.eval(env)
        exp
    space = (str)->
      if /^\S/.test(str) or str.length is 0 then str
      else
        n = /^\s+/.exec(str)[0];
        str.slice(n.length)
    root = (tree, str)->
      _str = space(str)
      if _str.length is 0 then tree
      else
        [remainStr, sexp] = sExp(_str)
        tree.expressions.push(sexp) #!! side effect !!
        root(tree, remainStr) #step to next expression
    sExp = (str)->
      _str = space(str)
      head = _str[0]
      tail = _str.slice(1)
      if head is "(" then list(tail)
      else if head is "'"
        [remainStr, sexp] = sExp(tail)
        _sexp = new Cons(new Symbol("quote"),
                 new Cons(sexp,
                          new Nil()))
        [remainStr, _sexp]
      else if head is "`"
        [remainStr, sexp] = sExp(tail)
        _sexp = new Cons(new Symbol("quasiquote"),
                 new Cons(sexp,
                          new Nil()))
        [remainStr, _sexp]
      else if head is ","
        [remainStr, sexp] = sExp(tail)
        _sexp = new Cons(new Symbol("unquote"),
                 new Cons(sexp,
                          new Nil()))
        [remainStr, _sexp]
      else                atom(_str)
    list = (str)->
      _str = space(str)
      head = _str[0]
      tail = _str.slice(1)
      if      head is ")" then [tail, new Nil()]
      else if head is "."
        [remainStr1, exp] = sExp(tail)
        remainStr2 = space(remainStr1).slice(1)
        [remainStr2, exp]
      else
        [remainStr1, fst] = sExp(_str)
        [remainStr2, scd] = list(remainStr1)
        [remainStr2, new Cons(fst, scd)]
    textReg = /^\"((?:[^\"]|\\\")*)\"/
    numeralReg = /^\-?\d+(?:\.\d+)?/
    symbolReg = /^[^\s\'\`\,\@\#\"\;\(\)]+/
    atom = (str)->
      _str = space(str)
      if textReg.test(_str) #Text
        [mch, val] = textReg.exec(_str)
        remainStr = _str.slice(mch.length)
        [remainStr, new Text(val)]
      else if numeralReg.test(_str) #Numeral
        val = numeralReg.exec(_str)[0]
        remainStr = _str.slice(val.length)
        [remainStr, new Numeral(val)]
      else if symbolReg.test(_str) #Symbol
        val = symbolReg.exec(_str)[0]
        remainStr = _str.slice(val.length)
        [remainStr, new Symbol(val)]
      else throw "SyntaxError: Unexpected something " + _str



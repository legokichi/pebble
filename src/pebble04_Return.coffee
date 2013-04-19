# 04_Return


  compile = (str)->
    tree = new AbstractSyntaxTree()
    tree.parse(str)
    ary = tree.run()
    ary.filter((_)->
      _.isRawString()
    ).map((_)->
      _.toString()
    ).join("\n\n")


  global.addEventListener "load", ->
    nodes = document.getElementsByTagName("script")
    str = ""
    Array.prototype.slice.call(nodes).forEach (script)->
      if script.type is "text/pebblelisp"
        str += script.innerText
    console.log(compile(str))


  return {compile: compile}



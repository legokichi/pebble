#


  ###
  window?.addEventListener "DOMContentLoaded", ->
    scripts = document.getElementsByTagName("script")
    ary = Array.prototype.slice.call(scripts)
    codes = ary.map (script)->
      if script.type is "text/pebble" then script.innerText
      else ""
    code = codes.join("\n\n")
    console.log emitter.coffee(code)
    emitter.eval(code)
  ###


  return {
    nodes: (pscode)->
      reader.parse(pscode)
    macroexpand: (pscode)->
      @nodes(pscode).expandMacros()
    toCoffee: (pscode)->
      @macroexpand(pscode).compileToCoffeeScript()
    compile: (pscode)->
      @toCoffee(pscode).compile()
    run: (pscode)->
      Function(@compile(pscode))()
  }


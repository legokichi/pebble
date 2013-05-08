# 04_return


  window?.addEventListener "DOMContentLoaded", ->
    scripts = document.getElementsByTagName("script")
    ary = Array.prototype.slice.call(scripts)
    codes = ary.map (script)->
      if script.type is "text/pebble" then script.innerText
      else                                  ""
    code = codes.join("\n\n")
    #console.log emitter.coffee(code)
    emitter.eval(code)


  return {
    nodes:   reader.parse
    coffee:  emitter.coffee
    compile: emitter.compile
    eval:    emitter.eval
  }



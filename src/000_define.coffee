# define


global = @


global.PebbleScript = do ->


  "use strict"


  ws = (i)-> [0..i].map(->"").join("  ")


  class Environment
    constructor: (obj)->
      @stack = Object.create(null)
      @stack[key] = val for key, val of obj
    has: (key)-> @stack[key]?
    get: (key)-> @stack[key]
    set: (key, val)->
      @stack = Object.create(@stack) # !! side effect !!
      @stack[key] = val 
      @
    extend:(obj)->
      @stack = Object.create(@stack) # !! side effect !!
      @stack[key] = val for key, val of obj
      @



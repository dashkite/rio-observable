import * as Fn from "@dashkite/joy/function"
import * as Obj from "@dashkite/joy/object"
import * as K from "@dashkite/katana/async"
import * as Ks from "@dashkite/katana/sync"
import { Daisho } from "@dashkite/katana"

Observable =

  get: K.poke ( observable ) -> observable.get()

  update: ( fx ) ->
    mutator = Fn.flow fx
    ( _daisho ) ->
      daisho = _daisho.clone()
      observable = daisho.peek()
      await observable.update ( data ) ->
        daisho.poke data
        ( await mutator daisho ).peek()
      _daisho

  observe: ( fx ) ->
    handler = Fn.flow fx
    Ks.peek ( observable, handle ) ->
      do ->
        observable.observe ( state ) -> 
          handler Daisho.create [ state, handle ], { handle }      
      # avoid waiting on promise
      undefined
    
  cancel: Ks.peek ( observable, observer ) ->
    observable.cancel observer

  assign: K.peek ( update, observable ) ->
    observable.assign update

  pop: K.push ( observable ) -> observable.pop()

export default Observable
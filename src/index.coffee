import * as Fn from "@dashkite/joy/function"
import * as Obj from "@dashkite/joy/object"
import Generic from "@dashkite/generic"
import * as K from "@dashkite/katana/async"
import * as Ks from "@dashkite/katana/sync"
import { Daisho } from "@dashkite/katana"

Observable =

  get: Ks.poke Fn.unary do ->
    ( Generic.make "Observable.get" )
      .define [ Object ], ( observable ) -> observable.get()
      .define [ Obj.has "observable" ],  ({ observable }) -> observable.get()

  update: ( fx ) ->
    mutator = Fn.flow fx
    ( daisho ) ->
      value = daisho.peek()
      observable = if value.observable? then value.observable else value
      await observable.update ( data ) ->
        daisho.poke data
        daisho = await mutator daisho
        do daisho.pop
      daisho

  observe: ( fx ) ->
    handler = Fn.flow fx
    Ks.peek Fn.binary do ({ f } = {}) ->

      ( Generic.make "Observable.observe" )

      .define [ Object, Object ], ( observable, handle ) ->
        handle.observable = observable
        f handle

      .define [( Obj.has "observable" )],  f = ( handle ) ->
        { observable } = handle
        # avoid waiting on promise
        do ->
          handle.observer = observable.observe ( state ) -> 
            handler Daisho.create [ state, handle ], { handle }
        return      
    
  cancel: Ks.peek ( handle ) ->
    handle.observable.cancel handle.observer

  assign: K.peek Fn.binary do ->
    ( Generic.make "Observable.assign" )

      # if get an unassignable value (ex: null) just ignore
      .define [( -> true ), Object ], 
        ( _, observable ) -> observable
      .define [( -> true ), Obj.has "observable" ], 
        ( _, { observable }) -> observable

      .define [ Object, Object ], ( update, observable ) ->
        observable.assign update
      .define [ Object, Obj.has "observable" ], ( update, { observable }) -> 
        observable.assign update

  pop: K.push Fn.unary do ->  
    ( Generic.make "Observable.pop" )
      .define [ Object ], ( observable ) -> observable.pop()
      .define [ Obj.has "observable" ],  ({ observable }) -> observable.pop()

export default Observable
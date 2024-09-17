import * as Fn from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Ks from "@dashkite/katana/sync"
import { Daisho } from "@dashkite/katana"

Observable =

  get: Ks.poke ( observable ) -> observable.get()

  update: ( fx ) ->
    mutator = Fn.flow fx
    ( daisho ) ->
      observable = daisho.peek()
      await observable.update ( data ) ->
        daisho.push data
        daisho = await mutator daisho
        do daisho.pop
      daisho

  observe: ( fx ) ->
    handler = Fn.flow fx
    Ks.peek ( observable, handle ) ->
      handle.observable = observable
      # don't await on promise
      # TODO maybe change the autoconversion in katana?
      do ->
        # TODO use return value of observe to cancel
        handle.observer = observable.observe ( state ) -> 
          handler Daisho.create [ state, handle ], { handle }
      return

  cancel: Ks.peek ( observable, handle ) ->
    # observable = await Registry.get "sansa.editor.state"
    observable.cancel handle.observer

  assign: K.peek ( observable, update ) ->
    observable.update ( data ) -> Object.assign data, update

  pop: K.push ( observable ) -> observable.pop()

export default Observable
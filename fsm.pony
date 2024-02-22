use "collections"
use "logger"

interface Named 
  fun name(): String

class State is Named
  let _name:String
  
  new create(name' : String) =>
    _name = name'

  fun name() : String => _name


class Event is Named
  let _name:String
  
  new create(name' : String) =>
    _name = name'

  fun name() : String => _name



type Action is {(String):String}

class TransitionMapKey is Hashable 
  let _state : String
  let _event : String

  new create(s: String, e: String) =>
    _state = s
    _event = e

  fun box hash() : USize val =>
    (_state + _event).hash()
  
  fun box eq(that: TransitionMapKey) : Bool =>
    _state == that._state



class Transition
  let source: State
  let target: State
  let event: Event
  let action: Action

  new create(s: State, t:State, e: Event, a: Action) =>
    source = s
    target = t
    event = e
    action = a



class Fsm 
  let states: Array[State]
  let events: Array[Event]
  let transitionMap: Map[String,Transition]

  new create(states': Array[State], events': Array[Event], transitions': Array[Transition]) =>
    states = states'
    events = events'
    transitionMap = Map[String, Transition]
    for tr in transitions'.values() do
      transitionMap.insert(tr.source.name()+tr.event.name(), tr)
    end





actor Main
  new create(env: Env) =>
    let logger = StringLogger(Warn, env.out)
    env.out.print("FSM has started")
    logger.log("FSM has started")

    // States
    let lockedState = State("locked")
    let unlockedState = State("unlocked")

    // Events
    let pushEvent=Event("push")
    let coinEvent=Event("coin")
    
    // Actions
    let noAction : Action = {(s:String):String => s}


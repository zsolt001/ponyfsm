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
  var currentState: State
  let logger: StringLogger

  new init(s: Array[State], e: Array[Event], t: Array[Transition], l: StringLogger) =>
    states = s
    events = e
    transitionMap = HashMap[String, Transition, HashEq[String]]
    for tr in t.values() do
      transitionMap.insert(tr.source.name()+tr.event.name(), tr)
    end
    currentState = s(0)
    logger = l


  new create(states': Array[State], events': Array[Event], transitions': Array[Transition]) =>
    states = states'
    events = events'
    transitionMap = Map[String, Transition]
    for tr in transitions'.values() do
      transitionMap.insert(tr.source.name()+tr.event.name(), tr)
    end

  fun handleEvent(e: Event) =>
    var key = currentState.name() + e.name()
    let tr = transitionMap(key)
    currentState = tr.target

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

    let unlock = Transition(lockedState, unlockedState, coinEvent, noAction)
    let remainLocked = Transition(lockedState, lockedState, pushEvent, noAction)
    let goThrough = Transition(unlockedState, lockedState, pushEvent, noAction)
    let takeMoreMoney = Transition(unlockedState, unlockedState, coinEvent, noAction)

    let states = [
      lockedState 
      unlockedState
    ]
    let events = [pushEvent; coinEvent]
    let transitions = [
      unlock
      remainLocked
      goThrough
      takeMoreMoney
    ]
    let turnstile = Fsm.init(states, events, transitions, logger)

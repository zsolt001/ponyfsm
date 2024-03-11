use "collections"
use "logger"

interface Named 
  fun name(): String

class State is Named
  let _name:String
  
  new create(name' : String) =>
    _name = name'

  fun name() : String => _name

  fun ne(that: box->State) =>
    this._name != that._name


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
  var currentState: State ref
  let logger: Logger[String val] 

  new create(states': Array[State], events': Array[Event], transitions': Array[Transition], l: Logger[String]) ? =>
    logger = l
    states = states'
    events = events'
    transitionMap = HashMap[String, Transition, HashEq[String]]
    for tr in transitions'.values() do
      transitionMap.insert(tr.source.name()+tr.event.name(), tr)
    end
    currentState = states(0)?

  fun handleEvent(e: Event) =>
    let key : String = currentState.name() + e.name()
    try 
      let tr = transitionMap(key)?
      if currentState.name() != tr.target.name() then
        logger.log("input: " + key + " >>> state transition: "+currentState.name() + "->"+tr.target.name())
        currentState = tr.target
      else
        logger.log("input: " + key + " >>> no state transition, staying in: "+currentState.name())
      end
    else
      logger.log("input: " + key + "did not find this transition in the transition map: ")
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
    try 
      let turnstile:Fsm = Fsm.create(states, events, transitions, logger) ?
      turnstile.handleEvent(coinEvent)
      turnstile.handleEvent(pushEvent)
    end

use "collections"

interface Named 
  fun name(): String

interface State is Named
  """
  Anything that has a name can be used as a State
  """


interface Event is Named
  """
  Anything that has a name can be used as an Event
  """

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

  new create(states': Array[State], events': Array[Event], transitions': Array[Transition])
    states = states'
    events = events'
    transitions = transitions'




actor Main
  new create(env: Env) =>
    env.out.print("FSM has started")
    let lockedState = State("locked")
    let unlockedState = State("unlocked")

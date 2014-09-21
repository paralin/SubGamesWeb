window.vis = (->
  stateKey = undefined
  eventKey = undefined
  keys =
    hidden: "visibilitychange"
    webkitHidden: "webkitvisibilitychange"
    mozHidden: "mozvisibilitychange"
    msHidden: "msvisibilitychange"

  for stateKey of keys
    if stateKey of document
      eventKey = keys[stateKey]
      break
  (c) ->
    document.addEventListener eventKey, c  if c
    not document[stateKey]
)()

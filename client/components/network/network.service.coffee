'use strict'

class NetworkService
  disconnected: true
  doReconnect: true
  reconnTimeout: null
  attempts: 0
  status: "Disconnected from the server."

  streamers: []

  constructor: (@scope, @timeout, @safeApply)->
  disconnect: ->
    @doReconnect = false
    console.log "Disconnect called"
    if @conn?
      if @cont
        @cont.close()
      @conn.disconnect()
    if @reconnTimeout?
      @timeout.cancel(@reconnTimeout)
      @reconnTimeout = null
    @disconnected = true

  reconnect: ->
    if @doReconnect
      if !@reconnTimeout?
        @safeApply @scope, =>
          @disconnected = true
          @status = "Reconnecting in 3 seconds, attempt ##{@attempts}..."
        @reconnTimeout = @timeout(=>
          @reconnTimeout = null 
          @connect()
        , 3000)
    else
      console.log "Not reconnecting."

  methods:
    play:
      checkAuth: (serv)->
        @invoke("checkauth").then (items)->
          if !_.contains items, "play"
            serv.scope.$broadcast "invalidAuth"
            serv.disconnect()
  handlers: 
    play:
      onopen: ->
        @play.do.checkAuth(@)

  connect: ->
    @doReconnect = true
    if !@disconnected
      console.log 'Already connected.'
      return
    @attempts += 1
    #@disconnect()
    if !@server?
      console.log "No server info yet."
      @status = "Waiting for server info..."
    else
      @status = "Connecting to the network..."
      console.log "Connecting to #{@server}..."
      if !@conn?
        conts = _.keys @handlers
        @conn = new XSockets.WebSocket @server, conts, {token:@token}
      else
        @conn.reconnect()
      safeApply = @safeApply
      scope = @scope
      serv = @
      @conn.onconnected = =>
        console.log "Connected to the network!"
        if @reconnTimeout?
          @timeout.cancel(@reconnTimeout)
          @reconnTimeout = null
        safeApply scope, =>
          @disconnected = false
          @status = "Connected to the network."
          @attempts = 0
          return
        for name, cbs of @handlers
          @[name] = cont = @conn.controller name
          cont.onopen = (ci)->
            console.log "#{name} opened."
          for cbn, cb of cbs
            do (cbn, cb, cont, name) ->
              cont[cbn] = (arg)->
                console.log cbn
                console.log arg
                safeApply scope, -> 
                  cb.call serv, arg
        for name, cbs of @methods
          @[name] = cont = @conn.controller name
          cont.do = {}
          for cbn, cb of cbs
            do (cbn, cb, cont, name) ->
              cont.do[cbn] = (arg)->
                cb.call cont, arg
      @conn.ondisconnected = =>
        console.log "Disconnected from the network..."
        #@disconnect()
        @reconnect()

angular.module('subgamesApp').factory 'Network', ($rootScope, $timeout, Auth, safeApply) ->
  service = new NetworkService $rootScope, $timeout, safeApply
  Auth.getLoginStatus (currentUser, currentToken, currentServer)->
    service.token = currentToken
    service.server = currentServer
    #service.connect()
  $(window).unload ->
    service.disconnect()
  window.service = service

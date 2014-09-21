'use strict'

class NetworkService
  disconnected: true
  doReconnect: true
  reconnTimeout: null
  attempts: 0
  status: "Disconnected from the server."

  streamers: []
  activeStream: null
  activeGame: null

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
        @invoke("checkauth").then (items)=>
          serv.safeApply serv.scope, ->
            if !_.contains items, "play"
              serv.scope.$broadcast "invalidAuth"
              serv.disconnect()
      fetchStreamers: (serv, cb)->
        console.log arguments
        @invoke("getactivestreams").then (streams)=>
          serv.safeApply serv.scope, ->
            serv.streamers = streams
            cb(streams)
      registerWithStream: (serv, id, cb)->
        @invoke("registerwithstream", {id: id}).then (ok)=>
          serv.safeApply serv.scope, ->
            console.log ok
            cb ok if cb?
      unregisterStream: (serv)->
        @invoke("deregisterStream")

  handlers: 
    play:
      onopen: ->
        @play.do.checkAuth(@)
      publicstreamupd: (upd)->
        for stream in upd.streams
          strm = _.findIndex @streamers, {Id: stream.Id}
          if strm != -1
            @streamers[strm] = stream
          else
            @streamers.push stream
      publicstreamrm: (upd)->
        for strmid in upd.ids
          strm = _.findIndex @streamers, {Id: strmid}
          if strm != -1
            @streamers.splice strm, 1
      clearstream: ->
        @activeStream = null
        @scope.$broadcast "clearStream"
      streamsnapshot: (snp)->
        @activeStream = snp
        @scope.$broadcast "streamSnapshot", snp

  callWhenOpen: (name, cb)->
    cont = @[name]
    if !cont?
      console.log "CallWhenOpen called with invalid controller #{name}"
    else
      if cont.isOpen
        cb(@)
      else
        cont.openCbs.push cb

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
        do (cont) ->
          cont.openCbs = []
          cont.onopen = (ci)->
            console.log "#{name} opened."
            cont.isOpen = true
            for cb in cont.openCbs
              cb(ci)
            cont.openCbs = []
        for cbn, cb of cbs
          do (cbn, cb, cont, name) ->
            if cbn is "onopen"
              cont.openCbs.push (arg)->
                safeApply scope, -> 
                  cb.call serv, arg
            else
              cont[cbn] = (arg)->
                safeApply scope, -> 
                  cb.call serv, arg
      for name, cbs of @methods
        @[name] = cont = @conn.controller name
        cont.do = {}
        for cbn, cb of cbs
          do (cbn, cb, cont, name) ->
            cont.do[cbn] = ->
              args = [serv]
              for arg in arguments
                args.push arg 
              cb.apply cont, args
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

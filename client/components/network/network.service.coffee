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
  activeSearch: null
  activePerms: null
  activeParty: null
  activePlayerCount: 0
  activeFollowerCount: 0
  activeSubscriberCount: 0

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
    stream:
      unregister: (serv)->
        @invoke "unregister"
      swapPlayer: (serv, steamId)->
        @invoke "swapplayer", {SteamID: steamId}
      kickPlayer: (serv, steamId)->
        @invoke "kickplayer", {SteamID: steamId}
      confirmTeams: (serv)->
        @invoke "confirmteams"
      finalizeGame: (serv)->
        @invoke "finalizegame"
      setAllowQueue: (serv, allow)->
        @invoke "setallowqueue", {AllowQueue: allow}
      startUpdatePool: (serv, gameId )->
        @invoke("startupdatepool", {gameId: gameId}).then (err)->
          return if !err?
          new PNotify
            title: "Start Error"
            text: err
            type: "error"
          return
      startParty: (serv, reqFollow, reqSub)->
        @invoke("startparty", {RequireFollow: reqFollow, RequireSubscribe: reqSub})
      addPartyPlayer: (serv)->
        @invoke "addpartyplayer"
      kickPartyPlayer: (serv, plyrid)->
        @invoke "kickpartyplayer", {SteamID: plyrid}
      startGame: (serv, playerCount, reqFollow, reqSub, gameMode, region)->
        @invoke("startsearch", {PlayerCount: playerCount, RequireFollow: reqFollow, RequireSubscribe: reqSub, GameMode: gameMode, Region: region})
      cancelGame: (serv)->
        @invoke "stopsearch"
    play:
      checkAuth: (serv)->
        @invoke("checkauth").then (items)=>
          serv.safeApply serv.scope, ->
            if !_.contains items, "play"
              serv.scope.$broadcast "invalidAuth"
              serv.disconnect()
      getPerms: (serv, id, cb)->
        @invoke("getperms", {Id: id}).then (perms)=>
          serv.safeApply serv.scope, ->
            cb perms
      fetchPerms: (serv, id, cb)->
        @invoke("fetchperms", {Id: id}).then (err)=>
          serv.safeApply serv.scope, ->
            if !err?
              cb true
            else
              if err is "AUTHFAIL"
                cb false
              else
                new PNotify
                  title: "Issue Checking Follow/Subscribe"
                  text: err
                  type: "error"
                cb true
      fetchStreamers: (serv, cb)->
        @invoke("getactivestreams").then (streams)=>
          serv.safeApply serv.scope, ->
            serv.streamers = streams
            cb(streams)
      registerWithStream: (serv, id, cb)->
        @invoke("registerwithstream", {id: id}).then (status)=>
          serv.safeApply serv.scope, ->
            console.log status
            cb status if cb?
      unregisterStream: (serv)->
        @invoke("deregisterStream")
      acceptMatch: (serv, acc)->
        @invoke "acceptmatch", {accepted: acc}

  handlers: 
    stream:
      clearstream: ->
        @activeStream = null
        @scope.$broadcast "clearStream"
        @activeGame = null
        @activeParty = null
        @activeSearch = null
        @activePerms = null
        @activePlayerCount = 0
        @activeFollowerCount = 0
        @activeSubscriberCount = 0
      streamsnapshot: (snp)->
        @activeStream = snp
        @scope.$broadcast "streamSnapshot", snp
      playercountupd: (upd)->
        @activePlayerCount = upd.Players
        @activeFollowerCount = upd.Followers
        @activeSubscriberCount = upd.Subscribers
      searchsnapshot: (snp)->
        @activeSearch = snp
        @scope.$broadcast "searchSnapshot", snp
      clearsearch: ->
        @activeSearch = null
        @scope.$broadcast "clearSearch"
      setupsnapshot: (snp)->
        @activeGame = snp
        @scope.$broadcast "gameSnapshot", snp
      clearsetup: ->
        @activeGame = null
        @scope.$broadcast "clearGame"
      partysnapshot: (snp)->
        if !@activeParty? && snp?
          @scope.$broadcast "joinedParty", snp
        @activeParty = snp
        @scope.$broadcast "partySnapshot", snp
      clearparty: ->
        @activeParty = null
        @scope.$broadcast "clearParty"
    play:
      onopen: ->
        @activeStream = null
        @activeGame = null
        @activeParty = null
        @activeSearch = null
        @play.do.checkAuth(@)
      permssnapshot: (snap)->
        @activePerms = snap
      onlobbyready: ->
        @scope.$broadcast "lobbyReady"
      onkicked: ->
        swal
          title: "Kicked From Game"
          text: "You were kicked from the game by the streamer. Sorry!"
          type: "error"
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
      partysnapshot: (snp)->
        if !@activeParty? && snp?
          @scope.$broadcast "joinedParty", snp
        @activeParty = snp
        @scope.$broadcast "partySnapshot", snp
      clearparty: ->
        @activeParty = null
        @scope.$broadcast "clearParty"
      setupsnapshot: (snp)->
        @activeGame = snp
        @scope.$broadcast "gameSnapshot", snp
      clearsetup: ->
        @activeGame = null
        @scope.$broadcast "clearGame"
      searchsnapshot: (snp)->
        @activeSearch = snp
        @scope.$broadcast "searchSnapshot", snp
      clearsearch: ->
        @activeSearch = null
        @scope.$broadcast "clearSearch"

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
                console.log cbn
                console.log arg
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

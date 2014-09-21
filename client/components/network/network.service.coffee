'use strict'

class NetworkService
  disconnected: true
  doReconnect: true
  reconnTimeout: null
  attempts: 0
  status: "Disconnected from the server."

  activeMatch: null
  chats: []
  liveMatches: []
  availableGames: []

  constructor: (@scope, @timeout, @safeApply)->
  disconnect: ->
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
    matches:
      leavematch: ->
        (@invoke "leavematch").then (err)->
          return if !err?
          new PNotify
            title: "Leave Error"
            text: err
            type: "error"
          return
      creatematch: (options)->
        @invoke("creatematch", options).then (err)->
          return if !err?
          new PNotify
            title: "Can't Create Match"
            text: err
            type: "error"
          return
      joinmatch: (options)->
        @invoke("joinmatch", options).then (err)->
          return if !err?
          new PNotify
            title: "Can't Join Match"
            text: err
            type: "error"
          return
      switchteam: ->
        @invoke("switchteam").then (err)->
          return if !err?
          new PNotify
            title: "Can't Switch Teams"
            text: err
            type: "error"
          return
  handlers: 
    matches:
      matchsnapshot: (match)->
        console.log "Received active match snapshot #{match}"
        @activeMatch = match
      matchplayerupd: (upd)->
        console.log "Received match player add/update"
        #find the match
        mtchs = []
        match = _.find @availableGames, {Id: upd.Id}
        mtchs[mtchs.length] = match if match?
        mtchs[mtchs.length] = @activeMatch if @activeMatch? and @activeMatch.Id is upd.Id
        if mtchs.length is 0
          console.log "Received match player add/update for an unknown match #{upd.Id}"
        for match in mtchs
          for plyr in upd.players
            plyrIdx = _.findIndex match.Players, {SID: plyr.SID}
            if plyrIdx isnt -1
              match.Players[plyrIdx] = plyr
            else
              match.Players[match.Players.length] = plyr
      matchplayerrm: (upd)->
        console.log "Received match player rm"
        #find the match
        mtchs = []
        match = _.find @availableGames, {Id: upd.Id}
        mtchs[mtchs.length] = match if match?
        mtchs[mtchs.length] = @activeMatch if @activeMatch? && @activeMatch.Id is upd.Id
        if mtchs.length is 0
          console.log "Received match player remove for an unknown match #{upd.Id}"
        for match in mtchs
          for id in upd.ids
            plyrIdx = _.findIndex match.Players, {SID: id}
            if plyrIdx isnt -1
              match.Players.splice plyrIdx, 1
      publicmatchupd: (upd)->
        console.log "Received public match add/update"
        for match in upd.matches
          idx = _.findIndex @liveMatches, {Id: match.Id}
          if idx isnt -1
            @liveMatches[idx] = match
          else
            @liveMatches[@liveMatches.length] = match
      publicmatchrm: (upd)->
        console.log "Received public match rm"
        for id in upd.ids
          idx = _.findIndex @liveMatches, {Id: id}
          if idx isnt -1
            @liveMatches.splice idx, 1
      availablegameupd: (upd)->
        console.log "Received available game add/update"
        for match in upd.matches
          idx = _.findIndex @availableGames, {Id: match.Id}
          if idx isnt -1
            @availableGames[idx] = match
          else
            @availableGames[@availableGames.length] = match
      availablegamerm: (upd)->
        console.log "Received available game rm"
        for id in upd.ids
          idx = _.findIndex @availableGames, {Id: id}
          if idx isnt -1
            @availableGames.splice idx, 1
    chat:
      onopen: (ci)->
        @chat.invoke('authinfo').then (auths)=>
          if auths.length is 0
            @status = "Authentication failed. Try signing out and back in."
            @disconnected = true
            @doReconnect = false
            @disconnect() 
          else
            console.log "Authenticated with auth groups #{auths}"
            @chat.invoke('joinorcreate', {Name: "main"})
            @fetchMatches()
      onchatmessage: (upd)->
        chat = @chatByID upd.Id
        if !chat?
          console.log "Message for unknown chat #{upd.Id}"
        else
          chat.messages.push
            member: upd.Member.ID
            msg: upd.Text
            name: chat.Members[upd.Member.ID].Name
      #add or remove a chat channel
      chatchannelupd: (upd)->
        for chan in upd.channels
          console.log "chat add/update"
          console.log chan
          #get idx in array
          idx = _.findIndex @chats, {Id: chan.Id}
          if idx is -1
            chan.messages = []
            @chats.push chan
          else
            _.merge @chats[idx], chan
        @scope.$broadcast 'chatMembersUpd'
      chatchannelrm: (upd)->
        console.log "removed chats: #{JSON.stringify upd.ids}"
        for id in upd.ids
          idx = _.findIndex @chats, {Id: id}
          @chats.splice idx, 1 if idx > -1
          return
        @scope.$broadcast 'chatMembersUpd'
      #add or remove a chat member
      chatmemberupd: (upd)->
        chat = @chatByID upd.id
        if !chat?
          console.log "WARN -> chat member(s) added to unknown chat"
          console.log upd
        else
          for memb in upd.members
            chat.Members[memb.ID] = memb
        @scope.$broadcast 'chatMembersUpd'
      chatmemberrm: (upd)->
        chat = @chatByID upd.id
        if !chat?
          console.log "WARN -> chat member(s) removed from unknown chat"
          console.log upd
        else
          for memb in upd.members
            delete chat.Members[memb]
        @scope.$broadcast 'chatMembersUpd'

  connect: ->
    console.log 'connect() called'
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
          @chats.length = 0
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

  chatByID: (id)->
    _.find @chats, {Id: id}
  fetchMatches: ->
    #return
    console.log "Fetching matches"
    @matches.invoke('getpublicgamelist').then (ms)=>
      console.log "Received public match list"
      @safeApply @scope, =>
        @liveMatches.length = 0
        for game in ms
          @liveMatches[@liveMatches.length] = game
      @matches.invoke('getavailablegamelist').then (ms)=>
        console.log "Received available match list"
        @safeApply @scope, =>
          #use the same array
          @availableGames.length = 0
          for game in ms
            @availableGames[@availableGames.length] = game

angular.module('webleagueApp').factory 'Network', ($rootScope, $timeout, Auth, safeApply) ->
  service = new NetworkService $rootScope, $timeout, safeApply
  Auth.getLoginStatus (currentUser, currentToken, currentServer)->
    service.token = currentToken
    service.server = currentServer
    service.connect()
  $(window).unload ->
    service.disconnect()
  window.service = service

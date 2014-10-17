'use strict'

angular.module 'subgamesApp'
.controller 'SpanelCtrl', ($scope, Network, Auth, safeApply, $location, $rootScope) ->
  window.scope = $scope
  c = []
  Auth.getLoginStatus (u)->
    if !u? || !_.contains u.authItems, "streamer"
      $location.url "/streamer"
    else
      Network.connect()
  c.push $rootScope.$on "invalidAuth", ->
    safeApply $rootScope, ->
      $location.url "/l"
  $scope.network = Network
  $scope.selectedGame = $rootScope.GameTypeSel[0]
  $scope.selectedGameMode = $rootScope.GameModeNA[0]
  $scope.range = (min, max, step) ->
    step = step or 1
    input = []
    i = min
    while i <= max
      input.push i
      i += step
    input
  $scope.openParty = ->
    Network.stream.do.startParty $scope.gameParams.reqFollow, $scope.gameParams.reqSub
  $scope.closePool = ->
    Network.stream.do.unregister()
  $scope.openPool = ->
    Network.stream.do.startUpdatePool($scope.selectedGame.id)
  $scope.overlayMessage = ->
    "Connecting to the network..."
  $scope.showOverlay = ->
    Network.disconnected
  $scope.startLobby = ->
    Network.stream.do.startLobby $scope.gameParams.reqFollow, $scope.gameParams.reqSub, $scope.gameParams.selectedGameMode.id, $scope.gameParams.selectedRegion.id
  $scope.allPlayers = (query)->
    j = Network.activeLobby.Players
    j = _.filter j, query if query?
    j
  $scope.gameParams = 
    reqFollow: false
    reqSub: false
    selectedGameMode: null
    playerCount: 9
    selectedRegion: $rootScope.RegionSel[0]
  $scope.swapPlayer = (player)->
    Network.stream.do.swapPlayer player.SID
  $scope.kickPlayer = (player)->
    Network.stream.do.kickLobbyPlayer player.SID
  $scope.confirmTeams = ->
    Network.stream.do.confirmTeams()
  $scope.cancelLobby = ->
    Network.stream.do.cancelLobby()
  $scope.cancelParty = ->
    Network.stream.do.cancelParty()
  $scope.finalizeParty = ->
    Network.stream.do.finalizeParty()
  $scope.finalizeLobby = ->
    Network.stream.do.finalizeLobby()
  $scope.allReady = ->
    return false if !Network.activeGame
    for plyr in Network.activeGame.Details.Players
      return false if !plyr.Ready
    return true
  $scope.$on "$destroy", ->
    if !Network.disconnected
      Network.stream.do.unregister()
    for ub in c
      ub()

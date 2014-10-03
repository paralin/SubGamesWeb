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
  $scope.closePool = ->
    Network.stream.do.unregister()
  $scope.openPool = ->
    Network.stream.do.startUpdatePool($scope.selectedGame.id)
  $scope.overlayMessage = ->
    "Connecting to the network..."
  $scope.showOverlay = ->
    Network.disconnected
  $scope.findGame = ->
    Network.stream.do.startGame $scope.gameParams.playerCount, $scope.gameParams.reqFollow, $scope.gameParams.reqSub, $scope.gameParams.selectedGameMode.id, $scope.gameParams.selectedRegion
  $scope.allPlayers = (query)->
    j = null
    if Network.activeGame?
      j = Network.activeGame.Details.Players
    else if Network.activeSearch?
      j = _.union Network.activeSearch.Players, Network.activeSearch.PotentialPlayers
    else
      return []
    j = _.filter j, query if query?
    j
  $scope.gameParams = 
    reqFollow: false
    reqSub: false
    selectedGameMode: null
    playerCount: 9
    selectedRegion: 0
  $scope.swapPlayer = (player)->
    Network.stream.do.swapPlayer player.SID
  $scope.kickPlayer = (player)->
    Network.stream.do.kickPlayer player.SID
  $scope.confirmTeams = ->
    Network.stream.do.confirmTeams()
  $scope.cancelGame = ->
    Network.stream.do.cancelGame()
  $scope.finalizeGame = ->
    Network.stream.do.finalizeGame()
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

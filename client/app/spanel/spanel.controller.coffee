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
    Network.stream.do.startUpdatePool($scope.reqFollow, $scope.reqSub, $scope.selectedGame.id, $scope.selectedGameMode.id)
  $scope.overlayMessage = ->
    "Connecting to the network..."
  $scope.showOverlay = ->
    Network.disconnected
  $scope.findGame = ->
    bootbox.dialog
      message: "Number of players: <input type='number' id='player_count' value='9' min='1' max='9'></input>"
      title: "Match Setup"
      buttons:
        cancel:
          label: "Cancel"
          className: ""
          callback: ->
        main:
          label: "Start"
          className: "btn-primary"
          callback: ->
            count = parseInt $('#player_count').val()
            count = 9 if count > 9
            count = 1 if count < 1
            Network.stream.do.startGame(count)
    return
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

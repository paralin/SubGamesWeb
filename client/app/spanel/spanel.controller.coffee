'use strict'

angular.module 'subgamesApp'
.controller 'SpanelCtrl', ($scope, Network, Auth, safeApply, $location, $rootScope) ->
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
  $scope.closePool = ->
    Network.stream.do.unregister()
  $scope.openPool = ->
    Network.stream.do.startUpdatePool($("#reqFollow").is(":checked"), $("#reqSub").is(":checked"))
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
  $scope.cancelGame = ->
    Network.stream.do.cancelGame()
  $scope.$on "$destroy", ->
    if !Network.disconnected
      Network.stream.do.unregister()
    for ub in c
      ub()

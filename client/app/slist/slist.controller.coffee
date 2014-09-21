'use strict'

angular.module 'subgamesApp'
.controller 'SlistCtrl', ($scope, Network, $rootScope, $location, safeApply, Auth) ->
  c=[]
  $scope.goToLink = ->
    $location.url "/l"
  $scope.network = Network
  $scope.streamersFetched = false
  $scope.selectStreamer = (strm)->
    $location.url "/p/"+strm.name
  $scope.overlayMessage = ->
    if Network.disconnected
      return "Connecting to the network..."
    else
      return "Fetching streamer list..."
  $scope.showOverlay = ->
    Network.disconnected || !$scope.streamersFetched
  Auth.getLoginStatus (u)->
    Network.connect()
    Network.callWhenOpen "play", ->
      Network.play.do.fetchStreamers (streams)->
        $scope.streamersFetched = true
    Network.callWhenOpen "play", ->
      Network.play.do.unregisterStream()
  c.push $rootScope.$on "invalidAuth", ->
    safeApply $rootScope, ->
      $location.url "/l"
  $scope.$on "$destroy", ->
    for ub in c
      ub()

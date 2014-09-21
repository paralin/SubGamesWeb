'use strict'

angular.module 'subgamesApp'
.controller 'PlayCtrl', ($scope, Network, $rootScope, $location, $stateParams, safeApply, Auth, Streamer) ->
  c=[]
  $scope.network = Network
  $scope.goToLink = ->
    $location.url "/sl"
  $scope.overlayMessage = ->
    if Network.disconnected
      return "Connecting to the network..."
    else
      return "Joining #{$stateParams.streamer}'s pool..."
  $scope.showOverlay = ->
    Network.disconnected or !Network.activeStream?
  if $stateParams.streamer?
    Auth.getLoginStatus (u)->
      Network.connect()
      Network.callWhenOpen "play", ->
        Network.play.do.fetchStreamers (streams)->
          strm = _.find(streams, {name: $stateParams.streamer})
          if !strm?
            $location.url "/sl"
          else
            Network.play.do.registerWithStream strm.Id, (ok)->
              $location.url "/sl" if !ok
  else
    $location.url "/sl"
  c.push $rootScope.$on "invalidAuth", ->
    safeApply $rootScope, ->
      if $stateParams.streamer?
        $location.url "/l/"+$stateParams.streamer
      else
        $location.url "/l"
  c.push $rootScope.$on "clearStream", ->
    safeApply $rootScope, ->
      $location.url "/l"
  $scope.$on "$destroy", ->
    if !Network.disconnected
      Network.play.do.unregisterStream()
    for ub in c
      ub()

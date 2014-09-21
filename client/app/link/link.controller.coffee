'use strict'

angular.module 'subgamesApp'
.controller 'LinkCtrl', ($scope, Auth, Streamer, $stateParams, $cookieStore, $location, Network) ->
  Network.disconnect()
  $scope.steamSignin = ->
    $cookieStore.put("authReturn", $location.url())
    window.location.href = "/auth/steam"
  $scope.getStarted = ->
    Auth.getLoginStatus (u)->
      if u?
        if $stateParams.streamer?
          $location.url "/p/"+$stateParams.streamer
        else
          $location.url "/sl"
  $scope.twitchSignin = ->
    $cookieStore.put("authReturn", $location.url())
    window.location.href = "/auth/twitchtv"
  if $stateParams.streamer?
    Streamer.get({id: $stateParams.streamer}, (data)->
      $scope.streamer = data
    , (err)->
      console.log err
    )
  $scope.auth = Auth

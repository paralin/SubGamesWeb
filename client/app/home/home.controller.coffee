'use strict'

angular.module 'subgamesApp'
.controller 'HomeCtrl', ($scope, Auth) ->
  $scope.steamSignin = ->
    window.location.href = "/auth/steam"
  $scope.twitchSignin = ->
    window.location.href = "/auth/twitchtv"
  $scope.auth = Auth

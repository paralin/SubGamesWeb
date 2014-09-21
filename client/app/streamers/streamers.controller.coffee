'use strict'

angular.module 'subgamesApp'
.controller 'StreamersCtrl', ($scope, Auth, $http, $location) ->
  $scope.hasRequestedSlot = ->
    Auth.currentUser && _.contains auth.currentUser.authItems, "subRequest"
  $scope.doRequest = ->
    Auth.currentUser.authItems.push "subRequest"
    $http.post "/api/users/requestSubSlot"
  $scope.goToLink = ->
    $location.url "/l"

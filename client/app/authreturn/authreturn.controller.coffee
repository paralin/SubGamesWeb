'use strict'

angular.module 'subgamesApp'
.controller 'AuthreturnCtrl', ($cookieStore, $location) ->
  path = $cookieStore.get "authReturn"
  if path?
    $location.url path
  else
    $location.url "/l"

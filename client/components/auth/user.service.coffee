'use strict'

angular.module('subgamesApp').factory 'User', ($resource) ->
  $resource '/api/users/status', {},
    get:
      method: 'GET'
      cache: false

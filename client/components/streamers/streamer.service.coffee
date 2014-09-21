'use strict'

angular.module('subgamesApp').factory 'Streamer', ($resource) ->
  $resource '/api/streamers/:id', {id: undefined},
    get:
      method: 'GET'
      cache: false
    getList:
      method: 'GET'
      cache: false
      isArray: true

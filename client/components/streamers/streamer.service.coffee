'use strict'

angular.module('subgamesApp').factory 'Streamer', ($resource) ->
  $resource '/api/streamers/:id', {paramDefaults: {id: ""}},
    get:
      method: 'GET'
      cache: false

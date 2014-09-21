'use strict'

angular.module('subgamesApp').factory 'Auth', ($location, $rootScope, $http, User, $interval, $q) ->
  service =
    currentPromise: null
    currentUser: null
    currentToken: null
    currentServer: null
    user: User
    getLoginStatus: (cb)->
      if @currentPromise?
        @currentPromise.then =>
          cb(@currentUser, @currentToken, @currentServer)
      else
        cb(@currentUser, @currentToken, @currentServer)
    logout: ->
      $http.get('/auth/logout').success ->
        service.update()
    disconnectSteam: ->
      $http.get('/auth/steam/disconnect').success ->
        service.update()
    disconnectTwitch: ->
      $http.get('/auth/twitchtv/disconnect').success ->
        service.update()
    update: ->
      deferred = $q.defer()
      @currentPromise = deferred.promise
      data = User.get =>
        if data.isAuthed
          data.user.steam = undefined if _.isEmpty data.user.steam
          data.user.twitchtv = undefined if _.isEmpty data.user.twitchtv
          @currentUser = data.user
          @currentToken = data.token
          @currentServer = data.server
        else
          @currentUser = null
          @currentToken = null
          @currentServer = null
        @currentPromise = null
        deferred.resolve()
      @currentPromise
  $interval =>
    service.update()
  , 30000
  service.update()
  window.auth = service
  service

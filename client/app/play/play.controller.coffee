'use strict'

foundSound = new buzz.sound "/assets/sounds/match_ready.wav"

angular.module 'subgamesApp'
.controller 'PlayCtrl', ($scope, Network, $rootScope, $location, $stateParams, safeApply, Auth, Streamer, $cookieStore) ->
  c=[]
  $scope.network = Network
  $scope.goToLink = ->
    $location.url "/sl"
  $scope.joinStatus = "Please refresh the page."
  $scope.overlayMessage = ->
    if Network.disconnected
      return "Connecting to the network..."
    else
      return $scope.joinStatus
  $scope.playerCount = 9
  $scope.getTeam = ->
    return -1 if !Network.activeGame?
    plyr = _.find Network.activeGame.Details.Players, {SID: Auth.currentUser.steam.steamid}
    if plyr?
      return plyr.Team
    else return -1
  $scope.getReady = ->
    return false if !Network.activeGame?
    plyr = _.find Network.activeGame.Details.Players, {SID: Auth.currentUser.steam.steamid}
    if plyr?
      return plyr.Ready
    return false
  $scope.showOverlay = ->
    Network.disconnected or !Network.activeStream?
  if $stateParams.streamer?
    Auth.getLoginStatus (u)->
      Network.connect()
      Network.callWhenOpen "play", ->
        $scope.joinStatus = "Finding stream..."
        Network.play.do.fetchStreamers (streams)->
          $scope.joinStatus = "Checking Twitch subscriber list..."
          strm = _.find(streams, {name: $stateParams.streamer})
          if !strm?
            $location.url "/sl"
          else
            Network.play.do.fetchPerms strm.Id, (ok)->
              $scope.joinStatus = "Getting your subscriber status..."
              if !ok
                $cookieStore.put "authReturn", $location.url()
                window.location.href = "/auth/twitchtv"
              else
                Network.play.do.getPerms strm.Id, (perms)->
                  $scope.joinStatus = "Joining #{$stateParams.streamer}'s pool...'"
                  $scope.perms = perms
                  Network.play.do.registerWithStream strm.Id, (ok)->
                    $scope.joinStatus = "Please refresh the page."
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
  queried = false
  c.push $rootScope.$on "searchSnapshot", ->
    idx = _.findIndex Network.activeSearch.PotentialPlayers, {SID: Auth.currentUser.steam.steamid}
    return if queried || idx is -1
    queried = true
    foundSound.play()
    bootbox.confirm "You have been selected for the next game, do you accept?", (c)->
      if c
        Network.play.do.acceptMatch(true)
      else
        Network.play.do.acceptMatch(false)
    return
  c.push $rootScope.$on "clearSearch", ->
    queried = false
    return
  $scope.$on "$destroy", ->
    if !Network.disconnected
      Network.play.do.unregisterStream()
    for ub in c
      ub()

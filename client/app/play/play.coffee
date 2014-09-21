'use strict'

angular.module 'subgamesApp'
.config ($stateProvider) ->
  $stateProvider.state 'play_streamer',
    url: '/p/:streamer'
    templateUrl: 'app/play/play.html'
    controller: 'PlayCtrl'
    authenticate: true

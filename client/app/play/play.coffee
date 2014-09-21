'use strict'

angular.module 'subgamesApp'
.config ($stateProvider) ->
  $stateProvider.state 'play',
    url: '/p'
    templateUrl: 'app/play/play.html'
    controller: 'PlayCtrl'
    authenticate: true
  $stateProvider.state 'play_streamer',
    url: '/p/:streamer'
    templateUrl: 'app/play/play.html'
    controller: 'PlayCtrl'
    authenticate: true

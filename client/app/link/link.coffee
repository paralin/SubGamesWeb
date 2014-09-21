'use strict'

angular.module 'subgamesApp'
.config ($stateProvider) ->
  $stateProvider.state 'link_streamer',
    url: '/l/:streamer'
    templateUrl: 'app/link/link.html'
    controller: 'LinkCtrl'
  $stateProvider.state 'link',
    url: '/l'
    templateUrl: 'app/link/link.html'
    controller: 'LinkCtrl'

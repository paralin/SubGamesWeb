'use strict'

angular.module 'subgamesApp'
.config ($stateProvider) ->
  $stateProvider.state 'streamers',
    url: '/streamers'
    templateUrl: 'app/streamers/streamers.html'
    controller: 'StreamersCtrl'
    authenticate: true

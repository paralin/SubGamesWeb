'use strict'

angular.module 'subgamesApp'
.config ($stateProvider) ->
  $stateProvider.state 'streamerlist',
    url: '/sl'
    templateUrl: 'app/slist/slist.html'
    controller: 'SlistCtrl'
    authenticate: true

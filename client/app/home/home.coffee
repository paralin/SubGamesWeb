'use strict'

angular.module 'subgamesApp'
.config ($stateProvider) ->
  $stateProvider.state 'home',
    url: '/'
    templateUrl: 'app/home/home.html'
    controller: 'HomeCtrl'

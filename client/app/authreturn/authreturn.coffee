'use strict'

angular.module 'subgamesApp'
.config ($stateProvider) ->
  $stateProvider.state 'authreturn',
    url: '/authreturn'
    controller: 'AuthreturnCtrl'

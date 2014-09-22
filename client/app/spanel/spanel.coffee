'use strict'

angular.module 'subgamesApp'
.config ($stateProvider) ->
  $stateProvider.state 'spanel',
    url: '/st'
    templateUrl: 'app/spanel/spanel.html'
    controller: 'SpanelCtrl'

'use strict'

angular.module 'subgamesApp'
.directive 'connectoverlay', ->
  templateUrl: 'components/connectoverlay/connectoverlay.html'
  restrict: 'A'
  link: (scope, element, attrs) ->
    scope.show = true
    attrs.$observe 'connectoverlay', (val)->
      scope.show = JSON.parse(val)

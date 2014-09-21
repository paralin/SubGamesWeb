'use strict'

angular.module 'subgamesApp'
.directive 'connectoverlay', ->
  templateUrl: 'components/connectoverlay/connectoverlay.html'
  restrict: 'A'
  link: (scope, element, attrs) ->
    scope.show = true
    scope.message = "Connecting to the network..."
    attrs.$observe 'connectoverlay', (val)->
      scope.show = JSON.parse(val)
    attrs.$observe 'message', (val)->
      scope.message = val

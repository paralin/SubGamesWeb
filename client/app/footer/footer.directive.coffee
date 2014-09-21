'use strict'

angular.module 'subgamesApp'
.directive 'footer', ->
  templateUrl: 'app/footer/footer.html'
  restrict: 'EA'
  link: (scope, element, attrs) ->

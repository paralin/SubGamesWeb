'use strict'

angular.module 'subgamesApp'
.directive 'footer', (Network)->
  templateUrl: 'app/footer/footer.html'
  restrict: 'EA'
  link: (scope, element, attrs) ->
    scope.network = Network

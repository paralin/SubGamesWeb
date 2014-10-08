'use strict'

angular.module 'subgamesApp'
.filter 'range', ->
  (input, total) ->
    total = parseInt(total)
    i = 0
    while i < total
      input.push i
      i++
    input


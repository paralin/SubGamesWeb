'use strict'

describe 'Filter: range', ->

  # load the filter's module
  beforeEach module 'subgamesApp'

  # initialize a new instance of the filter before each test
  range = undefined
  beforeEach inject ($filter) ->
    range = $filter 'range'

  it 'should return the input prefixed with \'range filter:\'', ->
    text = 'angularjs'
    expect(range text).toBe 'range filter: ' + text

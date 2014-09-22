'use strict'

describe 'Controller: SpanelCtrl', ->

  # load the controller's module
  beforeEach module 'subgamesApp'
  SpanelCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    SpanelCtrl = $controller 'SpanelCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1

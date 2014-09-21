'use strict'

describe 'Controller: HomeCtrl', ->

  # load the controller's module
  beforeEach module 'subgamesApp'
  HomeCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    HomeCtrl = $controller 'HomeCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1

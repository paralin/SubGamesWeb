'use strict'

describe 'Directive: footer', ->

  # load the directive's module and view
  beforeEach module 'subgamesApp'
  beforeEach module 'app/footer/footer.html'
  element = undefined
  scope = undefined
  beforeEach inject ($rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<footer></footer>'
    element = $compile(element) scope
    scope.$apply()
    expect(element.text()).toBe 'this is the footer directive'


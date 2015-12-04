describe 'app', ->
  beforeEach module 'app'

  describe 'controllers', ->
    beforeEach module 'controllers'

    describe 'calcController', ->
      beforeEach inject ($controller, $rootScope, $location) ->
        @scope = $rootScope.$new()
        @calcController = $controller 'calcController',
          $scope: @scope
        #console.log "add: #{@calcController}"

      it 'calcController should be defined', ->
        expect @calcController
          .toBeDefined

      it 'scope should be defined', ->
        expect @scope
          .toBeDefined

      it 'should add correctly', ->
        expect @scope.add 1, 2
          .toBe 3

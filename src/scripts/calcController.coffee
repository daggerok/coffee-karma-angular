angular.module('controllers', [])
  .controller 'calcController', [
    '$scope'
    ($scope) ->
      $scope.add = (a, b) ->
        a + b
  ]

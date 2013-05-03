(function() {
  angular.module("angular-bacon", []).run([
    "$rootScope", function($rootScope) {
      $rootScope.$watchAsStream = function(watchExp, objectEquality) {
        var bus;

        bus = new Bacon.Bus;
        this.$watch(watchExp, function(newValue) {
          return bus.push(newValue);
        }, objectEquality);
        return bus;
      };
      $rootScope.digestStreams = function(streams) {
        var self;

        self = this;
        return angular.forEach(streams, function(stream, key) {
          return stream.digest(self, key);
        });
      };
      return Bacon.Observable.prototype.digest = function($scope, prop) {
        return this.onValue(function(val) {
          if (!$scope.$$phase) {
            return $scope.$apply(function() {
              return $scope[prop] = val;
            });
          } else {
            return $scope[prop] = val;
          }
        });
      };
    }
  ]);

}).call(this);

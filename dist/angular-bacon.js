(function() {
  angular.module("angular-bacon", []).run([
    "$rootScope", "$parse", function($rootScope, $parse) {
      var watcherBus;
      watcherBus = function(scope, watchExp, objectEquality, watchMethod) {
        var bus, initialValue;
        bus = new Bacon.Bus;
        scope[watchMethod](watchExp, function(newValue) {
          return bus.push(newValue);
        }, objectEquality);
        scope.$on('$destroy', bus.end);
        initialValue = scope.$eval(watchExp);
        if (typeof initialValue !== "undefined") {
          return bus.toProperty(initialValue);
        } else {
          return bus.toProperty();
        }
      };
      $rootScope.__proto__.$watchAsProperty = function(watchExp, objectEquality) {
        return watcherBus(this, watchExp, objectEquality, '$watch');
      };
      $rootScope.__proto__.$watchCollectionAsProperty = function(watchExp, objectEquality) {
        return watcherBus(this, watchExp, objectEquality, '$watchCollection');
      };
      $rootScope.__proto__.digestObservables = function(observables) {
        var self;
        self = this;
        return angular.forEach(observables, function(observable, key) {
          return observable.digest(self, key);
        });
      };
      return Bacon.Observable.prototype.digest = function($scope, prop) {
        var propSetter, unsubscribe;
        propSetter = $parse(prop).assign;
        unsubscribe = this.subscribe(function(e) {
          if (e.hasValue()) {
            if (!$scope.$$phase) {
              return $scope.$apply(function() {
                return propSetter($scope, e.value());
              });
            } else {
              return propSetter($scope, e.value());
            }
          }
        });
        $scope.$on('$destroy', unsubscribe);
        return this;
      };
    }
  ]);

}).call(this);

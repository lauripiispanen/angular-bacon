angular
    .module("angular-bacon", [])
    .run ["$rootScope", "$parse", ($rootScope, $parse) ->
        $rootScope.$watchAsProperty = (watchExp, objectEquality) ->
            bus = new Bacon.Bus
            this.$watch watchExp, (newValue) ->
                bus.push newValue
            , objectEquality
            this.$on '$destroy', bus.end
            initialValue = this.$eval(watchExp)
            if typeof initialValue != "undefined"
                bus.toProperty(initialValue)
            else
                bus.toProperty()

        $rootScope.digestObservables = (observables) ->
            self = this
            angular.forEach observables, (observable, key) ->
                observable.digest self, key

        Bacon.Observable.prototype.digest = ($scope, prop) ->
            propSetter = $parse(prop).assign
            unsubscribe = this.subscribe (e) ->
                if (e.hasValue())
                    if(!$scope.$$phase)
                        $scope.$apply ->
                            propSetter($scope, e.value())
                    else
                        propSetter($scope, e.value())

            $scope.$on '$destroy', unsubscribe
            this

    ]
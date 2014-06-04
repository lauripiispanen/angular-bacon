angular
    .module("angular-bacon", [])
    .run ["$rootScope", "$parse", ($rootScope, $parse) ->
        watcherBus = (scope, watchExp, objectEquality, watchMethod) ->
            bus = new Bacon.Bus
            scope[watchMethod] watchExp, (newValue) ->
                bus.push newValue
            , objectEquality
            scope.$on '$destroy', bus.end
            initialValue = scope.$eval(watchExp)
            if typeof initialValue != "undefined"
                bus.toProperty(initialValue)
            else
                bus.toProperty()


        $rootScope.$watchAsProperty = (watchExp, objectEquality) ->
            watcherBus this, watchExp, objectEquality, '$watch'

        $rootScope.$watchCollectionAsProperty = (watchExp, objectEquality) ->
            watcherBus this, watchExp, objectEquality, '$watchCollection'

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

        $rootScope.$asEventStream = (event, names) ->
            $scope = this;
            Bacon.fromBinder (sink) ->
                end = $scope.$on event, (event) ->
                    if names 
                    then event.args = Bacon._.object names, Array.prototype.slice.call(arguments, 1)
                    else event.args = Array.prototype.slice.call(arguments, 1)

                    ret = sink(event);
                    if (ret == Bacon.noMore)
                        end()

                $scope.$on '$destroy', () ->
                    sink new Bacon.End()

                end
    ]

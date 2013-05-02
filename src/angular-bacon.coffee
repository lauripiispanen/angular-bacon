angular
    .module("angular-bacon", [])
    .run ["$rootScope", ($rootScope) ->
        $rootScope.$watchAsStream = (watchExp, objectEquality) ->
            bus = new Bacon.Bus
            this.$watch watchExp, (newValue) ->
                bus.push newValue
            , objectEquality
            bus

        $rootScope.digestStreams = (streams) ->
            self = this
            angular.forEach streams, (stream, key) ->
                stream.digest self, key

        Bacon.Observable.prototype.digest = ($scope, prop) ->
            this.onValue (val) ->
                if(!$scope.$$phase)
                    $scope.$apply () ->
                        $scope[prop] = val
                else
                    $scope[prop] = val
    ]
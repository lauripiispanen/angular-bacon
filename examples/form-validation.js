angular.
    module('example', ['angular-bacon']).
    controller('form', function($scope) {
        $scope.username = ''

        var atLeast = function(num) {
            return function(it) {
                return it && it.length > num;
            }
        }
        var passwordsEqual =
            $scope
                .$watchAsStream('password')
                .filter(atLeast(2))
                .combine(
                    $scope.$watchAsStream('passwordConfirm').filter(atLeast(2)),
                    function(pass, confirm) {
                        return {
                            password: pass,
                            confirm: confirm
                        }
                    }
                )
                .map(function(it) {
                    return it.password === it.confirm
                })

        var usernameInput = $scope
            .$watchAsStream('username')

        var usernameIsFree = usernameInput
            .filter(function(it) { return it.length > 2 })
            .flatMapLatest(function(it) { return Bacon.later(2000, it === "user"); })
            .merge(usernameInput.map(false))
            .toProperty()

        usernameIsFree.and(passwordsEqual).digest($scope, 'formValid')
    })

beforeEach module 'angular-bacon'

describe "rootScope", ->
    it "gets augmented", ->
        inject ($rootScope) ->
            expect(typeof $rootScope.$watchAsProperty).toEqual 'function'

    it "can create properties out of watch expressions", ->
        inject ($rootScope) ->
            $rootScope.foo = true
            values = []
            $rootScope.$watchAsProperty('foo').onValue (val) ->
                values.push val

            $rootScope.$apply ->
                $rootScope.foo = 'bar'

            expect(values[0]).toEqual true
            expect(values[1]).toEqual 'bar'

    it "will not push an initial value if one isn't defined", ->
        inject ($rootScope) ->
            values = []
            $rootScope.$watchAsProperty('foo').onValue (val) ->
                values.push val

            $rootScope.$apply ->
                $rootScope.foo = 'bar'

            expect(values[0]).toEqual 'bar'


    it "can digest observables back to scope", ->
        inject ($rootScope) ->
            bus = new Bacon.Bus

            bus.digest $rootScope, 'foo'

            expect($rootScope.foo).toBeUndefined()

            bus.push 'bar'

            expect($rootScope.foo).toEqual 'bar'

    it "can digest even if $apply already in process", ->
        inject ($rootScope) ->
            bus = new Bacon.Bus
            bus.digest $rootScope, 'foo'
            $rootScope.$apply ->
                bus.push 'bar'
            expect($rootScope.foo).toEqual 'bar'


    it "can digest multiple observables at once", ->
        inject ($rootScope) ->
            bus = new Bacon.Bus
            bus2 = new Bacon.Bus
            bus3 = new Bacon.Bus

            $rootScope.digestObservables 
                first: bus
                second: bus2
                third: bus3

            bus.push 'foo'
            bus2.push 'bar'

            expect($rootScope.first).toEqual 'foo'
            expect($rootScope.second).toEqual 'bar'
            expect($rootScope.third).toBeUndefined()

    it "can digest on deeply nested properties of $scope", ->
        inject ($rootScope) ->
            bus = new Bacon.Bus

            bus.digest $rootScope, 'foo.baz'

            expect($rootScope.foo).toBeUndefined()

            bus.push 'bar'

            expect($rootScope.foo.baz).toEqual 'bar'


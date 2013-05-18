beforeEach module 'angular-bacon'

describe "rootScope", ->
    it "gets augmented", ->
        inject ($rootScope) ->
            expect(typeof $rootScope.$watchAsStream).toEqual 'function'

    it "can create streams out of watch expressions", ->
        inject ($rootScope) ->
            done = false

            $rootScope.foo = true
            $rootScope.$watchAsStream('foo').onValue (val) ->
                expect(val).toEqual 'bar'
                done = true

            $rootScope.$apply ->
                $rootScope.foo = 'bar'

            waitsFor -> done

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

            $rootScope.digestStreams 
                first: bus
                second: bus2
                third: bus3

            bus.push 'foo'
            bus2.push 'bar'

            expect($rootScope.first).toEqual 'foo'
            expect($rootScope.second).toEqual 'bar'
            expect($rootScope.third).toBeUndefined()
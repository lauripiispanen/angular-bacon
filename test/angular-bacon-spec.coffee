beforeEach module 'angular-bacon'

describe "rootScope", ->
    it "gets augmented with $watchAsProperty", ->
        inject ($rootScope) ->
            expect(typeof $rootScope.$watchAsProperty).toEqual 'function'

    it "gets augmented with $watchCollectionAsProperty", ->
        inject ($rootScope) ->
            expect(typeof $rootScope.$watchCollectionAsProperty).toEqual 'function'

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

    it "can create collection properties out of watch expressions", ->
        inject ($rootScope) ->
            $rootScope.coll = [1]
            values = []
            $rootScope.$watchCollectionAsProperty('coll').onValue (val) ->
                values.push val

            $rootScope.$apply ->
                $rootScope.coll = [1,2]

            expect(values[0]).toEqual [1]
            expect(values[1]).toEqual [1,2]

    it "will not push an initial collection value if one isn't defined", ->
        inject ($rootScope) ->
            values = []
            $rootScope.$watchAsProperty('coll').onValue (val) ->
                values.push val

            $rootScope.$apply ->
                $rootScope.coll = [1,2]

            expect(values[0]).toEqual [1,2]


    it "can digest observables back to scope", ->
        inject ($rootScope) ->
            bus = new Bacon.Bus

            bus.digest $rootScope, 'foo'

            expect($rootScope.foo).toBeUndefined()

            bus.push 'bar'

            expect($rootScope.foo).toEqual 'bar'

    it "can chain on digest", ->
        inject ($rootScope) ->
            bus = new Bacon.Bus

            bus.digest($rootScope, 'foo').digest($rootScope, 'bar')

            expect($rootScope.foo).toBeUndefined()
            expect($rootScope.bar).toBeUndefined()

            bus.push 'baz'

            expect($rootScope.foo).toEqual 'baz'
            expect($rootScope.bar).toEqual 'baz'

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

    it "ends the stream when the $scope is $destroyed", ->
        inject ($rootScope) ->
            scope = $rootScope.$new()
            ended = false
            scope.$watchAsProperty('foo').onEnd ->
                ended = true

            expect(ended).toEqual false

            scope.$destroy()

            expect(ended).toEqual true

    it "cleans up digests when the $scope is $destroyed", ->
        inject ($rootScope) ->
            scope = $rootScope.$new()
            bus = new Bacon.Bus
            bus.digest scope, 'foo'
            
            bus.push 'bar'
            expect(scope.foo).toEqual 'bar'

            scope.$destroy()

            bus.push 'baz'
            expect(scope.foo).toEqual 'bar'

    describe "eventAsStream", ->

        it "won't stream an event if none triggered", ->
            inject ($rootScope) ->
                scope = $rootScope.$new()
                stream = scope.eventAsStream "testEvent"
                eventReceived = false
                stream.onValue (event) ->
                   eventReceived = true
                expect(eventReceived).toEqual false
    
        it "will stream triggered events", ->
            inject ($rootScope) ->
                scope = $rootScope.$new()
                stream = scope.eventAsStream "testEvent"
                eventReceived = false
                stream.onValue (event) ->
                   eventReceived = true
                scope.$emit "testEvent"
                expect(eventReceived).toEqual true
    
        it "will pass event parameters to stream", ->
            inject ($rootScope) ->
                scope = $rootScope.$new()
                stream = scope.eventAsStream "testEvent"
                parameter = null
                stream.onValue (parameters) ->
                   parameter = parameters[1]
                scope.$emit "testEvent", "test"
                expect(parameter).toEqual "test"
    
        it "will pass on $destroy events", ->
            inject ($rootScope) ->
                scope = $rootScope.$new()
                stream = scope.eventAsStream "$destroy"
                eventReceived = false
                stream.onValue (event) ->
                   eventReceived = true
                scope.$emit "$destroy"
                expect(eventReceived).toEqual true
    
        it "will end the stream on destroy events", ->
            inject ($rootScope) ->
                scope = $rootScope.$new()
                stream = scope.eventAsStream "$destroy"
    
                ended = false
                scope.eventAsStream("$destroy").onEnd ->
                   ended = true
    
                scope.$emit "$destroy"
                expect(ended).toEqual true

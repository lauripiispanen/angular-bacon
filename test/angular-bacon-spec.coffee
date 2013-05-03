beforeEach module 'angular-bacon'

describe "rootScope", ->
    it "gets augmented", ->
        inject ($rootScope) ->
            expect(typeof $rootScope.$watchAsStream).toEqual 'function'
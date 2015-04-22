should = require 'should'
sinon = require 'sinon'
HttpRequestPool = require '../lib/http/http-request-pool'
Q = require 'q'

describe 'HttpRequestPool', ->
  requestPool = null
  beforeEach ->
    requestPool = new HttpRequestPool
    requestPool.newRequest = (options, defer) ->
      ++ @activeSize
      process.nextTick =>
        defer.resolve()
        -- @activeSize
        @schedule()

  it 'send many request simultaneously', (done) ->
    promises = []
    for i in [0...20]
      promises.push requestPool.get()
      requestPool.getActiveSize().should.lessThan(11)
    Q.all(promises).then -> done()

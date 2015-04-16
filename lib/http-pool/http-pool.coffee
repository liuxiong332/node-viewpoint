Q = require 'q'
{HttpRequest} = require 'http-ext'

class HttpRequestPool
  constructor: (maxSize) ->
    @maxSize = maxSize ? 10
    @activeSize = 0
    @waitQueue = []

  schedule: ->
    count = Math.min @maxSize - @activeSize, @waitQueue.length
    for i in [0...count]
      task = @waitQueue.pop()
      task()

  createRequest: ->
    ++ @activeSize
    new HttpRequest options, (err, res) =>
      -- @activeSize
      @schedule()
      callback err, res

  _newRequest: (options, callback) ->
    resolveRequest = (defer) ->
      defer.resolve @createRequest()

    defer = Q.defer()
    if @activeSize + 1 > @maxSize
      @waitQueue.push resolveRequest.bind(this, defer)
    else
      resolveRequest.call(this, defer)
    defer.promise

  ['get', 'post', 'delete', 'put'].forEach (method) =>
    @prototype[method] = (url, options = {}, callback) ->
      if typeof options is 'function'
        callback = options
        options = {}
      options.url = url
      options.method = method.toUpperCase()

      defer = Q.defer()
      @_newRequest(options, callback).then (client) ->
        if options.requestMode is 'stream'
          defer.resolve client.getInputStream()
        else
          defer.resolve client
      defer.promise

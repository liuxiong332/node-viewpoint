Q = require 'q'
{HttpRequest} = require 'http-ext'

module.exports =
class HttpRequestPool
  constructor: (maxSize) ->
    @maxSize = maxSize ? 10
    @activeSize = 0
    @waitQueue = []
    @inProcessQueue = new Set

  getActiveSize: -> @activeSize

  schedule: ->
    while @waitQueue.length > 0 and @activeSize < @maxSize
      task = @waitQueue.pop()
      task()

  close: ->
    @waitQueue = []
    client.abort() for client in @inProcessQueue

  newRequest: (options, defer) ->
    ++ @activeSize
    client = new HttpRequest options, (err, res) =>
      if err then defer.reject(err) else defer.resolve(res)
      @inProcessQueue.delete client
      -- @activeSize
      this.schedule()
    @inProcessQueue.add client

  request = (method, url, options = {}) ->
    if typeof options is 'function'
      callback = options
      options = {}
    options.url = url
    options.method = method

    defer = Q.defer()
    if @activeSize + 1 > @maxSize
      @waitQueue.push @newRequest.bind(this, options, defer)
    else
      @newRequest(options, defer)
    defer.promise

  get: (url, options) -> request.call(this, 'GET', url, options)
  post: (url, options) -> request.call(this, 'POST', url, options)

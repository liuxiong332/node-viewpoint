HttpRequestPool = require './http-request-pool'
https = require 'https'
_ = require 'underscore'
{globalFilterManager} = require 'http-ext'
NtlmAuthFilter = require 'http-ext-ntlm'
Mixin = require 'mixto'

globalFilterManager.use NtlmAuthFilter

# example:
# ```javascript
# var client = new RequestClient(url, {rejectUnauthorized: false});
# client.setAuth(username, password);
# client.send('').then(function(res) { console.log(res.body); });
# ```

module.exports =
class RequestClient extends Mixin
  constructor: (url, options={}) ->
    @requestPool = new HttpRequestPool
    @url = url
    @options = _.clone options
    @options.agent = new https.Agent {keepAlive: true}

  setAuth: (username, password, domain) ->
    @options.ntlmAuth = {username, password, domain}

  setUrl: (@url) ->
    
  send: (soapMsg) ->
    @requestPool.post @url, _.extend body: soapMsg, @options

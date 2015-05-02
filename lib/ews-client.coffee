ItemAccessor = require './item-accessor'
FolderAccessor = require './folder-accessor'
EWSWebService = require './ews-web-service'

module.exports =
class EWSClient
  ItemAccessor.includeInto this
  FolderAccessor.includeInto this

  constructor: (username, password, url, options) ->
    @ews = new EWSWebService(url, options)
    @ews.setAuth(username, password)

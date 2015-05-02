{NAMESPACES} = require './ews-ns'
Item = require './types/item'
Message = require './types/message'
Mixin = require 'mixto'

Types = {Item, Message}

class RootFolder
  constructor: (@node) ->

  totalItemsInView: ->
    parseInt @node.attrVal('TotalItemsInView')

  includesLastItemInRange: ->
    @node.attrVal('IncludesLastItemInRange') is 'true'

  items: ->
    itemsNode = @node.get('t:Items', NAMESPACES)
    for childNode in itemsNode.childNodes()
      if (Constructor = Types[childNode.name()])?
        new Constructor(childNode)

  folders: ->
    foldersNode = @node.get('t:Folders', NAMESPACES)
    for childNode in foldersNode.childNodes()
      if (Constructor = Types[childNode.name()])?
        new Constructor(childNode)

class Items
  constructor: (@node) ->

  items: ->
    for childNode in @node.childNodes()
      if (Constructor = Types[childNode.name()])?
        new Constructor(childNode)

ResponseMsgs = {RootFolder, Items, Folders: Items}

class ResponseParser extends Mixin
  parseResponse: ->
    @resMsgs = @doc.get('//m:ResponseMessages', NAMESPACES)

    _msgNode = @resMsgs.child(0)
    @isSuccess = _msgNode.attrVal('ResponseClass') is 'Success'
    unless @isSuccess
      @responseCode = _msgNode.get('/m:ResponseCode', NAMESPACES)
      @messageText = _msgNode.get('/m:MessageText', NAMESPACES)
    @resMsg = _msgNode

module.exports =
class EWSResponse
  ResponseParser.includeInto this

  constructor: (@doc) ->
    @parseResponse()

  _responseNode: (resMsg) ->
    for node in resMsg.childNodes()
      nodeName = node.name()
      if ResponseMsgs[nodeName]
        return new ResponseMsgs[nodeName](node)

  response: ->
    @_responseNode @resMsgs.child(0)

  responses: ->
    for resNode in @resMsgs.childNodes()
      @_responseNode resNode

class EWSSyncResponse
  ResponseParser.includeInto this

  constructor: (@doc) ->
    @parseResponse()

  syncState: -> @resMsg.get('m:SyncState', NAMESPACES).text()

  includesLastItemInRange: ->
    @resMsg.get('m:IncludesLastItemInRange', NAMESPACES).text() is 'true'

  creates: ->
  updates: ->
  deletes: ->

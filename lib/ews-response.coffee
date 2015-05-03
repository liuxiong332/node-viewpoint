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
    @resMsgsNode = @doc.get('//m:ResponseMessages', NAMESPACES)

    _msgNode = @resMsgsNode.child(0)
    @isSuccess = _msgNode.attrVal('ResponseClass') is 'Success'
    unless @isSuccess
      @responseCode = _msgNode.get('/m:ResponseCode', NAMESPACES)
      @messageText = _msgNode.get('/m:MessageText', NAMESPACES)
    @resMsgNode = _msgNode

class EWSResponse
  ResponseParser.includeInto this

  constructor: (@doc) ->
    @parseResponse()

  _responseNode: (resMsg) ->
    for node in resMsg.childNodes()
      nodeName = node.name()
      if (Constructor = ResponseMsgs[nodeName])?
        return new Constructor(node)

  response: ->
    @_responseNode @resMsgsNode.child(0)

  responses: ->
    @_responseNode resNode for resNode in @resMsgsNode.childNodes()

class EWSSyncResponse
  ResponseParser.includeInto this

  constructor: (@doc) ->
    @parseResponse()
    @changesNode = @resMsgNode.get('m:Changes', NAMESPACES)

  syncState: -> @resMsgNode.get('m:SyncState', NAMESPACES).text()

  includesLastItemInRange: ->
    @resMsgNode.get('m:IncludesLastItemInRange', NAMESPACES).text() is 'true'

  _getChildItems: (path) ->
    createNodes = @changesNode.find(path, NAMESPACES)
    items = []
    for createNode in createNodes
      node = createNode.child(0)
      if (Constructor = Types[node.name()])?
        items.push new Constructor(node)
    items

  creates: ->
    @_getChildItems 't:Create'

  updates: ->
    @_getChildItems 't:Update'

  deletes: ->
    @_getChildItems 't:Delete'

module.exports = {EWSResponse, EWSSyncResponse}

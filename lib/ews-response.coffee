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

  parseNodes: (parent) ->
    for node in parent.childNodes()
      nodeName = node.name()
      if ResponseMsgs[nodeName]
        return new ResponseMsgs[nodeName](node)

module.exports =
class EWSResponse
  ResponseParser.includeInto this

  constructor: (@doc) ->
    @parseResponse()

  response: ->
    @parseNodes @resMsgsNode.child(0)

  responses: ->
    @parseNodes resNode for resNode in @resMsgsNode.childNodes()

class EWSSyncResponse
  ResponseParser.includeInto this

  constructor: (@doc) ->
    @parseResponse()
    @changesNode = @resMsgNode.get('m:Changes', NAMESPACES)

  syncState: -> @resMsg.get('m:SyncState', NAMESPACES).text()

  includesLastItemInRange: ->
    @resMsg.get('m:IncludesLastItemInRange', NAMESPACES).text() is 'true'

  creates: ->
    createNode = @changesNode.get('t:Create', NAMESPACES)
    if createNode then @parseNodes(createNode) else []

  updates: ->
    updateNode = @changesNode.get('t:Update', NAMESPACES)
    if updateNode then @parseNodes(updateNode) else []

  deletes: ->
    deleteNode = @changesNode.get('t:Delete', NAMESPACES)
    if deleteNode then @parseNodes(deleteNode) else []

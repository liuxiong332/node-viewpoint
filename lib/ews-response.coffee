{NAMESPACES} = require './ews-ns'
Item = require './types/item'
Message = require './types/message'

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

class Items
  constructor: (@node) ->

  items: ->
    for childNode in @node.childNodes()
      if (Constructor = Types[childNode.name()])?
        new Constructor(childNode)

ResponseMsgs = {RootFolder, Items, Folders: Items}

module.exports =
class EWSResponse
  constructor: (@doc) ->
    @resMsgs = @doc.get('//m:ResponseMessages', NAMESPACES)

    _msgNode = @resMsgs.child(0)
    @isSuccess = _msgNode.attrVal('ResponseClass') is 'Success'
    unless @isSuccess
      @responseCode = _msgNode.get('/m:ResponseCode', NAMESPACES)
      @messageText = _msgNode.get('/m:MessageText', NAMESPACES)

  _responseNode: (resMsg) ->
    for node in resMsg.childNodes()
      nodeName = node.name()
      if nodeName isnt 'ResponseCode'
        return new ResponseMsgs[nodeName](node)

  response: ->
    @_responseNode @resMsgs.child(0)

  responses: ->
    for resNode in @resMsgs.childNodes()
      @_responseNode resNode

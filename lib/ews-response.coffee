_ = require 'underscore'
{NAMESPACES} = require './ews-ns'
# Item = require './types/item'
# Message = require './types/message'

# Types = {Item, Message}

class RootFolder
  constructor: (@node) ->

  totalItemsInView: ->
    parseInt @node.attrVal('TotalItemsInView')

  includesLastItemInRange: ->
    @node.attrVal('IncludesLastItemInRange') is 'true'

  items: ->
    itemsNode = @node.get('t:Items', NAMESPACES)
    # for childNode in itemsNode.childNodes()
    #   if (Constructor = Types[childNode.name()])?
    #     new Constructor(childNode)

module.exports =
class EwsResponse
  constructor: (@doc) ->
    resMsgs = @doc.get('//m:ResponseMessages', NAMESPACES)

    _msgNode = resMsgs.child(0)
    @status = _msgNode.attrVal('ResponseClass') is 'Success'
    unless @status
      @responseCode = _msgNode.get('/m:ResponseCode', NAMESPACES)
      @messageText = _msgNode.get('/m:MessageText', NAMESPACES)
    @msgChildren = _msgNode.childNodes()

  responseMessages: ->
    for node in @msgChildren
      nodeName = node.name()
      continue if nodeName is 'ResponseCode'
      new EwsResponse[nodeName](node)

  this.RootFolder = RootFolder

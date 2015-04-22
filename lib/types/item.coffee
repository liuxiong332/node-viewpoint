{pascalCase} = require 'ews-util'
TypeMixin = require './type-mixin'

class Item
  TypeMixin.includeInto this
  constructor: (@node) ->

  itemId: ->
    itemIdNode = @node.get('ItemId')
    return null unless itemIdNode?
    id = itemIdNode.attrVal('Id')
    changeKey = itemIdNode.attrVal('ChangeKey')
    {id, changeKey}

  body: ->
    bodyNode = @node.get('Body')
    return null unless bodyNode
    bodyType = bodyNode.attrVal 'BodyType'
    content = bodyNode.text()
    {bodyType, content}

  @addTextMethod 'itemClass', 'subject', 'mimeContent'

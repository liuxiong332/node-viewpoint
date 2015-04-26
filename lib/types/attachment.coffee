{pascalCase} = require '../ews-util'
TypeMixin = require './type-mixin'

module.exports =
class Attachment
  TypeMixin.includeInto this
  constructor: (@node) ->

  attachmentId: ->
    idNode = @getChildNode 'attachmentId'
    idNode.attrVal('Id') if idNode

  # it represent type of attachment, `item` or `file`
  type: ->
    /^(Item|File)/.exec(@node.name())[1].toLowerCase()

  size: ->
    element = @getChildNode 'size'
    parseInt element.text() if element

  lastModifiedTime: ->
    element = @getChildNode 'lastModifiedTime'
    element.text() if element

  # this represent whether the attachment appears inline within an item
  isInline: ->
    element = @getChildNode 'isInline'
    element.text() is 'true' if element

  item: ->
    @getChildNode 'item'

  message: ->
    @getChildNode 'message'

  content: ->
    contentNode = @getChildNode 'content'
    new Buffer(contentNode.text(), 'base64') if contentNode

  # `name` is attachment name,
  # `contentType` is the MIME type of content
  # `contentId` is the user defined content
  # `contentLocation` is URI of the content
  @addTextMethods 'name', 'contentType', 'contentId', 'contentLocation'

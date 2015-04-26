{pascalCase} = require '../ews-util'
TypeMixin = require './type-mixin'
Attachment = require './attachment'

module.exports =
class Item
  TypeMixin.includeInto this
  constructor: (@node) ->

  mimeContent: ->
    element = @getChildNode('mimeContent')
    if element
      characterSet = element.attrVal 'CharacterSet'
      content = new Buffer(element.text()).toString('base64')
      {characterSet, content}

  # `return` {bodyType: 'html' or 'text', content: <content>}
  body: ->
    element = @getChildNode 'body'
    if element
      bodyType = element.attrVal('BodyType').toLowerCase()
      {bodyType, content: element.text()}

  attachments: ->
    attachments = @getChildNode 'attachments'
    if attachments
      new Attachment(attachNode) for attachNode in attachments.childNodes()

  size: -> @getChildIntValue('size')

  categories: ->
    element = @getChildNode('Categories')
    if element
      for childNode in element.childNodes()
        childNode.text()

  internetMessageHeaders: ->
    element = @getChildNode('InternetMessageHeaders')
    if element
      for headerNode in element.childNodes()
        {name: headerNode.attrVal 'HeaderName', value: headerNode.text()}

  @addBoolTextMethods 'isSubmitted', 'isDraft', 'isFromMe', 'isResend',
    'isUnmodified'

  @addTextMethods 'itemClass', 'subject', 'sensitivity', 'mimeContent',
    'dateTimeReceived', 'inReplyTo', 'importance'
  # `itemId` is the item id info that likes {id: <id>, changeKey: <key>}
  # `parentFolderId` the parent folder id
  # `body` contain the body content info, {bodyType: }
  @addAttrMethods 'itemId', 'parentFolderId', 'body'

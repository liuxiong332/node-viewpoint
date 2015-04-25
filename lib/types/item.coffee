{pascalCase, camelCase} = require 'ews-util'
TypeMixin = require './type-mixin'
Attachment = require './attachment'
{NAMESPACES} = require '../ews-ns'

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
      content = element.text()
      {bodyType, content}

  attachments: ->
    attachments = @getChildNode 'attachments'
    if attachments
      new Attachment(attachNode) for attachNode in attachments.childNodes()

  categories: ->
    element = @getChildNode('categories')
    if element
      for childNode in element.childNodes()
        childNode.text()

  internetMessageHeaders: ->
    element = @getChildNode('internetMessageHeaders')
    if element
      for headerNode in element.childNodes()
        {name: headerNode.attrVal 'HeaderName', value: headerNode.text()}

  responseObjects: ->
    element = @getChildNode('responseObjects')
    if element
      objects = {}
      for itemNode in element.childNodes()
        objects[camelCase(itemNode.name())] = new Item(itemNode)

  @addTimeTextMethods 'dateTimeReceived', 'dateTimeSent', 'dateTimeCreated',
    'ReminderDueBy'
  @addBoolTextMethods 'isSubmitted', 'isDraft', 'isFromMe', 'isResend',
    'isUnmodified', 'reminderIsSet', 'hasAttachments'
  @addIntTextMethods 'size', 'reminderMinutesBeforeStart'
  # * `culture` indicates the language, specified by using the RFC 1766 culture
  #   identifier; for example, en-US.
  @addTextMethod 'itemClass', 'subject', 'sensitivity', 'mimeContent',
    'inReplyTo', 'importance', 'displayCc', 'displayTo', 'culture'
  # `itemId` is the item id info that likes {id: <id>, changeKey: <key>}
  # `parentFolderId` the parent folder id
  # `body` contain the body content info, {bodyType: }
  @addAttrMethods 'itemId', 'parentFolderId', 'body', 'conversationId'

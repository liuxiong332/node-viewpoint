{pascalCase, camelCase} = require 'ews-util'
Item = require './item'
TypeMixin = require './type-mixin'
{NAMESPACES} = require '../ews-ns'

class Mailbox
  TypeMixin.includeInto this
  constructor: (@node) ->

  addTextMethods 'name', 'emailAddress', 'routingType', 'mailboxType'
  addAttrMethods 'itemId'

class Message extends Item
  constructor: (node) ->
    super node

  getMailboxList: (methodName) ->
    element = @getChildNode(methodName)
    if element
      new Mailbox(node) for node in element.childNodes()

  @addMailboxMethods: (methods...) ->
    methods.forEach (methodName) =>
      @prototype[methodName] = ->
        element = @getChildNode(methodName)
        new Mailbox(element.child(0)) if element

  @addMailboxListMethods: (methods...) ->
    methods.forEach (methodName) =>
      @prototype[methodName] = -> @getMailboxList(methodName)

  @addMailboxMethods 'sender', 'from', 'receivedBy'
  @addMailboxListMethods 'toRecipients', 'ccRecipients', 'bccRecipients',
    'replyTo'
  @addTextMethods 'conversationTopic', 'conversationIndex', 'internetMessageId',
    'references'
  @addBoolTextMethods 'isReadReceiptRequested', 'isDeliveryReceiptRequested',
    'isRead', 'isResponseRequested'

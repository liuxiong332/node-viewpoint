Builder = require 'libxmljs-builder'
NS = require './ews-ns'
{pascalCase} = require './ews-util'
_ = require 'underscore'

module.exports =
class EWSBuilder
  NS_T = NS.NS_TYPES
  NS_M = NS.NS_MESSAGES

  convertName = (name) ->
    '$' + name
  # * `bodyCallback` {Function} to build children nodes
  @build: (bodyCallback) ->
    @builder = new Builder
    @builder.defineNS NS.NAMESPACES
    @builder.rootNS NS.NS_SOAP, 'Envelope', (builder) ->
      builder.nodeNS NS.NS_SOAP, 'Body', bodyCallback

  @_addTextMethods: (names...) ->
    names.forEach (name) =>
      this[convertName(name)] = (builder, params) ->
        builder.nodeNS NS_T, pascalCase(name), params

  # `sensitivity` {String} value can be `Normal`, `Personal`, `Private`,
  #   or `Confidential`
  # `importance` {String} can be `Low`, `Normal`, `High`
  @_addTextMethods 'isSubmitted', 'isDraft', 'isFromMe', 'inReplyTo',
    'isResend', 'sensitivity', 'importance', 'itemClass', 'subject', 'isRead'

  @_addTimeMethods: (names...) ->
    names.forEach (name) =>
      this[convertName(name)] = (builder, params) ->
        val = if params instanceof Date then params.toISOString() else params
        builder.nodeNS NS_T, pascalCase(name), val

  @_addTimeMethods 'dateTimeSent', 'dateTimeCreated'

  @$bodyType: (builder, type) ->
    builder.nodeNS NS_T, 'BodyType', @convertBodyType(type) if type?

  @$body: (builder, body) ->
    params = {}
    if _.isString body
      content = body
    else
      params.BodyType = @convertBodyType(body.bodyType) if body.bodyType?
      params.IsTruncated = body.isTruncated if body.isTruncated?
      content = body.content
    builder.nodeNS NS_T, 'Body', params, content

  @_addTextMethods 'name', 'emailAddress'

  @$mimeContent: (builder, params) ->
    attrs = {}
    if Buffer.isBuffer params
      content = params
    else
      attrs.CharacterSet = params.characterSet if params.characterSet?
      content = params.content
    builder.nodeNS NS_T, 'MimeContent', attrs, content.toString('base64')

  parseId = (param) ->
    res = {Id: param.id}
    res.ChangeKey = param.changeKey if param.changeKey?
    res

  @$itemId: (builder, params) ->
    builder.nodeNS NS_T, 'ItemId', parseId(params)

  @$parentFolderId: (builder, params) ->
    builder.nodeNS NS_T, 'ParentFolderId', parseId(params)

  @$mailbox: (builder, params) ->
    builder.nodeNS NS_T, 'Mailbox', (builder) =>
      @$name(builder, params.name) if params.name?
      @$emailAddress(builder, params.emailAddress) if params.emailAddress?

  @_buildMailbox: (builder, name, params) ->
    builder.nodeNS NS_T, pascalCase(name), (builder) =>
      params = [params] unless Array.isArray(params)
      for item in params
        @$mailbox(builder, item)

  @_addMailboxMethods: (names...) ->
    names.forEach (name) =>
      this[convertName(name)] = (builder, params) ->
        @_buildMailbox(builder, name, params)

  @_addMailboxMethods 'sender', 'toRecipients', 'ccRecipients', 'bccRecipients',
    'from'

  @_addTextMethods 'contentType', 'contentId', 'contentLocation'

  @$content: (builder, params) ->
    unless Buffer.isBuffer(params)
      throw new TypeError('params should be Buffer')
    builder.nodeNS NS_T, 'Content', params.toString('base64')

  # `builder` is XMLBuilder
  # `attachments` {Array} each item is attachment params, which like
  #   {type: 'item' or 'message', content: '<content>'}
  @$attachments: (builder, attachments) ->
    attachments = [attachments] unless Array.isArray(attachments)
    builder.nodeNS NS_T, 'Attachments', (builder) =>
      for item in attachments
        if item.type is 'item'
          @$itemAttachment(builder, item)
        else
          @$fileAttachment(builder, item)

  @$internetMessageHeader: (builder, header) ->
    params = {HeaderName: header.headerName}
    builder.nodeNS NS_T, 'InternetMessageHeader', params, header.headerValue

  # `builder` {XMLBuilder}
  # `headers` {Array} each item is likes
  #   {headerName: <name>, headerValue: <value>}
  @$internetMessageHeaders: (builder, headers) ->
    builder.nodeNS NS_T, 'InternetMessageHeaders', (builder) =>
      for header in headers
        @$internetMessageHeader builder, header

  @$baseShape: (builder, params) ->
    builder.nodeNS NS_T, 'BaseShape', pascalCase(params)

  @_addTextMethods 'includeMimeContent'
  # * `itemShape` {Object} the ItemShape parameters
  #   * `baseShape` {String} can be `idOnly` or `default` or `allProperties`
  #   * `includeMimeContent` (optional) {Bool}
  #   * `bodyType` (optional) {String}  `html` or `text` or `best`
  # * `builder` {ChildrenBuilder}
  @$itemShape: (builder, itemShape) ->
    builder.nodeNS NS_M, 'ItemShape', (builder) =>
      @$baseShape(builder, itemShape.baseShape) if itemShape.baseShape?
      if (imc = itemShape.includeMimeContent)?
        @$includeMimeContent(builder, imc)
      @$bodyType(builder, itemShape.bodyType) if itemShape.bodyType?

  # * `folderIds` {Array} or `Object`
  #   every item of `folderIds` is `Object`, for distinguished folderId,
  #   just like {id: <myId>, changeKey: <key>, type: 'distinguished'},
  #   for folderId, the `type` should be ignore
  _buildFolderIds = (builder, name, folderIds) ->
    builder.nodeNS NS_M, pascalCase(name), (builder) ->
      folderIds = [folderIds] unless Array.isArray folderIds
      for fid in folderIds
        if fid.type is 'distinguished'
          builder.nodeNS NS_T, 'DistinguishedFolderId', parseId(fid)
        else
          builder.nodeNS NS_T, 'FolderId', parseId(fid)

  @$parentFolderIds: (builder, folderIds) ->
    _buildFolderIds(builder, 'parentFolderIds', folderIds)

  @$savedItemFolderId: (builder, folderId) ->
    _buildFolderIds(builder, 'savedItemFolderId', folderId)

  @$toFolderId: (builder, folderId) ->
    _buildFolderIds(builder, 'toFolderId', folderId)

  @returnNewItemIds: (builder, param) ->
    builder.nodeNS NS_M, 'ReturnNewItemIds', param
  # * `viewOpts` {Object}
  #   * `maxReturned` {Number}
  #   * `offset` {Number}
  #   * `basePoint` {String} 'beginning' or 'end'
  @$indexedPageItemView: (builder, viewOpts) ->
    params =
      MaxEntriesReturned: viewOpts.maxReturned
      Offset: viewOpts.offset.toString()
      BasePoint: pascalCase(viewOpts.basePoint)
    builder.nodeNS NS_T, 'IndexedPageViewItemView', params

  # `itemIds` {Array} or 'Object'
  #   every item of `itemIds` is 'Object', like {id: <id>, changeKey: <key>}
  @$itemIds: (builder, itemIds) ->
    itemIds = [itemIds] unless Array.isArray(itemIds)
    builder.nodeNS NS_M, 'ItemIds', (builder) =>
      @$itemId(builder, iid) for iid in itemIds

  @_buildItem: (builder, name, params) ->
    builder.nodeNS NS_T, pascalCase(name), (builder) =>
      for key, param of params when param?
        this[convertName(key)]?.call(this, builder, param)

  @_addItemMethods: (names...) ->
    names.forEach (name) =>
      this[convertName(name)] = (builder, params) ->
        @_buildItem(builder, name, params)

  @_addItemMethods 'itemAttachment', 'fileAttachment', 'item', 'message'

  @$items: (builder, params) ->
    params = [params] unless Array.isArray(params)
    builder.nodeNS NS_M, 'Items', (builder) =>
      @$message(builder, itemInfo) for itemInfo in params

  @convertBodyType: (body) ->
    switch body
      when 'html' then 'HTML'
      when 'text' then 'Text'
      when 'best' then 'Best'
      else bodyType

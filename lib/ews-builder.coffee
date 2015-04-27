Builder = require 'libxmljs-builder'
NS = require './ews-ns'
{pascalCase} = require './ews-util'

module.exports =
class EwsBuilder
  NS_T = NS.NS_TYPES
  NS_M = NS.NS_MESSAGES

  # * `bodyCallback` {Function} to build children nodes
  @build: (bodyCallback) ->
    @builder = new Builder
    @builder.defineNS NS.NAMESPACES
    @builder.rootNS NS.NS_SOAP, 'Envelope', (builder) ->
      builder.nodeNS NS.NS_SOAP, 'Body', bodyCallback

  @_buildText: (builder, name, opts) ->
    if (value = opts[name])?
      builder.nodeNS NS_T, pascalCase(name), value

  @_buildTime: (builder, name, opts) ->
    if (value = opts[name])?
      builder.nodeNS NS_T, pascalCase(name), value.toISOString()

  @_buildTexts: (builder, opts, names...) ->
    for name in names
      @_buildText builder, name, opts

  @_buildTimes: (builder, opts, names...) ->
    for name in names
      @_buildTime builder, name, opts

  @_buildPascalText: (builder, name, opts) ->
    if (value = opts[name])?
      builder.nodeNS NS_T, pascalCase(name), pascalCase(value)

  @_buildAttr: (builder, name, opts) ->
    if (attrs = opts[name])?
      params = {}
      for key, value of attrs when key isnt 'content'
        params[pascalCase(key)] = value
      builder.nodeNS NS_T, pascalCase(name), params, attrs.content

  @bodyType: (builder, type) ->
    builder.nodeNS NS_T, 'BodyType', @convertBodyType(type) if type?

  @body: (builder, body) ->
    if body?
      bodyType = @convertBodyType(body.bodyType) if body.bodyType?
      params = {bodyType, isTruncated: body.isTruncated}
      builder.nodeNS NS_T, 'Body', params, body.content

  @mimeContent: (builder, params) ->
    if params?
      characterSet = params['characterSet']
      content = new Buffer(params.content).toString('base64')
      builder.nodeNS NS_T, 'MimeContent', {characterSet}, content

  @itemAttachment: (builder, params) ->
    if params?
      builder.nodeNS NS_T, 'ItemAttachment', (builder) =>
        @_buildText(builder, 'name', params)
        @_buildText(builder, 'contentType', params)
        @_buildText(builder, 'contentId', params)
        @_buildText(builder, 'contentLocation', params)
        @item(builder, params.item)
        @message(builder, params.message)

  @fileAttachment: (builder, params) ->
    if params?
      builder.nodeNS NS_T, 'FileAttachment', (builder) =>
        @_buildText(builder, 'name', params)
        @_buildText(builder, 'contentType', params)
        @_buildText(builder, 'contentId', params)
        @_buildText(builder, 'contentLocation', params)
        if params.content?
          builder.nodeNS NS_T, 'Content', params.content.toString('base64')

  # `builder` is XMLBuilder
  # `attachments` {Array} each item is attachment params, which like
  #   {type: 'item' or 'message', content: '<content>'}
  @attachments: (builder, attachments) ->
    if attachments?
      attachments = [attachments] unless Array.isArray(attachments)
      builder.nodeNS NS_T, 'Attachments', (builder) =>
        for item in attachments
          if item.type is 'item'
            @itemAttachment(builder, item)
          else
            @fileAttachment(builder, item)

  @internetMessageHeader: (builder, header) ->
    if header?
      params = {HeaderName: header.headerName}
      builder.nodeNS NS_T, 'InternetMessageHeader', params, header.headerValue

  # `builder` {XMLBuilder}
  # `headers` {Array} each item is likes
  #   {headerName: <name>, headerValue: <value>}
  @internetMessageHeaders: (builder, headers) ->
    if headers?
      builder.nodeNS NS_T, 'InternetMessageHeaders', (builder) =>
        for header in headers
          @internetMessageHeader builder, header
  # * `itemShape` {Object} the ItemShape parameters
  #   * `baseShape` {String} can be `idOnly` or `default` or `allProperties`
  #   * `includeMimeContent` (optional) {Bool}
  #   * `bodyType` (optional) {String}  `html` or `text` or `best`
  # * `builder` {ChildrenBuilder}
  @itemShape: (itemShape, builder) ->
    builder.nodeNS NS_M, 'ItemShape', (builder) =>
      @_buildPascalText(builder, 'baseShape', itemShape)
      @_buildText(builder, 'includeMimeContent', itemShape)
      @bodyType(builder, itemShape.bodyType)

  # * `folderIds` {Array} or `Object`
  #   every item of `folderIds` is `Object`, for distinguished folderId,
  #   just like {id: <myId>, changeKey: <key>, type: 'distinguished'},
  #   for folderId, the `type` should be ignore
  @parentFolderIds: (folderIds, builder) ->
    folderIds = [folderIds] unless Array.isArray folderIds

    builder.nodeNS NS_M, 'ParentFolderIds', (builder) ->
      for fid in folderIds
        params = {Id: fid.id, ChangeKey: fid.changeKey}
        if fid.type is 'distinguished'
          builder.nodeNS NS_T, 'DistinguishedFolderId', params
        else
          builder.nodeNS NS_T, 'FolderId', params

  # * `viewOpts` {Object}
  #   * `maxReturned` {Number}
  #   * `offset` {Number}
  #   * `basePoint` {String} 'beginning' or 'end'
  @indexedPageItemView: (viewOpts, builder) ->
    params =
      MaxEntriesReturned: viewOpts.maxReturned
      Offset: viewOpts.offset.toString()
      BasePoint: pascalCase(viewOpts.basePoint)
    builder.nodeNS NS_T, 'IndexedPageViewItemView', params

  # `itemIds` {Array} or 'Object'
  #   every item of `itemIds` is 'Object', like {id: <id>, changeKey: <key>}
  @itemIds: (itemIds, builder) ->
    itemIds = [itemIds] unless Array.isArray(itemIds)
    builder.nodeNS NS_M, 'ItemIds', (builder) ->
      for iid in itemIds
        builder.nodeNS NS_T, 'ItemId', {Id: iid.id, ChangeKey: iid.changeKey}

  @message: (msg, builder) ->
    builder.nodeNS NS_T, 'Message', (builder) =>
      @_buildText(builder, 'itemClass', msg)
      @_buildText(builder, 'subject', msg)
      @mimeContent(builder, msg.mimeContent)
      @_buildText(builder, 'sensitivity', msg)
      @body(builder, msg.body)
      @attachments(builder, msg.attachments)
      @_buildTexts builder, msg, 'importance', 'inReplyTo', 'isSubmitted',
        'isDraft', 'isResend', 'isFromMe', 'isUnmodified'
      @internetMessageHeaders(builder, msg.internetMessageHeaders)
      @_buildTimes builder, msg, 'dateTimeSent', 'dateTimeCreated'

  @convertBodyType: (body) ->
    switch body
      when 'html' then 'HTML'
      when 'text' then 'Text'
      when 'best' then 'Best'
      else bodyType

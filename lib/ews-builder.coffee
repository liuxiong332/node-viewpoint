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

  # * `itemShape` {Object} the ItemShape parameters
  #   * `baseShape` {String} can be `idOnly` or `default` or `allProperties`
  #   * `includeMimeContent` (optional) {Bool}
  #   * `bodyType` (optional) {String}  `html` or `text` or `best`
  # * `builder` {ChildrenBuilder}
  @itemShape: (itemShape, builder) ->
    builder.nodeNS NS_M, 'ItemShape', (builder) =>
      if itemShape.baseShape?
        builder.nodeNS NS_T, 'BaseShape', pascalCase itemShape.baseShape

      iMC = itemShape.includeMimeContent
      builder.nodeNS NS_T, 'IncludeMimeContent', iMC.toString() if iMC?

      if (bodyType = itemShape.bodyType)?
        builder.nodeNS NS_T, 'BodyType', @convertBodyType(itemShape.bodyType)

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

  @convertBodyType: (body) ->
    switch body
      when 'html' then 'HTML'
      when 'text' then 'Text'
      when 'best' then 'Best'
      else bodyType

Builder = require 'libxmljs-builder'
_ = require 'underscore'
NS = require './ews-ns'
{pascalCase} = require './ews-util'

module.exports =
class EwsBuilder
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
    NS_T = NS.NS_TYPES
    builder.nodeNS NS.NS_MESSAGES, 'ItemShape', (builder) =>
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
    folderIds = [folderIds] unless _.isArray folderIds

    NS_T = NS.NS_TYPES
    builder.nodeNS NS.NS_MESSAGES, 'ParentFolderIds', (builder) ->
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
    builder.nodeNS EwsBuilder.NS_TYPES, 'IndexedPageViewItemView', params

  @convertBodyType: (body) ->
    switch body
      when 'html' then 'HTML'
      when 'text' then 'Text'
      when 'best' then 'Best'
      else bodyType

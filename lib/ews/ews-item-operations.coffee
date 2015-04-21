EwsBuilder = require '../ews-builder'
{NS_MESSAGES} = require './ews-ns'

module.exports =
class EWSItemOperations
  # @param [Object] options traversal, baseShape, parentFolderId
  findItem: (opts) ->
    doc = EwsBuilder.build (builder) ->
      traversal = opts['traversal'] ? 'Shallow'
      builder.nodeNS NS_MESSAGES, 'FindItem', Traversal: traversal, (builder) ->
        EwsBuilder.itemShape opts.itemShape, builder if opts.itemShape?
        EwsBuilder.parentFolderIds opts.folderIds, builder if opts.folderIds?
        if opts.indexedPageItemView?
          EwsBuilder.indexedPageItemView opts.indexedPageItemView, builder
    @doSoapRequest(doc)

Mixin = require 'mixto'
EwsBuilder = require '../ews-builder'
{NS_MESSAGES} = require '../ews-ns'

module.exports =
class EWSItemOperations extends Mixin

  buildFindItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      traversal = opts['traversal'] ? 'Shallow'
      builder.nodeNS NS_MESSAGES, 'FindItem', Traversal: traversal, (builder) ->
        EwsBuilder.itemShape(opts.itemShape, builder) if opts.itemShape?
        if (pid = opts.parentFolderIds)?
          EwsBuilder.parentFolderIds(pid, builder)
        if opts.indexedPageItemView?
          EwsBuilder.indexedPageItemView opts.indexedPageItemView, builder

  # @param [Object] options traversal, baseShape, parentFolderId
  findItem: (opts) ->
    @doSoapRequest @buildFindItem(opts)

  buildGetItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'GetItem', (builder) ->
        EwsBuilder.itemShape(opts.itemShape, builder) if opts.itemShape?
        EwsBuilder.itemIds(opts.itemIds, builder) if opts.itemIds?

  getItem: (opts) ->
    @doSoapRequest @buildGetItem(opts)

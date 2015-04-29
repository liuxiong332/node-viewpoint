Mixin = require 'mixto'
EwsBuilder = require '../ews-builder'
{NS_MESSAGES} = require '../ews-ns'

module.exports =
class EWSItemOperations extends Mixin

  buildFindItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      traversal = opts['traversal'] ? 'Shallow'
      builder.nodeNS NS_MESSAGES, 'FindItem', Traversal: traversal, (builder) ->
        EwsBuilder.itemShape(builder, opts.itemShape) if opts.itemShape?
        if (pid = opts.parentFolderIds)?
          EwsBuilder.parentFolderIds(builder, pid)
        if opts.indexedPageItemView?
          EwsBuilder.indexedPageItemView builder, opts.indexedPageItemView

  # @param [Object] options traversal, baseShape, parentFolderId
  findItem: (opts) ->
    @doSoapRequest @buildFindItem(opts)

  buildGetItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'GetItem', (builder) ->
        EwsBuilder.itemShape(builder, opts.itemShape) if opts.itemShape?
        EwsBuilder.itemIds(builder, opts.itemIds) if opts.itemIds?

  getItem: (opts) ->
    @doSoapRequest @buildGetItem(opts)

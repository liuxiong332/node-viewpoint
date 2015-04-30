Mixin = require 'mixto'
EwsBuilder = require '../ews-builder'
{NS_MESSAGES} = require '../ews-ns'

module.exports =
class EWSItemOperations extends Mixin
  buildFindItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      traversal = opts['traversal'] ? 'Shallow'
      builder.nodeNS NS_MESSAGES, 'FindItem', Traversal: traversal, (builder) ->
        EwsBuilder.$itemShape(builder, opts.itemShape) if opts.itemShape?
        if (pid = opts.parentFolderIds)?
          EwsBuilder.$parentFolderIds(builder, pid)
        if opts.indexedPageItemView?
          EwsBuilder.$indexedPageItemView builder, opts.indexedPageItemView

  # @param [Object] options traversal, baseShape, parentFolderId
  findItem: (opts) ->
    @doSoapRequest @buildFindItem(opts)

  buildGetItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'GetItem', (builder) ->
        EwsBuilder.$itemShape(builder, opts.itemShape) if opts.itemShape?
        EwsBuilder.$itemIds(builder, opts.itemIds) if opts.itemIds?

  getItem: (opts) ->
    @doSoapRequest @buildGetItem(opts)

  buildCreateItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      param = {MessageDisposition: opts.messageDisposition}
      builder.nodeNS NS_MESSAGES, 'CreateItem', param, (builder) ->
        if opts.savedItemFolderId?
          EwsBuilder.$savedItemFolderId(builder, opts.savedItemFolderId)
        EwsBuilder.$items(builder, opts.items) if opts.items?

  createItem: (opts) ->
    @doSoapRequest @buildCreateItem(opts)

  buildCopyOrMoveItem = (nodeName, opts={}) ->
    EwsBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, nodeName, (builder) ->
        EwsBuilder.$toFolderId(builder, opts.toFolderId) if opts.toFolderId
        EwsBuilder.$itemIds(builder, opts.itemIds) if opts.itemIds
        if opts.returnNewItemIds
          EwsBuilder.$returnNewItemIds(builder, opts.returnNewItemIds)

  copyItem: (opts) ->
    @doSoapRequest buildCopyOrMoveItem('CopyItem', opts)

  moveItem: (opts) ->
    @doSoapRequest buildCopyOrMoveItem('MoveItem', opts)
  # `opts` {Object}
  #   `deleteType` {String} can be 'HardDelete', 'SoftDelete',
  #   'MoveToDeletedItems'
  buildDeleteItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      param = {DeleteType: opts.deleteType}
      builder.nodeNS NS_MESSAGES, 'DeleteItem', param, (builder) ->
        EwsBuilder.$itemIds(builder, opts.itemIds)

  deleteItem: (opts) ->
    @doSoapRequest @buildDeleteItem(opts)

  buildSendItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      param = {SaveItemToFolder: opts.saveItemToFolder}
      builder.nodeNS NS_MESSAGES, 'SendItem', param, (builder) ->
        EwsBuilder.$itemIds(builder, opts.itemIds)
        if opts.savedItemFolderId
          EwsBuilder.$savedItemFolderId(builder, opts.savedItemFolderId)

  sendItem: (opts) ->
    @doSoapRequest @buildSendItem(opts)

  buildUpdateItem: (opts={}) ->
    EwsBuilder.build (builder) ->
      param = {MessageDisposition: opts.messageDisposition}
      builder.nodeNS NS_MESSAGES 'UpdateItem', param, (builder) ->
        if opts.savedItemFolderId
          EwsBuilder.$savedItemFolderId(builder, opts.savedItemFolderId)
        EwsBuilder.$itemChanges(builder, opts.itemChanges)

  updateItem: (opts) ->
    @doSoapRequest @buildUpdateItem(opts)

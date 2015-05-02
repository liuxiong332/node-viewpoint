Mixin = require 'mixto'
EWSBuilder = require '../ews-builder'
{NS_MESSAGES} = require '../ews-ns'

module.exports =
class EWSItemOperations extends Mixin
  buildFindItem: (opts={}) ->
    EWSBuilder.build (builder) ->
      traversal = opts['traversal'] ? 'Shallow'
      builder.nodeNS NS_MESSAGES, 'FindItem', Traversal: traversal, (builder) ->
        EWSBuilder.$itemShape(builder, opts.itemShape)
        if (itemView = opts.indexedPageItemView)?
          EWSBuilder.$indexedPageItemView builder, itemView
        EWSBuilder.$parentFolderIds(builder, opts.parentFolderIds)

  # @param [Object] options traversal, baseShape, parentFolderId
  findItem: (opts) ->
    @doSoapRequest @buildFindItem(opts)

  buildGetItem: (opts={}) ->
    EWSBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'GetItem', (builder) ->
        EWSBuilder.$itemShape(builder, opts.itemShape) if opts.itemShape?
        EWSBuilder.$itemIds(builder, opts.itemIds) if opts.itemIds?

  getItem: (opts) ->
    @doSoapRequest @buildGetItem(opts)

  buildCreateItem: (opts={}) ->
    EWSBuilder.build (builder) ->
      param = {MessageDisposition: opts.messageDisposition ? 'SaveOnly'}
      builder.nodeNS NS_MESSAGES, 'CreateItem', param, (builder) ->
        if opts.savedItemFolderId?
          EWSBuilder.$savedItemFolderId(builder, opts.savedItemFolderId)
        EWSBuilder.$items(builder, opts.items) if opts.items?

  createItem: (opts) ->
    @doSoapRequest @buildCreateItem(opts)

  buildCopyOrMoveItem: (nodeName, opts={}) ->
    EWSBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, nodeName, (builder) ->
        EWSBuilder.$toFolderId(builder, opts.toFolderId) if opts.toFolderId
        EWSBuilder.$itemIds(builder, opts.itemIds) if opts.itemIds
        if opts.returnNewItemIds
          EWSBuilder.$returnNewItemIds(builder, opts.returnNewItemIds)

  copyItem: (opts) ->
    @doSoapRequest @buildCopyOrMoveItem('CopyItem', opts)

  moveItem: (opts) ->
    @doSoapRequest @buildCopyOrMoveItem('MoveItem', opts)
  # `opts` {Object}
  #   `deleteType` {String} can be 'HardDelete', 'SoftDelete',
  #   'MoveToDeletedItems'
  buildDeleteItem: (opts={}) ->
    EWSBuilder.build (builder) ->
      param = {DeleteType: opts.deleteType}
      builder.nodeNS NS_MESSAGES, 'DeleteItem', param, (builder) ->
        EWSBuilder.$itemIds(builder, opts.itemIds)

  deleteItem: (opts) ->
    @doSoapRequest @buildDeleteItem(opts)

  buildSendItem: (opts={}) ->
    EWSBuilder.build (builder) ->
      opts.saveItemToFolder ?= opts.savedItemFolderId?
      param = {SaveItemToFolder: opts.saveItemToFolder}
      builder.nodeNS NS_MESSAGES, 'SendItem', param, (builder) ->
        EWSBuilder.$itemIds(builder, opts.itemIds)
        if opts.savedItemFolderId
          EWSBuilder.$savedItemFolderId(builder, opts.savedItemFolderId)

  sendItem: (opts) ->
    @doSoapRequest @buildSendItem(opts)

  buildUpdateItem: (opts={}) ->
    EWSBuilder.build (builder) ->
      param = {MessageDisposition: opts.messageDisposition ? 'SaveOnly'}
      builder.nodeNS NS_MESSAGES, 'UpdateItem', param, (builder) ->
        if opts.savedItemFolderId
          EWSBuilder.$savedItemFolderId(builder, opts.savedItemFolderId)
        EWSBuilder.$itemChanges(builder, opts.itemChanges)

  updateItem: (opts) ->
    @doSoapRequest @buildUpdateItem(opts)

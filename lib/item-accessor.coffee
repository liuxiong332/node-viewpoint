Mixin = require 'mixto'
_ = require 'underscore'

module.exports =
class ItemAccessor extends Mixin
  # `itemId` {String} the id of item
  # `opts` {Object} more options
  #   'shape' {String} baseShape value
  getItem: (itemId, opts={}) ->
    args = @_getItemArgs(itemId, opts)
    @ews.getItem(args).then (res) -> res.items()[0]

  getItems: (itemIds, opts={}) ->
    args = @_getItemArgs(itemIds, opts)
    @ews.getItem(args).then (res) -> res.items()

  findItems: (opts={}) ->
    @ews.findItem @_findItemsArgs(opts)

  copyItems: (items, folder) ->
    args = @_moveCopyItemsArgs(items, folder)
    @ews.copyItem(args).then (res) -> res.items()

  moveItems: (items, folder) ->
    args = @_moveCopyItemsArgs(items, folder)
    @ews.moveItem(args).then (res) -> res.items()

  deleteItems: (items, deleteType) ->
    opts =
      deleteType: deleteType ? 'HardDelete'
      itemIds: @_getItemIds(items)
    @ews.deleteItem opts

  markRead: (items) ->
    args = @_markReadArgs(items)
    @ews.updateItem(args).then (res) -> res.items()

  # `opts` {Object}
  #   `folderId` the folder that items saved
  #   `items` {Object} or `Array` the message item
  saveItems: (opts) ->
    params = _.clone(opts)
    if opts.folderId
      params.savedItemFolderId = @_getItemId(opts.folderId)
    @ews.createItem(params).then (res) -> res.items()

  sendItems: (opts) ->
    if opts.itemIds
      @ews.sendItem {itemIds: @_getItemIds(opts.itemIds)}
    else if opts.items
      @ews.createItem _.extend opts, {messageDisposition: 'SendOnly'}

  sendAndSaveItems: (opts) ->
    params = savedItemFolderId: @_getItemId(opts.folderId)
    if opts.itemIds
      @ews.sendItem _.extend(params, itemIds: @_getItemIds(opts.itemIds))
    else if opts.items
      _.extend params,
        items: opts.items, messageDisposition: 'SendAndSaveCopy'
      @ews.createItem _.extend params

  syncItems: (opts) ->
    @ews.syncFolderItems @_syncItemsArgs(opts)

  # private methods
  _getItemId: (id) ->
    if _.isString(id) then {id: id} else id

  _getItemIds: (itemIds) ->
    itemIds = [itemIds] unless Array.isArray(itemIds)
    @_getItemId(itemId) for itemId in itemIds

  _getItemArgs: (itemIds, opts) ->
    args = itemShape: baseShape: opts.shape ? 'Default'
    args.itemIds = @_getItemIds(itemIds)
    _.extend(args, opts)

  _findItemsArgs: (opts) ->
    args =
      traversal: 'Shallow'
      itemShape: baseShape: opts.shape ? 'Default'
    args.parentFolderIds = @_getItemId(opts.folderId)
    _.extend args, opts

  _moveCopyItemsArgs: (items, folder) ->
    toFolderId: @_getItemId(folder)
    itemIds: @_getItemIds(items)
    returnNewItemIds: true

  _markReadArgs: (items) ->
    itemChanges = []
    items = [items] unless Array.isArray(items)
    itemChanges = for itemId in items
      {itemId, setFields: {fieldURI: 'message:IsRead', message: isRead: true}}
    {itemChanges}

  _syncItemsArgs: (opts) ->
    params =
      itemShape: {baseShape: opts.shape ? 'IdOnly'}
      syncFolderId: @_getItemId(opts.folderId)
    params.maxChangesReturned = opts.maxReturned if opts.maxReturned
    _.extend params, opts

Mixin = require 'mixto'
_ = require 'underscore'

module.exports =
class ItemAccessor extends Mixin
  # `itemId` {String} the id of item
  # `opts` {Object} more options
  #   'shape' {String} baseShape value
  getItem: (itemId, opts={}) ->
    args = @_getItemArgs(itemId, opts)
    @ews.getItem(args).then (responses) -> responses[0]

  getItems: (itemIds, opts={}) ->
    @ews.getItem @_getItemArgs(itemIds, opts)

  findItems: (opts={}) ->
    @ews.findItem @_findItemsArgs(opts)

  copyItems: (items, folder) ->
    @ews.copyItem @_moveCopyItemsArgs(items, folder)

  moveItems: (items, folder) ->
    @ews.moveItem @_moveCopyItemsArgs(items, folder)

  deleteItems: (items, deleteType) ->
    opts =
      deleteType: deleteType ? 'HardDelete'
      itemIds: @_getItemIds(items)
    @ews.deleteItem opts

  markRead: (items) ->


  _getItemIds: (itemIds) ->
    itemIds = [itemIds] unless Array.isArray(itemIds)
    for itemId in itemIds
      if _.isString(itemId) then {id: itemId} else itemId

  _getItemArgs: (itemIds, opts) ->
    args = itemShape: baseShape: opts.shape ? 'Default'
    args.itemIds = @_getItemIds(itemIds)
    _.extend(args, opts)

  _findItemsArgs: (opts) ->
    args =
      traversal: 'Shallow'
      itemShape: baseShape: 'Default'
    folderId = opts.folderId
    args.parentFolderIds =
      if _.isString(folderId) then {id: folderId} else folderId
    _.extend args, opts

  _moveCopyItemsArgs: (items, folder) ->
    toFolderId: if _.isString(folder) then {id: folder} else folder
    itemIds: @_getItemIds(items)
    returnNewItemIds: true

  _markReadArgs: (items) ->
    itemChanges = []
    items = [items] unless Array.isArray(items)
    itemChanges = for item in items
      itemId = if _.isString(item) then {id: item} else item
      {itemId, setFields: {fieldURI: 'message:IsRead', message: isRead: true}}
    {itemChanges}

Mixin = require 'mixto'
_ = require 'underscore'

module.exports =
class ItemAccessor extends Mixin
  # `itemId` {String} or `Array` the id of item
  # `opts` {Object} more options
  getItem: (itemIds, opts={}) ->
    promise = @ews.getItem @_getItemArgs(itemIds, opts)
    unless Array.isArray(itemIds)
      promise = promise.then (responses) -> responses[0]
    promise

  _getItemArgs: (itemIds, opts) ->
    args = itemShape: baseShape: opts.shape ? 'Default'

    itemIds = [itemIds] unless Array.isArray(itemIds)
    args.itemIds = for itemId in itemIds
      if _.isString(itemId) then {id: itemId} else itemId
    _.extend(args, opts)

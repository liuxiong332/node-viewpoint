EwsBuilder = require '../ews-builder'
{NS_TYPES, NS_MESSAGES} = EwsBuilder

module.exports =
class EWSItemOperations
  # @param [Object] options traversal, baseShape, parentFolderId
  findItem: (opts) ->
    EwsBuilder.build (builder) ->
      traversal = opts['traversal'] ? 'Shallow'
      builder.nodeNS NS_MESSAGES, 'FindItem', Traversal: traversal, (builder) ->
        EwsBuilder.itemShape opts, builder

Mixin = require 'mixto'
EWSBuilder = require '../ews-builder'
{NS_MESSAGES} = require '../ews-ns'

module.exports =
class EWSSyncOperations extends Mixin
  buildSyncFolderItems: (opts={}) ->
    EWSBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'SyncFolderItems', (builder) ->
        EWSBuilder.$itemShape(builder, opts.itemShape)
        EWSBuilder.$syncFolderId(builder, opts.syncFolderId)
        EWSBuilder.$syncState(builder, opts.syncState) if opts.syncState
        if (mr = opts.maxChangesReturned)?
          EWSBuilder.$maxChangesReturned(builder, mr)

  syncFolderItems: (opts) ->
    @doSoapRequest @buildSyncFolderItems(opts)

  buildSyncFolderHierarchy: (opts={}) ->
    EWSBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'SyncFolderHierarchy', (builder) ->
        EWSBuilder.$folderShape(builder, opts.folderShape)
        EWSBuilder.$syncFolderId(builder, opts.syncFolderId)
        EWSBuilder.$syncState(builder, opts.syncState) if opts.syncState

  syncFolderHierarchy: (opts) ->
    @doSoapRequest @buildSyncFolderHierarchy(opts)

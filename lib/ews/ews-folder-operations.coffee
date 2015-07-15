Mixin = require 'mixto'
EWSBuilder = require '../ews-builder'
{NS_MESSAGES} = require '../ews-ns'

module.exports =
class EWSFolderOperations extends Mixin
  buildCreateFolder: (opts={}) ->
    EWSBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'CreateFolder', (builder) ->
        EWSBuilder.$parentFolderId(builder, opts.parentFolderId)
        EWSBuilder.$folders(builder, opts.folders)

  createFolder: (opts) ->
    @doSoapRequest @buildCreateFolder(opts), 'EWSFoldersResponse'

  buildDeleteFolder: (opts={}) ->
    EWSBuilder.build (builder) ->
      param = {DeleteType: opts.deleteType}
      builder.nodeNS NS_MESSAGES, 'DeleteFolder', param, (builder) ->
        EWSBuilder.$folderIds(builder, opts.folderIds)

  # `opts` {Object}
  #   `deleteType` {String} can be 'HardDelete', 'SoftDelete',
  #     'MoveToDeletedItems'
  #   `folders` {Array} or `Object`
  deleteFolder: (opts) ->
    @doSoapRequest @buildDeleteFolder(opts)

  buildFindFolder: (opts={}) ->
    EWSBuilder.build (builder) ->
      param = {Traversal: opts.traversal ? 'Shallow'}
      builder.nodeNS NS_MESSAGES, 'FindFolder', param, (builder) ->
        EWSBuilder.$folderShape(builder, opts.folderShape)
        EWSBuilder.$parentFolderIds(builder, opts.parentFolderIds)

  findFolder: (opts) ->
    @doSoapRequest @buildFindFolder(opts), 'EWSRootFolderResponse'

  buildGetFolder: (opts={}) ->
    EWSBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'GetFolder', (builder) ->
        EWSBuilder.$folderShape(builder, opts.folderShape)
        EWSBuilder.$folderIds(builder, opts.folderIds)

  getFolder: (opts) ->
    @doSoapRequest @buildGetFolder(opts), 'EWSFoldersResponse'

  buildMoveFolder: (opts={}) ->
    EWSBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'MoveFolder', (builder) ->
        EWSBuilder.$toFolderId(builder, opts.toFolderId)
        EWSBuilder.$folderIds(builder, opts.folderIds)

  moveFolder: (opts) ->
    @doSoapRequest @buildMoveFolder(opts), 'EWSFoldersResponse'

  buildUpdateFolder: (opts={}) ->
    EWSBuilder.build (builder) ->
      builder.nodeNS NS_MESSAGES, 'UpdateFolder', (builder) ->
        EWSBuilder.$folderChanges(builder, opts)

  updateFolder: (opts) ->
    @doSoapRequest @buildUpdateFolder(opts), 'EWSFoldersResponse'

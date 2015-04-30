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
    @doSoapRequest @buildCreateFolder(opts)

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

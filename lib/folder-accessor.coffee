Mixin = require 'mixto'
_ = require 'underscore'

module.exports =
class FolderAccessor extends Mixin
  # `itemId` {String} the id of item
  # `opts` {Object} more options
  #   'shape' {String} baseShape value
  getFolder: (folderId, opts={}) ->
    args = @_getFolderArgs(folderId, opts)
    @ews.getFolder(args).then (responses) -> responses[0]

  getFolders: (folderIds, opts={}) ->
    @ews.getFolder @_getFolderArgs(folderIds, opts)

  # `opts` {Object}
  #   `shape` {String} the folderShape value, default value `Default`
  #   `parent` {String} or `Object` the folderId value
  findFolders: (opts={}) ->
    @ews.findFolder @_findFoldersArgs(opts)

  createFolders: (names, opts={}) ->
    @ews.createFolder @_createFoldersArgs(names, opts)

  deleteFolders: (folderIds, deleteType) ->
    deleteType ?= 'HardDelete'
    folderIds = @_getItemIds(folderIds)
    @ews.deleteFolder {deleteType, folderIds}

  moveFolders: (folderIds, opts={}) ->
    params =
      toFolderId: @_getItemId(opts.parent)
      folderIds: @_getItemIds(folderIds)
    @ews.moveFolder params

  syncFolders: (opts={}) ->
    @ews.syncFolderHierarchy @_syncFoldersArgs(opts)

  # private methods
  _getFolderArgs: (folderId, opts) ->
    params =
      folderShape: baseShape: opts.shape ? 'Default'
      folderIds: @_getItemIds(folderId)
    _.extend params, opts

  ROOT_FOLDER_ID = {id: 'msgfolderroot', type: 'distinguished'}

  _findFoldersArgs: (opts) ->
    params =
      folderShape: baseShape: opts.shape ? 'Default'
      parentFolderIds: ROOT_FOLDER_ID
    params.parentFolderIds = @_getItemIds(opts.parent) if opts.parent
    _.extend params, opts

  _createFoldersArgs: (names, opts) ->
    params = parentFolderId: ROOT_FOLDER_ID
    params.parentFolderId = @_getItemId(opts.parent) if opts.parent
    names = [names] unless Array.isArray(names)
    params.folders = ({displayName: name} for name in names)
    _.extend(params, opts)

  _syncFoldersArgs: (opts) ->
    params =
      folderShape: baseShape: opts.shape ? 'Default'
    params.syncFolderId = @_getItemId(opts.parent) if opts.parent
    _.extend params, opts

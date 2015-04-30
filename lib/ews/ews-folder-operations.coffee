Mixin = require 'mixto'
EWSBuilder = require '../ews-builder'
{NS_MESSAGES} = require '../ews-ns'

module.exports =
class EWSFolderOperations extends Mixin
  buildCreateFolder: (opts={}) ->
    EWSBuilder.build (builder) ->
      EWSBuilder.$parentFolderId(builder, opts.parentFolderId)
      EWSBuilder.$folders(builder, opts.folders)

  createFolder: (opts) ->
    @doSoapRequest @buildCreateFolder(opts)

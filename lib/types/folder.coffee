TypeMixin = require './type-mixin'

module.exports =
class Folder
  TypeMixin.includeInto this
  constructor: (@node) ->

  @addIntTextMethods 'totalCount', 'childFolderCount', 'unreadCount'

  @addTextMethods 'folderClass', 'displayName'
  
  @addAttrMethods 'folderId', 'parentFolderId'

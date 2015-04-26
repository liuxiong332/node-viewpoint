{pascalCase} = require 'ews-util'
TypeMixin = require './type-mixin'

class Folder
  TypeMixin.includeInto this

  constructor: (@node) ->

  @addIntTextMethods 'totalCount', 'childFolderCount', 'unreadCount'
  
  @addTextMethod 'folderClass', 'displayName'

  @addAttrMethods 'folderId', 'parentFolderId'

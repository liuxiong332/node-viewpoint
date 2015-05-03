{NAMESPACES} = require './ews-ns'
Item = require './types/item'
Message = require './types/message'
Folder = require './types/folder'
Mixin = require 'mixto'

Types = {Item, Message}

class RootFolder extends Mixin
  constructor: (@rootFolderNode) ->

  totalItemsInView: ->
    parseInt @rootFolderNode.attrVal('TotalItemsInView')

  includesLastItemInRange: ->
    @rootFolderNode.attrVal('IncludesLastItemInRange') is 'true'

  items: ->
    itemsNode = @rootFolderNode.get('t:Items', NAMESPACES)
    resItems = []
    for childNode in itemsNode.childNodes()
      if (Constructor = Types[childNode.name()])?
        resItems.push new Constructor(childNode)
    resItems

  folders: ->
    foldersNode = @rootFolderNode.get('t:Folders', NAMESPACES)
    new Folder(childNode) for childNode in foldersNode.childNodes()

class Items extends Mixin
  constructor: (@itemsNode) ->

  items: ->
    resItems = []
    for childNode in @itemsNode.childNodes()
      if (Constructor = Types[childNode.name()])?
        resItems.push new Constructor(childNode)
    resItems

class Folders
  constructor: (@foldersNode) ->

  folders: ->
    new Folder(childNode) for childNode in @foldersNode.childNodes()

class ResponseParser extends Mixin
  parseResponse: ->
    @resMsgsNode = @doc.get('//m:ResponseMessages', NAMESPACES)

    _msgNode = @resMsgsNode.child(0)
    @isSuccess = _msgNode.attrVal('ResponseClass') is 'Success'
    unless @isSuccess
      @responseCode = _msgNode.get('/m:ResponseCode', NAMESPACES)
      @messageText = _msgNode.get('/m:MessageText', NAMESPACES)
    @resMsgNode = _msgNode

  ResponseMsgs = {RootFolder, Items, Folders}
  _responseNode: (resMsg) ->
    for node in resMsg.childNodes()
      nodeName = node.name()
      if (Constructor = ResponseMsgs[nodeName])?
        return new Constructor(node)

  response: ->
    @_responseNode @resMsgsNode.child(0)

  responses: ->
    @_responseNode resNode for resNode in @resMsgsNode.childNodes()

class EWSResponse
  ResponseParser.includeInto this

  constructor: (@doc) ->
    @parseResponse()

class EWSRootFolderResponse
  ResponseParser.includeInto this
  RootFolder.includeInto this

  constructor: (@doc) ->
    @parseResponse()
    RootFolder.call this, @resMsgNode.get('m:RootFolder', NAMESPACES)

class EWSItemsResponse
  ResponseParser.includeInto this
  Items.includeInto this

  constructor: (@doc) ->
    @parseResponse()
    Items.call this, @resMsgNode.get('m:Items', NAMESPACES)

class EWSFoldersResponse
  ResponseParser.includeInto this

  constructor: (@doc) ->
    @parseResponse()
    nodes = @resMsgsNode.childNodes()
    @foldersList = for node in nodes
      new Folders node.get('m:Folders', NAMESPACES)

  folders: ->
    res = []
    for node in @foldersList
      res = res.concat(node.folders())
    res

class EWSSyncResponse
  ResponseParser.includeInto this

  constructor: (@doc) ->
    @parseResponse()
    @changesNode = @resMsgNode.get('m:Changes', NAMESPACES)

  syncState: -> @resMsgNode.get('m:SyncState', NAMESPACES).text()

  includesLastItemInRange: ->
    @resMsgNode.get('m:IncludesLastItemInRange', NAMESPACES).text() is 'true'

  _getChildItems: (path) ->
    createNodes = @changesNode.find(path, NAMESPACES)
    items = []
    for createNode in createNodes
      node = createNode.child(0)
      if (Constructor = Types[node.name()])?
        items.push new Constructor(node)
    items

  creates: ->
    @_getChildItems 't:Create'

  updates: ->
    @_getChildItems 't:Update'

  deletes: ->
    @_getChildItems 't:Delete'

module.exports = {EWSResponse, EWSRootFolderResponse, EWSItemsResponse,
  EWSFoldersResponse, EWSSyncResponse}

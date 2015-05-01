should = require 'should'
FolderAccessor = require '../lib/folder-accessor'
ItemAccessor = require '../lib/item-accessor'
NS = require '../lib/ews-ns'

describe 'FolderAccessor', ->
  it '_getFolderArgs', ->
    accessor = new FolderAccessor
    ItemAccessor.extend accessor
    res = accessor._getFolderArgs 'ID', shape: 'IdOnly'
    res.folderShape.baseShape.should.equal 'IdOnly'
    res.folderIds.should.eql [{id: 'ID'}]

  it '_findFoldersArgs', ->
    accessor = new FolderAccessor
    ItemAccessor.extend accessor
    res = accessor._findFoldersArgs {shape: 'IdOnly', parent: 'ID'}
    res.folderShape.baseShape.should.equal 'IdOnly'
    res.parentFolderIds.should.eql [{id: 'ID'}]

  it '_createFoldersArgs', ->
    accessor = new FolderAccessor
    ItemAccessor.extend accessor
    res = accessor._createFoldersArgs 'name', {parent: 'ID'}
    res.folders.should.eql [{displayName: 'name'}]
    res.parentFolderId.should.eql {id: 'ID'}

  it '_syncFoldersArgs', ->
    accessor = new FolderAccessor
    ItemAccessor.extend accessor
    res = accessor._syncFoldersArgs {shape: 'IdOnly', parent: 'ID'}
    res.folderShape.baseShape.should.equal 'IdOnly'
    res.syncFolderId.should.eql {id: 'ID'}

should = require 'should'
EWSSyncOperations = require '../../lib/ews/ews-sync-operations'
{NAMESPACES} = require '../../lib/ews-ns'

describe 'EWSSyncOperations', ->
  it 'buildSyncFolderItems', ->
    operation = new EWSSyncOperations
    opts =
      itemShape: {baseShape: 'Default'}
      syncFolderId: {id: 'FolderId'}
      syncState: 'state'
      maxChangesReturned: 100
    doc = operation.buildSyncFolderItems opts

    node = doc.get('//m:SyncFolderItems', NAMESPACES)
    node.get('m:ItemShape', NAMESPACES).should.ok
    node.get('m:SyncFolderId', NAMESPACES).should.ok
    node.get('m:SyncState', NAMESPACES).should.ok
    node.get('m:MaxChangesReturned', NAMESPACES).should.ok

  it 'buildSyncFolderHierarchy', ->
    operation = new EWSSyncOperations
    opts =
      folderShape: {baseShape: 'Default'}
      syncFolderId: {id: 'ID'}
      syncState: 'state'
    doc = operation.buildSyncFolderHierarchy(opts)

    node = doc.get('//m:SyncFolderHierarchy', NAMESPACES)
    node.get('m:FolderShape', NAMESPACES).should.ok
    node.get('m:SyncFolderId', NAMESPACES).should.ok
    node.get('m:SyncState', NAMESPACES).should.ok

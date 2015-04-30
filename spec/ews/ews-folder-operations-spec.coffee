should = require 'should'
EWSFolderOperations = require '../../lib/ews/ews-folder-operations'
{NAMESPACES} = require '../../lib/ews-ns'

describe 'EWSFolderOperations', ->
  it 'buildDeleteFolder', ->
    operation = new EWSFolderOperations
    opts =
      deleteType: 'HardDelete'
      folderIds: {id: 'myId', changeKey: 'changeKey'}
    doc = operation.buildDeleteFolder opts

    folderNode = doc.get('//m:DeleteFolder', NAMESPACES)
    folderNode.attrVals().should.eql {DeleteType: 'HardDelete'}
    idsNode = folderNode.get('m:FolderIds', NAMESPACES)
    idsNode.childNodes().length.should.equal 1
    idsNode.child(0).attrVals().should.eql {Id: 'myId', ChangeKey: 'changeKey'}

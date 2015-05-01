should = require 'should'
EWSItemOperations = require '../../lib/ews/ews-item-operations'
{NAMESPACES} = require '../../lib/ews-ns'

describe 'EWSItemOperations', ->
  it 'buildFindItem', ->
    operation = new EWSItemOperations
    opts =
      itemShape: baseShape: 'idOnly'
      parentFolderIds: {id: 'myId', changeKey: 'changeKey'}
      indexedPageItemView: {maxReturned: 10, offset: 10, basePoint: 'End'}
    doc = operation.buildFindItem opts

    findItemNode = doc.get('//m:FindItem', NAMESPACES)
    findItemNode.get('m:ItemShape', NAMESPACES).should.ok
    findItemNode.get('m:ParentFolderIds', NAMESPACES).should.ok
    findItemNode.get('m:IndexedPageItemView', NAMESPACES).should.ok

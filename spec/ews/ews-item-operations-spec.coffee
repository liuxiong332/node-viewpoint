should = require 'should'
EWSItemOperations = require '../../lib/ews/ews-item-operations'
{NAMESPACES} = require '../../lib/ews-ns'

describe 'EWSItemOperations', ->
  it 'buildFindItem', ->
    operation = new EWSItemOperations
    opts =
      itemShape: baseShape: 'idOnly'
      folderIds: {id: 'myId', changeKey: 'changeKey'}
    doc = operation.buildFindItem opts
    findItemNode = doc.get('//m:FindItem', NAMESPACES)
    findItemNode.should.ok

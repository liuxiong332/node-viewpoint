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

  it 'buildGetItem', ->
    operation = new EWSItemOperations
    opts =
      itemShape: baseShape: 'IdOnly'
      itemIds: {id: 'ID'}
    doc = operation.buildGetItem(opts)

    node = doc.get('//m:GetItem', NAMESPACES)
    node.get('m:ItemShape', NAMESPACES).should.ok
    node.get('m:ItemIds', NAMESPACES).should.ok

  it 'buildCreateItem', ->
    operation = new EWSItemOperations
    opts =
      savedItemFolderId: {id: 'SAVE'}
      items: {itemClass: 'IPM.Note', subject: 'Action'}
    doc = operation.buildCreateItem opts

    node = doc.get('//m:CreateItem', NAMESPACES)
    node.get('m:SavedItemFolderId', NAMESPACES).should.ok
    node.get('m:Items', NAMESPACES).get('t:Message', NAMESPACES).should.ok

  it 'buildCopyOrMoveItem', ->
    operation = new EWSItemOperations
    opts =
      toFolderId: {id: 'To'}
      itemIds: {id: 'ITEM'}
      returnNewItemIds: true
    doc = operation.buildCopyOrMoveItem 'MoveItem', opts
    node = doc.get('//m:MoveItem', NAMESPACES)
    node.get('m:ToFolderId', NAMESPACES).should.ok
    node.get('m:ItemIds', NAMESPACES).should.ok
    node.get('m:ReturnNewItemIds', NAMESPACES).should.ok

  it 'buildDeleteItem', ->
    operation = new EWSItemOperations
    opts =
      deleteType: 'HardDelete'
      itemIds: {id: 'myId'}
    doc = operation.buildDeleteItem opts
    node = doc.get('//m:DeleteItem', NAMESPACES)
    node.attrVals().should.eql {DeleteType: 'HardDelete'}
    node.get('m:ItemIds', NAMESPACES).should.ok

  it 'buildSendItem', ->
    operation = new EWSItemOperations
    opts =
      saveItemToFolder: true
      itemIds: {id: 'ID'}
      savedItemFolderId: {id: 'Save', type: 'distinguished'}
    doc = operation.buildSendItem opts

    node = doc.get('//m:SendItem', NAMESPACES)
    node.attrVals().should.eql {SaveItemToFolder: 'true'}
    node.get('m:ItemIds', NAMESPACES).should.ok
    node.get('m:SavedItemFolderId', NAMESPACES).should.ok

  it 'buildUpdateItem', ->
    operation = new EWSItemOperations
    opts =
      messageDisposition: 'SaveOnly'
      savedItemFolderId: {id: 'ID'}
      itemChanges:
        itemId: {id: 'ID'},
        appendFields:
          fieldURI: 'item:Sensitivity',
          message: {sensitivity: 'Normal'}
    doc = operation.buildUpdateItem opts

    node = doc.get('//m:UpdateItem', NAMESPACES)
    node.attrVals().should.eql {MessageDisposition: 'SaveOnly'}
    node.get('m:ItemChanges', NAMESPACES).should.ok
    node.get('m:SavedItemFolderId', NAMESPACES).should.ok

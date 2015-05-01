should = require 'should'
ItemAccessor = require '../lib/item-accessor'
NS = require '../lib/ews-ns'

describe 'ItemAccessor', ->
  it '_getItemArgs', ->
    accessor = new ItemAccessor
    res = accessor._getItemArgs 'ID', shape: 'IdOnly'
    res.itemShape.baseShape.should.equal 'IdOnly'
    res.itemIds.should.eql [{id: 'ID'}]

    res = accessor._getItemArgs ['ID1', 'ID2'], shape: 'IdOnly'
    res.itemIds.should.eql [{id: 'ID1'}, {id: 'ID2'}]

  it '_findItemsArgs', ->
    accessor = new ItemAccessor
    res = accessor._findItemsArgs {traversal: 'IdOnly', folderId: 'HELLO'}
    res.traversal.should.equal 'IdOnly'
    res.parentFolderIds.should.eql {id: 'HELLO'}

  it '_moveCopyItemsArgs', ->
    args = new ItemAccessor()._moveCopyItemsArgs('ID1', 'Folder1')
    args.returnNewItemIds.should.equal true
    args.itemIds.should.eql [{id: 'ID1'}]
    args.toFolderId.should.eql {id: 'Folder1'}

  it '_markReadArgs', ->
    args = new ItemAccessor()._markReadArgs(['ID1', 'ID2'])
    args.itemChanges.length.should.equal 2
    args.itemChanges[0].itemId.should.eql {id: 'ID1'}
    setFields = args.itemChanges[0].setFields
    setFields.fieldURI.should.equal 'message:IsRead'
    setFields.message.should.eql {isRead: true}

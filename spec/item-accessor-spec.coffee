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

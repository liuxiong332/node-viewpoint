should = require 'should'
EwsResponse = require '../lib/ews-response'
Builder = require 'libxmljs-builder'
NS = require '../lib/ews-ns'
EWSBuilder = require '../lib/ews-builder'

NS_T = NS.NS_TYPES
NS_M = NS.NS_MESSAGES

buildRootFolder = (callback) ->
  builder = new Builder
  builder.defineNS NS.NAMESPACES

  builder.rootNS NS_M, 'ResponseMessages', (builder) ->
    params = {ResponseClass: 'Success'}
    builder.nodeNS NS_M, 'FindItemResponseMessage', params, (builder) ->
      builder.nodeNS NS_M, 'ResponseCode', 'NoError'
      params =
        TotalItemsInView: '10'
        IncludesLastItemInRange: 'true'
      builder.nodeNS NS_M, 'RootFolder', params, callback

describe 'EwsResponse', ->
  it 'RootFolder', ->
    doc = buildRootFolder (builder) ->
      params = [
        {itemId: {id: 'ID1', changeKey: 'KEY1'}}
        {itemId: {id: 'ID2', changeKey: 'KEY2'}}
      ]
      builder.nodeNS NS_T, 'Items', (builder) ->
        EWSBuilder.$message(builder, itemInfo) for itemInfo in params

    res = new EwsResponse(doc)
    res.isSuccess.should.ok
    resMsg = res.response()
    resMsg.totalItemsInView().should.equal 10
    resMsg.includesLastItemInRange().should.equal true
    items = resMsg.items()
    items.length.should.equal 2
    items[0].itemId().should.eql {id: 'ID1', changeKey: 'KEY1'}
    items[1].itemId().should.eql {id: 'ID2', changeKey: 'KEY2'}

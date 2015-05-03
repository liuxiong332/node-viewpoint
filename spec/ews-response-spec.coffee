should = require 'should'
{EWSResponse, EWSSyncResponse} = require '../lib/ews-response'
Builder = require 'libxmljs-builder'
NS = require '../lib/ews-ns'
EWSBuilder = require '../lib/ews-builder'

NS_T = NS.NS_TYPES
NS_M = NS.NS_MESSAGES

describe 'EWSResponse', ->
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

  it 'RootFolder', ->
    doc = buildRootFolder (builder) ->
      params = [
        {itemId: {id: 'ID1', changeKey: 'KEY1'}}
        {itemId: {id: 'ID2', changeKey: 'KEY2'}}
      ]
      builder.nodeNS NS_T, 'Items', (builder) ->
        EWSBuilder.$message(builder, itemInfo) for itemInfo in params

    res = new EWSResponse(doc)
    res.isSuccess.should.ok
    resMsg = res.response()
    resMsg.totalItemsInView().should.equal 10
    resMsg.includesLastItemInRange().should.equal true
    items = resMsg.items()
    items.length.should.equal 2
    items[0].itemId().should.eql {id: 'ID1', changeKey: 'KEY1'}
    items[1].itemId().should.eql {id: 'ID2', changeKey: 'KEY2'}

describe 'EWSSyncResponse', ->
  buildSyncResponse = ->
    builder = new Builder
    builder.defineNS NS.NAMESPACES

    builder.rootNS NS_M, 'ResponseMessages', (builder) ->
      params = ResponseClass: 'Success'
      builder.nodeNS NS_M, 'SyncResponseMessage', params, (builder) ->
        builder.nodeNS NS_M, 'ResponseCode', 'NoError'
        builder.nodeNS NS_M, 'SyncState', 'State'
        builder.nodeNS NS_M, 'IncludesLastItemInRange', 'true'
        builder.nodeNS NS_M, 'Changes', (builder) ->
          builder.nodeNS NS_T, 'Create', (builder) ->
            EWSBuilder.$message(builder, {subject: 'CREATE'})
          builder.nodeNS NS_T, 'Update', (builder) ->
            EWSBuilder.$message(builder, {subject: 'UPDATE'})
          builder.nodeNS NS_T, 'Delete', (builder) ->
            EWSBuilder.$message(builder, {subject: 'DELETE'})

  it 'changes', ->
    res = new EWSSyncResponse buildSyncResponse()
    res.isSuccess.should.ok
    res.syncState().should.equal 'State'
    res.includesLastItemInRange().should.ok
    res.creates().length.should.equal 1
    res.updates().length.should.equal 1
    res.deletes().length.should.equal 1

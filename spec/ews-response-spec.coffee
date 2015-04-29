should = require 'should'
EwsResponse = require '../lib/ews-response'
Builder = require 'libxmljs-builder'
NS = require '../lib/ews-ns'

resRootFolder = ->
  builder = new Builder
  builder.defineNS NS.NAMESPACES

  NS_M = NS.NS_MESSAGES
  params = {ResponseClass: 'Success'}
  builder.rootNS NS_M, 'ResponseMessages', (builder) ->
    builder.nodeNS NS_M, 'FindItemResponseMessage', params, (builder) ->
      builder.nodeNS NS_M, 'ResponseCode', 'NoError'
      params =
        TotalItemsInView: '10'
        IncludesLastItemInRange: 'true'
      builder.nodeNS NS_M, 'RootFolder', params, (builder) ->
        builder.nodeNS NS.NS_TYPES, 'Items'

describe 'EwsResponse', ->
  it 'RootFolder', ->
    doc = resRootFolder()
    res = new EwsResponse(doc)
    res.isSuccess.should.ok
    resMsg = res.response()
    resMsg.totalItemsInView().should.equal 10
    resMsg.includesLastItemInRange().should.equal true
    resMsg.items().should.ok

should = require 'should'
EWSClient = require '../../lib/ews-client'
config = require './config.json'

describe 'ews operations integration', ->

  TRASH_ID = {id: 'deleteditems', type: 'distinguished'}
  [client, itemIds] = []

  beforeEach ->
    opts =
      rejectUnauthorized: false
      proxy: {host: 'localhost', port: 8888}
      agent: new require('http').Agent({keepAlive: true})
    client = new EWSClient config.username, config.password, config.url, opts

  it 'findItems', (done) ->
    params =
      shape: 'IdOnly'
      folderId: TRASH_ID
      indexedPageItemView: {offset: 0, maxReturned: 2}
    client.findItems(params).then (res) ->
      itemArray = res.response().items()
      itemArray.length.should.equal 2
      Object.keys(itemArray[0].itemId()).should.eql ['id', 'changeKey']

      client.getItem(itemArray[0].itemId())
      .then (res) ->
        itemInfos = res.response().items()
        itemInfos.length.should.equal 1
        itemInfos[0].itemId().should.eql itemArray[0].itemId()
        done()
      .catch (err) -> done(err)

should = require 'should'
EWSClient = require '../../lib/ews-client'
config = require './config.json'

describe.skip 'ews operations integration', ->

  TRASH_ID = {id: 'deleteditems', type: 'distinguished'}
  client = null

  beforeEach ->
    opts =
      rejectUnauthorized: false
      proxy: {host: 'localhost', port: 8888}
      agent: new require('http').Agent({keepAlive: true})
    client = new EWSClient config.username, config.password, config.url, opts

  describe 'items', ->
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

    it 'saveItems & deleteItems', (done) ->
      params =
        folderId: TRASH_ID
        items:
          subject: 'Hello, World', body: '<body>Hello</body>'
      client.saveItems(params).then (res) ->
        items = res.response().items()
        items[0].itemId().should.ok

        client.deleteItems items[0].itemId()
        .then -> done()
        .catch (err) -> done(err)

    it 'syncItems', (done) ->
      client.syncItems({folderId: TRASH_ID, maxReturned: 2})
      .then (res) ->
        res.syncState().should.ok
        done()
      .catch (err) -> done(err)

  describe 'folders', ->
    it 'createFolder', (done) ->
      client.createFolders(['TestFolder3', 'TestFolder4'])
      .then (res) ->
        # client.deleteFolders res.

        done()
      .catch (err) -> done(err)

should = require 'should'
Item = require '../lib/types/item'
Builder = require 'libxmljs-builder'
NS = require '../lib/ews-ns'

describe 'Item', ->
  generate = ->
    builder = new Builder
    builder.defineNS NS.NAMESPACES
    NS_T = NS.NS_TYPES
    builder.rootNS NS_T, 'Item', (builder) ->
      builder.nodeNS NS_T, 'MimeContent', new Buffer('ABCD').toString('base64')
      builder.nodeNS NS_T, 'Body', {BodyType: 'HTML'}, 'Hello'
      builder.nodeNS NS_T, 'Size', '12'
      builder.nodeNS NS_T, 'IsSubmitted', 'true'
      builder.nodeNS NS_T, 'ItemClass', 'class'
      builder.nodeNS NS_T, 'ItemId', {Id: 'id', ChangeKey: 'ChangeKey'}

  it 'test all of instance methods', ->
    doc = generate()
    item = new Item doc.root()
    item.mimeContent().content.toString().should.equal 'ABCD'
    item.size().should.equal 12
    item.body().should.eql {bodyType: 'html', content: 'Hello'}
    item.isSubmitted().should.equal true
    item.itemClass().should.equal 'class'
    item.itemId().should.eql {id: 'id', changeKey: 'ChangeKey'}

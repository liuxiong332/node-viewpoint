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
      builder.nodeNS NS_T, 'MimeContent', new Buffer('NIme', 'base64').toString()
      builder.nodeNS NS_T, 'Body', {BodyType: 'HTML'}, 'Hello World!'
      builder.nodeNS NS_T, 'Size', '12'
      builder.nodeNS NS_T, 'IsSubmitted', 'true'
      builder.nodeNS NS_T, 'itemClass', 'class'
      builder.nodeNS NS_T, 'itemId', {Id: 'id', ChangeKey: 'ChangeKey'}

  it 'test all of instance methods', ->
    doc = generate()
    item = new Item doc.root()
    console.log 'string' +  item.getChildNode('MimeContent').attrVal  # 'CharacterSet'
    item.size().should.equal 12

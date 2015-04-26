should = require 'should'
Message = require '../lib/types/message'
Builder = require 'libxmljs-builder'
NS = require '../lib/ews-ns'

describe 'Message', ->
  generate = ->
    builder = new Builder
    builder.defineNS NS.NAMESPACES
    NS_T = NS.NS_TYPES
    builder.rootNS NS_T, 'Message', (builder) ->
      builder.nodeNS NS_T, 'Sender', (builder) ->
        builder.nodeNS NS_T, 'Mailbox', (builder) ->
          builder.nodeNS NS_T, 'Name', 'Mike'
          builder.nodeNS NS_T, 'EmailAddress', 'Mike@pp.com'
          builder.nodeNS NS_T, 'ItemId', {Id: 'id', ChangeKey: 'changeKey'}

  it 'test instance methods', ->
    doc = generate()
    item = new Message doc.root()
    sender = item.sender()
    sender.name().should.equal 'Mike'
    sender.emailAddress().should.equal 'Mike@pp.com'
    sender.itemId().should.eql {id: 'id', changeKey: 'changeKey'}

should = require 'should'
Attachment = require '../lib/types/attachment'
Builder = require 'libxmljs-builder'
NS = require '../lib/ews-ns'

describe 'Attachment', ->
  generate = ->
    builder = new Builder
    builder.defineNS NS.NAMESPACES
    NS_T = NS.NS_TYPES
    builder.rootNS NS_T, 'ItemAttachment', (builder) ->
      builder.nodeNS NS_T, 'AttachmentId', {Id: 'myId'}
      builder.nodeNS NS_T, 'Name', 'Name'
      builder.nodeNS NS_T, 'ContentType', 'ContentType'
      builder.nodeNS NS_T, 'ContentId', 'ContentId'
      builder.nodeNS NS_T, 'ContentLocation', 'ContentLocation'
      builder.nodeNS NS_T, 'Size', '100'
      builder.nodeNS NS_T, 'IsInline', 'true'
      fileContent = new Buffer('STRM', 'base64').toString()
      builder.nodeNS NS_T, 'Content', fileContent

  it 'test all of instance methods', ->
    doc = generate()
    attachment = new Attachment doc.root()
    attachment.attachmentId().should.equal 'myId'
    attachment.size().should.equal 100
    attachment.isInline().should.equal true
    attachment.name().should.equal 'Name'
    attachment.contentType().should.equal 'ContentType'
    attachment.contentId().should.equal 'ContentId'
    attachment.contentLocation().should.equal 'ContentLocation'
    attachment.content().should.equal 'STRM'
    attachment.type().should.equal 'item'

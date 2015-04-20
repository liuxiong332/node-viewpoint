should = require 'should'
EwsBuilder = require '../lib/ews-builder'

describe 'EwsBuilder', ->
  getNSHref = (node) ->
    node.namespace().href()

  it '@build', ->
    doc = EwsBuilder.build()
    doc.should.ok
    SOAP_HREF = EwsBuilder.NAMESPACES[EwsBuilder.NS_SOAP]
    getNSHref(doc.root()).should.equal SOAP_HREF
    doc.root().name().should.equal 'Envelope'

    bodyNode = doc.childNodes()[0]
    getNSHref(bodyNode).should.equal SOAP_HREF

  it '@buildItemShape', ->
    itemShape =
      baseShape: 'idOnly'
      includeMimeContent: true
      bodyType: 'html'

    doc = EwsBuilder.build (builder) ->
      EwsBuilder.buildItemShape itemShape, builder

    itemShapeNode = doc.get('//m:ItemShape', EwsBuilder.NAMESPACES)
    itemShapeNode.should.ok
    childNodes = itemShapeNode.childNodes()
    childNodes.length.should.equal 3

    childNodes[0].text().should.equal 'IdOnly'
    childNodes[1].text().should.equal 'true'
    childNodes[2].text().should.equal 'HTML'

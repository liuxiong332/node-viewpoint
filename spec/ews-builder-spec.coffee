should = require 'should'
EWSBuilder = require '../lib/ews-builder'
NS = require '../lib/ews-ns'

describe 'EWSBuilder', ->
  getNSHref = (node) ->
    node.namespace().href()

  it '@build', ->
    doc = EWSBuilder.build()
    doc.should.ok
    SOAP_HREF = NS.NAMESPACES[NS.NS_SOAP]
    getNSHref(doc.root()).should.equal SOAP_HREF
    doc.root().name().should.equal 'Envelope'

    bodyNode = doc.childNodes()[0]
    getNSHref(bodyNode).should.equal SOAP_HREF

  it '@$itemShape', ->
    itemShape =
      baseShape: 'idOnly'
      includeMimeContent: true
      bodyType: 'HTML'

    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$itemShape builder, itemShape

    itemShapeNode = doc.get('//m:ItemShape', NS.NAMESPACES)
    itemShapeNode.should.ok
    childNodes = itemShapeNode.childNodes()
    childNodes.length.should.equal 3

    childNodes[0].text().should.equal 'IdOnly'
    childNodes[1].text().should.equal 'true'
    childNodes[2].text().should.equal 'HTML'

  it '@$parentFolderIds', ->
    folderIds = [
      {id: 'ID1', changeKey: 'KEY1', type: 'distinguished'}
      {id: 'ID2', changeKey: 'KEY2'}
    ]
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$parentFolderIds builder, folderIds

    folderIdsNode = doc.get('//m:ParentFolderIds', NS.NAMESPACES)
    childNodes = folderIdsNode.childNodes()
    childNodes.length.should.equal 2
    childNodes[0].name().should.equal 'DistinguishedFolderId'
    childNodes[0].attrVals().should.eql {Id: 'ID1', ChangeKey: 'KEY1'}
    childNodes[1].name().should.equal 'FolderId'
    childNodes[1].attrVals().should.eql {Id: 'ID2', ChangeKey: 'KEY2'}

  it '@$isDraft', ->
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$isDraft builder, true
    node = doc.get('//t:IsDraft', NS.NAMESPACES)
    node.text().should.equal 'true'

  it '@$name', ->
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$name builder, 'NAME'
    node = doc.get('//t:Name', NS.NAMESPACES)
    node.text().should.equal 'NAME'

  it '@$dateTimeSent', ->
    date = new Date
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$dateTimeSent builder, date
    node = doc.get('//t:DateTimeSent', NS.NAMESPACES)
    node.text().should.equal date.toISOString()

  it '@$bodyType', ->
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$bodyType builder, 'HTML'
    node = doc.get('//t:BodyType', NS.NAMESPACES)
    node.text().should.equal 'HTML'

  it '@$body', ->
    param = {bodyType: 'HTML', content: 'HELLO'}
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$body builder, param
    node = doc.get('//t:Body', NS.NAMESPACES)
    node.text().should.equal 'HELLO'
    node.attrVals().should.eql {BodyType: 'HTML'}

  it '@$mimeContent', ->
    content = new Buffer('HELLO WORLD')
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$mimeContent builder, content
    node = doc.get('//t:MimeContent', NS.NAMESPACES)
    new Buffer(node.text(), 'base64').compare(content).should.equal 0

  it '@$itemId', ->
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$itemId builder, {id: 'ID', changeKey: 'ChangeKey'}
    node = doc.get('//t:ItemId', NS.NAMESPACES)
    node.attrVals().should.eql {Id: 'ID', ChangeKey: 'ChangeKey'}

  it '@$sender', ->
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$sender builder, {name: 'NAME', emailAddress: 'ADDRESS'}
    node = doc.get('//t:Sender', NS.NAMESPACES)
    node.childNodes().length.should.equal 1
    mailNode = node.child(0)
    mailNode.get('t:Name', NS.NAMESPACES).text().should.equal 'NAME'
    mailNode.get('t:EmailAddress', NS.NAMESPACES).text().should.equal 'ADDRESS'

  it '@$content', ->
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$content builder, new Buffer('HELLO')
    text = doc.get('//t:Content', NS.NAMESPACES).text()
    new Buffer(text, 'base64').toString().should.equal 'HELLO'

  it '@$itemAttachment', ->
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$itemAttachment(builder, {name: 'NAME', contentType: 'TYPE'})
    node = doc.get('//t:ItemAttachment', NS.NAMESPACES)
    node.childNodes().length.should.equal 2
    node.get('t:Name', NS.NAMESPACES).text().should.equal 'NAME'
    node.get('t:ContentType', NS.NAMESPACES).text().should.equal 'TYPE'

  it '@$additionalProperties', ->
    properties = ['PROP1', 'PROP2']
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$additionalProperties(builder, properties)
    node = doc.get('//t:AdditionalProperties', NS.NAMESPACES)
    node.childNodes().length.should.equal 2
    node.child(0).attrVals().should.eql {FieldURI: 'PROP1'}
    node.child(1).attrVals().should.eql {FieldURI: 'PROP2'}

  it '@$folderShape', ->
    param =
      baseShape: 'IdOnly'
      additionalProperties: ['PROP1', 'PROP2']
    doc = EWSBuilder.build (builder) ->
      EWSBuilder.$folderShape(builder, param)
    node = doc.get('//m:FolderShape', NS.NAMESPACES)
    node.get('t:BaseShape', NS.NAMESPACES).text().should.equal 'IdOnly'
    apNode = node.get('t:AdditionalProperties', NS.NAMESPACES)
    apNode.childNodes().length.should.equal 2

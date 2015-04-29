should = require 'should'
EwsBuilder = require '../lib/ews-builder'
NS = require '../lib/ews-ns'

describe 'EwsBuilder', ->
  getNSHref = (node) ->
    node.namespace().href()

  it '@build', ->
    doc = EwsBuilder.build()
    doc.should.ok
    SOAP_HREF = NS.NAMESPACES[NS.NS_SOAP]
    getNSHref(doc.root()).should.equal SOAP_HREF
    doc.root().name().should.equal 'Envelope'

    bodyNode = doc.childNodes()[0]
    getNSHref(bodyNode).should.equal SOAP_HREF

  it '@itemShape', ->
    itemShape =
      baseShape: 'idOnly'
      includeMimeContent: true
      bodyType: 'html'

    doc = EwsBuilder.build (builder) ->
      EwsBuilder.itemShape builder, itemShape

    itemShapeNode = doc.get('//m:ItemShape', NS.NAMESPACES)
    itemShapeNode.should.ok
    childNodes = itemShapeNode.childNodes()
    childNodes.length.should.equal 3

    childNodes[0].text().should.equal 'IdOnly'
    childNodes[1].text().should.equal 'true'
    childNodes[2].text().should.equal 'HTML'

  it '@parentFolderIds', ->
    folderIds = [
      {id: 'ID1', changeKey: 'KEY1', type: 'distinguished'}
      {id: 'ID2', changeKey: 'KEY2'}
    ]
    doc = EwsBuilder.build (builder) ->
      EwsBuilder.parentFolderIds builder, folderIds

    folderIdsNode = doc.get('//m:ParentFolderIds', NS.NAMESPACES)
    childNodes = folderIdsNode.childNodes()
    childNodes.length.should.equal 2
    childNodes[0].name().should.equal 'DistinguishedFolderId'
    childNodes[0].attrVals().should.eql {Id: 'ID1', ChangeKey: 'KEY1'}
    childNodes[1].name().should.equal 'FolderId'
    childNodes[1].attrVals().should.eql {Id: 'ID2', ChangeKey: 'KEY2'}

TypeMixin = require '../lib/types/type-mixin'
EWSItemOperations = require '../lib/ews/ews-item-operations'
{NAMESPACES} = require '../lib/ews-ns'

describe 'TypeMixin', ->
  doc = null
  beforeEach ->
    opts =
      itemShape: baseShape: 'idOnly'
      parentFolderIds: {id: 'myId', changeKey: 'changeKey'}
    doc = (new EWSItemOperations).buildFindItem opts

  it '@addTextMethods', ->
    class FakeClass
      TypeMixin.includeInto this
      constructor: ->
        @node = doc.get('//m:ItemShape', NAMESPACES)
      @addTextMethods 'baseShape'

    instance = new FakeClass
    instance.baseShape().should.eql 'IdOnly'

  it '@addAttrMethods', ->
    class FakeClass
      TypeMixin.includeInto this
      constructor: -> @node = doc.get('//m:ParentFolderIds', NAMESPACES)
      @addAttrMethods 'folderId'
    instance = new FakeClass
    instance.folderId().should.eql {id: 'myId', changeKey: 'changeKey'}

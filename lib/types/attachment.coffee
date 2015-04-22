{pascalCase} = require 'ews-util'

class Attachment
  constructor: (@node) ->

  attachmentId: ->
    idNode = @node.get('AttachmentId')
    idNode.attrVal('Id') if idNode

  name: ->

EWSItemOperations = require './ews/ews-item-operations'
EWSFolderOperations = require './ews/ews-folder-operations'
EWSSyncOperations = require './ews/ews-sync-operations'
RequestClient = require './http/request-client'
EWSRes = require './ews-response'
libxml = require 'libxmljs'

EWSResponse = EWSRes.EWSResponse

class SoapError extends Error
  constructor: ->
    err = super
    @name = 'SoapError'
    @stack = err.stack
    @message = err.message

module.exports =
class EWSWebService
  EWSItemOperations.includeInto(this)
  EWSFolderOperations.includeInto(this)
  EWSSyncOperations.includeInto(this)
  RequestClient.includeInto(this)

  constructor: ->
    RequestClient.apply(this, arguments)

  doSoapRequest: (doc, resName) ->
    @send(doc.toString(false)).then (res) ->
      Response = if resName then EWSRes[resName] else EWSResponse
      ewsRes = new Response libxml.parseXmlString(res.body)
      unless ewsRes.isSuccess
        param =
          responseCode: ewsRes.responseCode
          messageText: ewsRes.messageText
        throw new SoapError "SOAP Error:#{JSON.stringify(param, null, 2)}"
      ewsRes

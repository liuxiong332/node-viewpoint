EWSItemOperations = require './ews/ews-item-operations'
RequestClient = require './http/request-client'
EWSResponse = require './ews-response'
libxml = require 'libxmljs'

class SoapError extends Error
  constructor: ->
    err = super
    @name = 'SoapError'
    @stack = err.stack
    @message = err.message

module.exports =
class EWSWebService
  EWSItemOperations.includeInto(this)
  RequestClient.includeInto(this)

  constructor: ->
    RequestClient.apply(this, arguments)

  doSoapRequest: (doc) ->
    @send(doc.toString(false)).then (res) ->
      ewsRes = new EWSResponse libxml.parseXmlString(res.body)
      unless ewsRes.isSuccess
        param =
          responseCode: ewsRes.responseCode
          messageText: ewsRes.messageText
        throw new SoapError "SOAP Error:#{JSON.stringify(param, null, 2)}"
      ewsRes.responses

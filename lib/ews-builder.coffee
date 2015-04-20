Builder = require 'libxmljs-builder'
_ = require 'underscore'

pascalCase = (str) -> str[0].toUpperCase() + str.slice(1)

module.exports =
class EwsBuilder
  @build: (bodyCallback) ->
    @builder = new Builder
    @builder.defineNS EwsBuilder.NAMESPACES
    @builder.rootNS EwsBuilder.NS_SOAP, 'Envelope', (builder) ->
      builder.nodeNS EwsBuilder.NS_SOAP, 'Body', bodyCallback

  @buildItemShape: (itemShape, builder) ->
    NS_T = EwsBuilder.NS_TYPES
    builder.nodeNS EwsBuilder.NS_MESSAGES, 'ItemShape', (builder) =>
      if itemShape.baseShape?
        builder.nodeNS NS_T, 'BaseShape', pascalCase itemShape.baseShape

      iMC = itemShape.includeMimeContent
      builder.nodeNS NS_T, 'IncludeMimeContent', iMC.toString() if iMC?

      if (bodyType = itemShape.bodyType)?
        builder.nodeNS NS_T, 'BodyType', @convertBodyType(itemShape.bodyType)

  @convertBodyType: (body) ->
    switch body
      when 'html' then 'HTML'
      when 'text' then 'Text'
      when 'best' then 'Best'
      else bodyType

  @NS_SOAP: 'soap'
  @NS_TYPES: 't'
  @NS_MESSAGES: 'm'
  @NAMESPACES:
    soap: 'http://schemas.xmlsoap.org/soap/envelope/'
    t: 'http://schemas.microsoft.com/exchange/services/2006/types'
    m: 'http://schemas.microsoft.com/exchange/services/2006/messages'

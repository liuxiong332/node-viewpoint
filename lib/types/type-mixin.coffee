Mixin = require 'mixto'
{pascalCase, camelCase} = require '../ews-util'
{NAMESPACES} = require '../ews-ns'

module.exports =
class TypeMixin extends Mixin

  getChildNode: (methodName) ->
    @node.get "t:#{pascalCase(methodName)}", NAMESPACES

  # add methods into the class by analyze the DOM textContent
  @addTextMethods: (methods...) ->
    methods.forEach (methodName) =>
      @prototype[methodName] = ->
        element = @getChildNode(methodName)
        element.text() if element

  # add methods into the class by analyze the DOM attributes and textContent
  @addAttrMethods: (methods...) ->
    methods.forEach (methodName) =>
      @prototype[methodName] = ->
        element = @getChildNode(methodName)
        return null unless element
        res = {}
        for attrKey, attrVal of element.attrVals()
          res[camelCase(attrKey)] = attrVal
        if (text = element.text())
          res.content = text
        res
#

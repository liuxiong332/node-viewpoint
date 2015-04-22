Mixin = require 'mixto'
{pascalCase, camelCase} = require '../ews-util'
{NAMESPACES} = require '../ews-ns'

module.exports =
class TypeMixin extends Mixin
  getByName = (node, methodName) ->
    node.get "t:#{pascalCase(methodName)}", NAMESPACES

  @addTextMethods: (methods...) ->
    for methodName in methods
      @prototype[methodName] = ->
        element = getByName(@node, methodName)
        element.text() if element

  @addAttrMethods: (methods...) ->
    for methodName in methods
      @prototype[methodName] = ->
        element = getByName(@node, methodName)
        return null unless element
        res = {}
        for attrKey, attrVal of element.attrVals()
          res[camelCase(attrKey)] = attrVal
        if (text = element.text())
          res.content = text
        res
#

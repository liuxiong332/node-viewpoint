Mixin = require 'mixto'
{pascalCase, camelCase} = require '../ews-util'

module.exports =
class TypeMixin extends Mixin
  @addTextMethods: (methods...) ->
    for methodName in methods
      @prototype[methodName] = ->
        element = @node.get pascalCase(methodName)
        element.text() if element

  @addAttrMethods: (methods...) ->
    for methodName in methods
      @prototype[methodName] = ->
        element = @node.get pascalCase(methodName)
        return null unless element
        res = {}
        for attrKey, attrVal of element.attrVals()
          res[camelCase(attrKey)] = attrVal
        res.content = element.text()
        res

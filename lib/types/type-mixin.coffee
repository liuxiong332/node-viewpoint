Mixin = require 'mixto'
{pascalCase, camelCase} = require '../ews-util'
{NAMESPACES} = require '../ews-ns'

module.exports =
class TypeMixin extends Mixin

  getChildNode: (methodName) ->
    @node.get "t:#{pascalCase(methodName)}", NAMESPACES

  getChildValue: (methodName) ->
    element = @getChildNode(methodName)
    element.text() if element

  getChildIntValue: (methodName) ->
    element = @getChildNode(methodName)
    parseInt element.text() if element

  getChildBoolValue: (methodName) ->
    element = @getChildNode(methodName)
    element.text() is 'true' if element

  getChildTimeValue: (methodName) ->
    element = @getChildNode(methodName)
    element.text() if element

  @addBoolTextMethods: (methods...) ->
    methods.forEach (methodName) =>
      @prototype[methodName] = -> @getChildBoolValue(methodName)

  @addIntTextMethods: (methods...) ->
    methods.forEach (methodName) =>
      @prototype[methodName] = -> @getChildIntValue(methodName)

  # add methods into the class by analyze the DOM textContent
  @addTextMethods: (methods...) ->
    methods.forEach (methodName) =>
      @prototype[methodName] = -> @getChildValue(methodName)

  @addTimeTextMethods: (methods...) ->
    methods.forEach (methodName) =>
      @prototype[methodName] = -> @getChildTimeValue(methodName)

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

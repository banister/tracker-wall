Element = require './element'

class Message
  constructor: (options) ->
    @page = options.page
    @element = options.element
    @tagName = @element.tagName

    @domMappings = options.domMappings
    @fragment = options.fragment

    @timestamp = +new Date

  category: ->
    @domMappings[@tagName] && @domMappings[@tagName][@element.type]

  classesOf: (element = @element) ->
    Element.classesOf element.base

  eventType: ->
    @element.type

  fullName: =>
    path = "#{@element.tagName}"
    path

  id: ->
    @element.id

  recursivelyWalkUp: (elements = [], element = @element) ->
    if element
      if element.id is ""
        selectorPath = @selectorPathFor element
        elements.unshift selectorPath if @selectorWorthy? selectorPath
        @recursivelyWalkUp elements, new Element element.base.parentNode
      else if element.base != @fragment
        elements.unshift "#{element.tagName}##{element.id}"
    elements

  selector: ->
    @recursivelyWalkUp().join ' '

  selectorPathFor: (element = @element) ->
    classArray = @classesOf(element)

    path = element.tagName
    path += "##{element.id}" if element.id
    path += ".#{classArray.join('.')}" if classArray.length > 0
    path

  selectorWorthy: (selectorPath) ->
    selectorPath != 'DIV' && selectorPath != 'SMALL' && selectorPath != 'P' && selectorPath != 'LABEL'

  text: ->
    @element.base.text

  toObject: ->
    message =
      category: @category()
      classes: @classesOf()
      element: @tagName
      eventType: @eventType()
      fullName: @fullName()
      id: @id()
      page: @page
      selector: @selector()
      text: @text()
      timestamp: @timestamp
      value: @value()

  value: ->
    @element.base.value

module.exports = Message

DOMMappings = require './dom_mappings'
Page = require './page'
Element = require './element'
Message = require './message'

class Spy
  constructor: (options = {}) ->
    @domMappings = options.domMappings || DOMMappings
    @page = new Page
    @handle = options.handler || (message) ->
      console.log "A message was handled: #{message}"

  inform: (event) =>
    message = new Message
      domMappings: @domMappings
      page: @page
      fragment: @fragment
      element: new Element event.target, event.type
    @handle message

  listen: (selector) ->
    @fragment = document.querySelector (selector || 'body')

    config = {
      attributes: true, childList: true, characterData: true, subtree: true
    }

    observer = new MutationObserver @mutationHandler
    observer.observe @fragment, config

  mutationHandler: (mutations) =>
    for mutation in mutations
      @register mutation.addedNodes

  register: (nodes) =>
    for element in nodes
      if element.childNodes.length > 0
        @register element.childNodes

      for event, category of (@registerableMappings element)
        element.addEventListener event, @inform, false

    nodes

  matchSelector: (element, mapping) ->
    if mapping.class
      mapping.class in element.className.split(' ')
    else
      true

  registerableMappings: (element) =>
    mapping = @domMappings[element.tagName]

    if mapping && @matchSelector element, mapping
      mapping.events
    else
      {}

module.exports = Spy

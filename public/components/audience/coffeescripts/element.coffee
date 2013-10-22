class Element
  constructor: (element, type) ->
    @base            = element
    @id              = element.id
    @classes         = @constructor.classesOf element
    @tagName         = element.tagName
    @type            = type

  @classesOf: (element) ->
    classes = element.classList.toString().trim()

    if classes is ""
      []
    else
      classes.split(' ')

module.exports = Element

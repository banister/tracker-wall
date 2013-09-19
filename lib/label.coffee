class Label
  constructor: (options) ->
    for name, value of options
      @[name] = value

module.exports = Label

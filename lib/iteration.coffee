class Iteration
  constructor: (options) ->
    for name, value of options
      if @name is "stories"
        @[name] = []

        for storyOptions in value
          @[name] << new Story storyOptions
      else
        @[name] = value

module.exports = Iteration

Tracker = require "./tracker"
Story = require "./story"

tracker = new Tracker "978f492d5d2a080ced6e8fbb801700fc"

class Project
  constructor: (options) ->
    for name, value of options
      @[name] = value

  stories: () ->
    tracker.stories @id,
      failure: (error) ->
        console.log error
      success: (jsonString) ->
        list = for options in JSON.parse jsonString
          story = new Story options
          console.log story unless story.isBug()

module.exports = Project

Story = require "./story"
Label = require "./label"

class Iteration
  constructor: (options) ->
    for name, value of options
      if name is "stories"
        @[name] = []

        for storyOptions in value
          @[name].push new Story storyOptions
      else if name is "labels"
        @[name] = []

        for labelOptions in value
          @[name].push new Label labelOptions
      else
        @[name] = value

  notStartedStories: () ->
    story for story in @stories when story.notStarted()

  blockedDevelopmentStories: () ->
    story for story in @stories when story.inDevelopment() and story.blocked()

  developmentStories: () ->
    story for story in @stories when story.inDevelopment() and !story.blocked()

  blockedDeliveredStories: () ->
    story for story in @stories when story.delivered() and story.blocked()

  deliveredStories: () ->
    story for story in @stories when story.delivered() and !story.blocked()

  completedStories: () ->
    story for story in @stories when story.accepted()

module.exports = Iteration

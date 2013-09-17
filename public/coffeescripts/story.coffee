class Story
  BUG = "bug"
  CHORE = "chore"
  FEATURE = "feature"

  constructor: (options) ->
    for name, value of options
      @[name] = value

  bug: ->
    @story_type is BUG

  chore: ->
    @story_type is CHORE

  feature: ->
    @story_type is FEATURE

module.exports = Story

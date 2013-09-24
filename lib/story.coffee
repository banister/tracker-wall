class Story
  BUG = "bug"
  CHORE = "chore"
  FEATURE = "feature"
  RELEASE = "release"

  UNSTARTED = "unstarted"
  STARTED = "started"
  FINISHED = "finished"
  DELIVERED = "delivered"
  ACCEPTED = "accepted"

  BLOCKED = "blocked"

  constructor: (options) ->
    for name, value of options
      @[name] = value

  bug: () ->
    @story_type is BUG

  chore: ->
    @story_type is CHORE

  feature: ->
    @story_type is FEATURE

  release: ->
    @story_type is RELEASE

  theType: ->
    @blocked? ? BLOCKED : @story_type

  notStarted: ->
    @current_state is UNSTARTED

  inDevelopment: ->
    @current_state is STARTED or @current_state is FINISHED

  delivered: ->
    @current_state is DELIVERED

  accepted: ->
    @current_state is ACCEPTED

  blocked: ->
    labels = label for label in @labels when label.name is BLOCKED
    !!labels

  ownedBy: (membership) ->
    membership.person.id == @owned_by_id

  personColor: ->
    if @owned_by_id == 892027
      "phill"
    else if @owned_by_id == 764173
      "robert"
    else if @owned_by_id == 1072639
      "gracie"
    else if @owned_by_id == 1088828
      "joshua"
    else if @owned_by_id == 909513
      "dustin"

  personName: (memberships) ->
    for number, membership of memberships when membership.person.id == @owned_by_id
      membership.person.name

module.exports = Story

class Project extends Backbone.Model
  urlRoot: "https://www.pivotaltracker.com/services/v5/projects"

  initialize: (options) ->
    @constructor.__super__.initialize.apply @, [options]
    @iterationsCollection = new IterationsCollection @

  fetchIterations: (options) ->
    @iterationsCollection.fetch {data: {token: TrackerApplication.token(), scope: options['scope']}}


class ProjectsCollection extends Backbone.Collection
  model: Project
  url: "https://www.pivotaltracker.com/services/v5/projects"


class Iteration extends Backbone.Model
  availableStories: () ->
    _.map get('stories'), (story) ->
      new Story(story.toJSON())


class IterationsCollection extends Backbone.Collection
  model: Iteration
  url: "https://www.pivotaltracker.com/services/v5/projects/:project_id/iterations"

  initialize: (project) ->
    @project = project
    @url = @url.replace ":project_id", project.get('id')


class Story extends Backbone.Model
  BUG = "bug"
  CHORE = "chore"
  FEATURE = "feature"
  RELEASE = "release"

  UNSTARTED = "unstarted"
  STARTED = "started"
  FINISHED = "finished"
  DELIVERED = "delivered"
  REJECTED = "rejected"
  ACCEPTED = "accepted"

  BLOCKED = "blocked"
  ONCALL = "on-call"

  url: "https://www.pivotaltracker.com/services/v5/projects/:project_id/stories"

  initialize: (json) ->
    @url = "#{@url.replace(":project_id", json.project_id)}/#{json.id}"

  feature: () ->
    @get('story_type') is FEATURE

  mark: () ->
    if @feature?
      @get('estimate')
    else
      @get('story_type').charAt(0).toUpperCase()

  onCall: () ->
    labels = label for label in @get('labels') when /#{ONCALL}/i.test label.name
    !!labels

  status: () ->
    state = @get 'current_state'

    if state is UNSTARTED
      'available'
    else if state is STARTED || state is FINISHED || state is REJECTED
      'development'
    else if state is DELIVERED
      'test'
    else if state is ACCEPTED
      'complete'

  type: () ->
    if @onCall()
      ONCALL
    else
      @get('story_type')


class ProjectsView extends Backbone.View
  el: '#projects'
  tagName: 'ul'

  initialize: () ->
    @projectsCollection = new ProjectsCollection
    @projectsCollection.on "add", (model) =>
      @addProject model

  addProject: (model) ->
    project = $ "<li><a data-cid='#{model.cid}' data-id='#{model.get('id')}' href='#'>#{model.get('name')}</a></li>"
    project.find('a').click () =>
      @trigger 'project-selected', model
    @$el.append project

  render: () ->
    @projectsCollection.fetch {data: {token: TrackerApplication.token()}}
    @$el.show()
    @


class TokenView extends Backbone.View
  el: '#token'
  tagName: 'form'

  initialize: () ->
    @$el.find('#token-submit').click @submitApiToken
    @

  render: () ->
    @$el.show()
    @

  submitApiToken: (element) =>
    document.cookie = "pivotal-api-token=#{@$el.find('input.api-token').val()}"
    @trigger 'token-stored'
    @$el.hide()


class StoryWall extends Backbone.View
  tagName: 'div'
  className: 'stickies'

class StoryView extends Backbone.View
  tagName: 'div'
  className: 'story'

  initialize: (story) ->
    @story = story

  render: () ->
    template = _.template "<h5 class='complexity <%= story_type %>'><%= mark %></h5><p class='description'><%= name %></p><p class='user legend'></p><p class='user'>#{}</p>"
    @$el.addClass @story.get 'current_state'
    @$el.addClass @story.type()
    @$el.html template
      id: "@story-#{@story.get('id')}"
      cid: @story.cid
      current_state: @story.get('current_state')
      name: @story.get('name')
      mark: @story.mark()
      story_type: @story.get('@story_type')
      type: @story.type()

    @

class KanbanView extends Backbone.View
  handleDroppedStory: (event, ui) ->
    console.log event

  COLUMNS =
    available:
      accepts: '.started'
      action: @prototype.handleDroppedStory
      title: 'Available'
    development:
      accepts: '.unstarted, .delivered'
      action: @prototype.handleDroppedStory
      title: 'Development'
    test:
      accepts: '.finished, .started, .rejected, .accepted'
      action: @prototype.handleDroppedStory
      title: 'Title'
    complete:
      accepts: '.delivered'
      action: @prototype.handleDroppedStory
      title: 'Complete'

  el: '#stories'
  tagName: 'section'

  initialize: (project) ->
    @project = project
    @totals =
      available: 0
      development: 0
      test: 0
      complete: 0

  addStory: (story) ->
    if story.feature?()
      @totals[story.status()] += +story.get('estimate')

    if @$el.find("#story-#{story.get('id')}").length is 0
      storyView = new StoryView(story).render()
      $(storyView.el).draggable
        opacity: 0.85
        revert: "invalid"
        stack: "div"
      @$el.find(".#{story.status()} .stickies").append storyView.el

  addIterationToWall: (iteration) =>
    _.each iteration.get('stories'), (json) =>
      @addStory new Story(json)
    @renderTotals()

  render: () ->
    @renderBase().renderHeaders().renderStoryArea()

    @project.iterationsCollection.on "add", @addIterationToWall
    @project.fetchIterations({scope: 'current_backlog'})

    _.each COLUMNS, (column, key) =>
      @$el.find(".#{key}.wall").droppable
        accept: column.accepts
        drop: column.action

    @

  renderBase: () ->
    template = _.template "<table id='project-#{@project.get('id')}' class='kanban'><thead></thead><tbody></tbody></table>"
    @$el.html template()
    @

  renderHeaders: () ->
    template = _.template "<tr>#{_.map COLUMNS, (column, key) -> "<td class='#{key} label'>#{column.title}</td>"}</tr>"
    @$el.find('table tbody').append template()
    @

  renderStoryArea: () ->
    template = _.template "<tr>#{_.map COLUMNS, (column, key) -> "<td class='#{key} wall'><div class='stickies'></div></td>"}</tr>"
    @$el.find('table tbody').append template()
    @

  renderTotals: () =>
    _.each COLUMNS, (column, key) =>
      @$el.find(".label.#{key}").text "#{column.title} (#{@totals[key]})"
    @


class TrackerApplication extends Backbone.View
  el: 'body'
  tagName: 'body'

  initialize: () ->
    @tokenView = new TokenView
    @tokenView.on 'token-stored', () =>
      @render()

    @projectsView = new ProjectsView
    @projectsView.on 'project-selected', (project) =>
      @updateSelectedProject project
      @constructor.setCookie 'tracker-project-id', project.get('id')

  render: () ->
    if TrackerApplication.token()
      @projectsView.render()

      if TrackerApplication.projectId()
        project = new Project {id: TrackerApplication.projectId()}
        project.on 'change', (model) =>
          @updateSelectedProject model
        project.fetch {data: {token: TrackerApplication.token()}}
    else
      @tokenView.render()

  updateSelectedProject: (project) ->
    if @$el.find("#project-#{project.get('id')}").length == 0
      @$el.find('header h1').text project.get('name')
      @$el.append new KanbanView(project).render().el

  @getCookie: (value) ->
    cookie = _.find document.cookie.split(';'), (cookieString) ->
      _.find cookieString.trim().split('='), (key, index, cookie) ->
        true if key is value
    if cookie
      _.last cookie.split('=')

  @setCookie: (name, value) ->
    document.cookie = "#{name}=#{value}"

  @projectId: () ->
    @getCookie 'tracker-project-id'

  @token: () =>
    @getCookie 'pivotal-api-token'


Backbone.ajax = () ->
  args = Array.prototype.slice.call arguments, 0
  if args.length > 0
    args[0].beforeSend = (request) ->
      request.setRequestHeader "X-TrackerToken", TrackerApplication.token()

  Backbone.$.ajax.apply Backbone.$, args


new TrackerApplication().render()


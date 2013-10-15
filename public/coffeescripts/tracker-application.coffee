class Project extends Backbone.Model
  initialize: (options) ->
    @constructor.__super__.initialize.apply @, [options]
    @iterationsCollection = new IterationsCollection @

  fetchIterations: (options) ->
    @iterationsCollection.fetch {data: {token: TrackerApplication.token(), scope: options['scope']}}

class ProjectsCollection extends Backbone.Collection
  model: Project
  url: "https://www.pivotaltracker.com/services/v5/projects"

class Iteration extends Backbone.Model
  currentStories: () ->
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
  ACCEPTED = "accepted"

  BLOCKED = "blocked"
  ONCALL = "old-on-call"

  mark: () ->
    if @get('story_type') is FEATURE
      @get('estimate')
    else
      @get('story_type').charAt(0).toUpperCase()

  onCall: () ->
    labels = label for label in @get('labels') when label.name is ONCALL
    !!labels

  status: () ->
    state = @get('current_state')

    if state is UNSTARTED
      'current'
    else if state is STARTED || state is FINISHED
      'development'
    else if state is DELIVERED
      'test'
    else if state is ACCEPTED
      'complete'

  type: () ->
    if @onCall()
      'on-call'
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
  tagName: 'ol'
  className: 'stickies'

class StoryView extends Backbone.View
  tagName: 'li'
  className: 'story'

  initialize: (story) ->
    @story = story

  render: () ->
    template = _.template "<h5 class='complexity <%= story_type %>'><%= mark %></h5><p class='description'><%= name %></p><p class='user legend'></p><p class='user'>#{}</p>"
    @$el.addClass @story.type
    @$el.attr('cid', @story.cid)
    @$el.html template @story
    @$el.click (event) =>
      event.stopPropagation()
      @$el.zoomTo {
        closeclick: true,
        debug: true,
        root: $(document.body),
        targetsize: 0.6
      }
    @

class KanbanView extends Backbone.View
  COLUMNS = ['Current', 'Development', 'Test', 'Complete']

  el: '#stories'
  tagName: 'section'

  initialize: (project) ->
    @project = project
    @totals =
      current: 0
      development: 0
      test: 0
      complete: 0

  addStory: (story) ->
    @totals[story.status()] += 1

    if @$el.find("#story-#{story.get('id')}").length is 0
      @$el.find(".#{story.status()} ol.stickies").append new StoryView({
        id: "story-#{story.get('id')}", cid: story.cid,
        story_type: story.get('story_type'), name: story.get('name'),
        mark: story.mark(), type: story.type()
      }).render().el

  addIterationToWall: (iteration) =>
    _.each iteration.get('stories'), (json) =>
      @addStory new Story(json)
    @renderTotals()

  render: () ->
    @renderBase().renderHeaders().renderStoryArea()

    @project.iterationsCollection.on "add", @addIterationToWall
    @project.fetchIterations({scope: 'current_backlog'})
    @

  renderBase: () ->
    template = _.template "<table id='project-#{@project.get('id')}' class='kanban'><thead></thead><tbody></tbody></table>"
    @$el.html template()
    @

  renderHeaders: () ->
    template = _.template "<tr>#{_.map COLUMNS, (column) -> "<td class='#{column.toLowerCase()} label'>#{column}</td>"}</tr>"
    @$el.find('table tbody').append template()
    @

  renderStoryArea: () ->
    template = _.template "<tr>#{_.map COLUMNS, (column) -> "<td class='#{column.toLowerCase()}'><ol class='stickies'></ol></td>"}</tr>"
    @$el.find('table tbody').append template()
    @

  renderTotals: () =>
    _.each COLUMNS, (column) =>
      @$el.find(".label.#{column.toLowerCase()}").text "#{column} (#{@totals[column.toLowerCase()]})"
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
      if @$el.find("#project-#{project.get('id')}").length == 0
        @$el.find('header h1').text project.get('name')
        @$el.append new KanbanView(project).render().el

  render: () ->
    if TrackerApplication.token()
      @projectsView.render()
    else
      @tokenView.render()

  @getCookie: (value) ->
    cookie = _.find document.cookie.split(';'), (cookieString) ->
      _.find cookieString.trim().split('='), (key, index, cookie) ->
        true if key is value
    if cookie
      _.last cookie.split('=')

  @token: () =>
    @getCookie 'pivotal-api-token'


new TrackerApplication().render()


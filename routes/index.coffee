Tracker    = require "./../lib/tracker"
Project    = require "./../lib/project"
Story      = require "./../lib/story"
Membership = require "./../lib/membership"
Iteration  = require "./../lib/iteration"

token = "978f492d5d2a080ced6e8fbb801700fc"

exports.tokenIndex = (req, res) ->
  res.render 'token/index'

exports.kanbanIndex = (req, res) ->
  req.session.token = token

  tracker = new Tracker req.session.token
  tracker.project req.params["projectId"], {},
    failure: (error) ->
      res.json JSON.parse error
    success: (project) ->
      tracker.iterations project.id, {scope: 'current_backlog'},
        failure: (error) ->
          res.json JSON.parse error
        success: (iterations) ->
          tracker.memberships req.params["projectId"], req.query,
            failure: (error) ->
              res.json JSON.parse error
            success: (memberships) ->
              res.render 'kanban/index', {
                title: project,
                project: project,
                titles: ['Current', 'Development', 'Test', 'Complete'],
                iterations: iterations,
                memberships: memberships
              }

exports.projectIndex = (req, res) ->
  req.session.token = req.body["token"]

  tracker = new Tracker req.session.token
  tracker.projects
    failure: (error) ->
      res.json JSON.parse error
    success: (jsonString) ->
      list = for options in JSON.parse jsonString
        new Project options

      res.render 'index', {
        title: 'Projects',
        projects: list
      }

exports.projectShow = (req, res) ->
  tracker = new Tracker token
  tracker.project req.params["projectId"], req.query,
    failure: (error) ->
      res.json JSON.parse error
    success: (options) ->
      res.json new Project JSON.parse options

exports.membershipsIndex = (req, res) ->
  tracker = new Tracker req.session.token
  tracker.memberships req.params["projectId"], req.query,
    failure: (jsonString) ->
      res.json JSON.parse jsonString
    success: (jsonString) ->
      list = for options in JSON.parse jsonString
        new Membership options
      res.json list

exports.storiesIndex = (req, res) ->
  tracker = new Tracker req.session.token
  tracker.stories req.params["projectId"], req.query,
    failure: (jsonString) ->
      res.json JSON.parse jsonString
    success: (jsonString) ->
      list = for options in JSON.parse jsonString
        new Story options
      res.json list

exports.iterationsIndex = (req, res) ->
  tracker = new Tracker token #req.session.token
  tracker.iterations req.params["projectId"], req.query,
    failure: (jsonString) ->
      res.json JSON.parse jsonString
    success: (iterations) ->
      res.json iterations


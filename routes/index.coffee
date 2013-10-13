Tracker    = require "./../lib/tracker"
Project    = require "./../lib/project"
Story      = require "./../lib/story"
Membership = require "./../lib/membership"
Iteration  = require "./../lib/iteration"

exports.backboneIndex = (req, res) ->
  res.render 'backbone/index'

exports.tokenIndex = (req, res) ->
  res.render 'token/index'

exports.kanbanIndex = (req, res) ->
  tracker = new Tracker req.cookies['pivotal-api-token']
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
  tracker = new Tracker req.cookies['pivotal-api-token']
  tracker.projects
    failure: (error) ->
      res.json JSON.parse error
    success: (jsonString) ->
      list = for options in JSON.parse jsonString
        new Project options

      res.render 'past', {
        title: 'Projects',
        projects: list
      }

exports.projectShow = (req, res) ->
  tracker = new Tracker req.cookies['pivotal-api-token']
  tracker.project req.params["projectId"], req.query,
    failure: (error) ->
      res.json JSON.parse error
    success: (options) ->
      res.json new Project JSON.parse options

exports.membershipsIndex = (req, res) ->
  tracker = new Tracker req.cookies['pivotal-api-token']
  tracker.memberships req.params["projectId"], req.query,
    failure: (jsonString) ->
      res.json JSON.parse jsonString
    success: (memberships) ->
      res.json memberships

exports.storiesIndex = (req, res) ->
  tracker = new Tracker req.cookies['pivotal-api-token']
  tracker.stories req.params["projectId"], req.query,
    failure: (jsonString) ->
      res.json JSON.parse jsonString
    success: (jsonString) ->
      list = for options in JSON.parse jsonString
        new Story options
      res.json list

exports.iterationsIndex = (req, res) ->
  tracker = new Tracker req.cookies['pivotal-api-token']
  tracker.iterations req.params["projectId"], req.query,
    failure: (jsonString) ->
      res.json JSON.parse jsonString
    success: (iterations) ->
      res.json iterations


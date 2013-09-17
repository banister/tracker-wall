Tracker    = require "./../lib/tracker"
Project    = require "./../lib/project"
Story      = require "./../lib/story"
Membership = require "./../lib/membership"
Iteration  = require "./../lib/iteration"

exports.tokenIndex = (req, res) ->
  res.render 'token/index'

exports.projectIndex = (req, res) ->
  req.session.token = req.body["token"]

  tracker = new Tracker req.session.token
  tracker.projects
    failure: (error) ->
      res.json JSON.parse jsonString
    success: (jsonString) ->
      list = for options in JSON.parse jsonString
        new Project options

      res.render 'index', {
        title: 'Projects',
        projects: list
      }

exports.projectShow = (req, res) ->
  tracker = new Tracker req.session.token
  tracker.project req.params["projectId"], req.query,
    failure: (error) ->
      res.json JSON.parse jsonString
    success: (jsonString) ->
      list = for options in JSON.parse jsonString
        options

      res.json list

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
  tracker = new Tracker req.session.token
  tracker.iterations req.params["projectId"], req.query,
    failure: (jsonString) ->
      res.json JSON.parse jsonString
    success: (jsonString) ->
      list = for options in JSON.parse jsonString
        new Iteration options
      res.json list

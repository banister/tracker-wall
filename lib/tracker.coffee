request = require "request"
repl    = require "repl"

class Tracker
  URL = "https://www.pivotaltracker.com/services/v5"

  constructor: (@apiToken) ->

  options: (path) =>
    method: "GET"
    url: "#{URL}#{path}"
    headers:
      "X-TrackerToken": @apiToken

  projects: (callbacks) =>
    request @options("/projects"), (error, response, body) ->
      if !error && response.statusCode == 200 && callbacks.success
        callbacks.success body
      else if callbacks.failure
        callbacks.failure response.body

  project: (projectId, params, callbacks) =>
    console.log @options("/projects/#{projectId}")
    request @options("/projects/#{projectId}"), (error, response, body) ->
      if !error && response.statusCode == 200 && callbacks.success
        callbacks.success body
      else if callbacks.failure
        callbacks.failure response.body

  memberships: (projectId, params, callbacks) =>
    requestUrl = "/projects/#{projectId}/memberships"

    request @options(requestUrl), (error, response, body) ->
      if !error && response.statusCode == 200 && callbacks.success
        callbacks.success body
      else if callbacks.failure
        callbacks.failure response.body
  iterations: (projectId, params, callbacks) =>
    requestUrl = "/projects/#{projectId}/iterations"

    if params
      queryString = for key, value of params
        "#{key}=#{value}"

      if queryString isnt {}
        requestUrl += "?#{queryString.join("&")}"

    request @options(requestUrl), (error, response, body) ->
      if !error && response.statusCode == 200 && callbacks.success
        callbacks.success body
      else if callbacks.failure
        callbacks.failure response.body

  stories: (projectId, params, callbacks) =>
    requestUrl = "/projects/#{projectId}/stories"

    if params
      queryString = for key, value of params
        "#{key}=#{value}"

      if queryString isnt {}
        requestUrl += "?#{queryString.join("&")}"

    request @options(requestUrl), (error, response, body) ->
      if !error && response.statusCode == 200 && callbacks.success
        callbacks.success body
      else if callbacks.failure
        callbacks.failure response.body


module.exports = Tracker

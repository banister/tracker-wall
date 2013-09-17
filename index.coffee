Tracker = require "./lib/tracker"
Project = require "./lib/project"

tracker = new Tracker "978f492d5d2a080ced6e8fbb801700fc"

tracker.projects
  failure: (error) ->
    console.log error
  success: (jsonString) ->
    list = for options in JSON.parse jsonString
      new Project options

    for project in list when project.name is 'Core'
      project.stories()

express = require 'express'
routes = require './routes'
user = require './routes/user'
http = require 'http'
path = require 'path'
stylus = require 'stylus'

app = express()

app.set 'port', process.env.PORT || 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser('your secret here')
app.use express.session()
app.use app.router
app.use(stylus.middleware(__dirname + '/public'))
app.use express.static(path.join(__dirname, 'public'))

if 'development' == app.get('env')
  app.use express.errorHandler()

app.get '/backbone',                         routes.backboneIndex
app.get  '/',                                routes.tokenIndex
app.post '/',                                routes.projectIndex
app.get  '/kanban/:projectId',               routes.kanbanIndex
app.get  '/projects/:projectId',             routes.projectShow
app.get  '/projects/:projectId/memberships', routes.membershipsIndex
app.get  '/projects/:projectId/stories',     routes.storiesIndex
app.get  '/projects/:projectId/iterations',  routes.iterationsIndex
app.get  '/users', user.list

http.createServer(app).listen app.get('port'), () ->
  console.log 'Express server listening on port ' + app.get('port')


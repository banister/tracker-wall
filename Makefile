start:
	node_modules/.bin/nodemon app.coffee

start-compile:
	coffee --output ./public/javascripts public/coffeescripts/tracker-application.coffee
	node_modules/.bin/nodemon app.coffee

compile:
	coffee --output ./public/javascripts --watch public/coffeescripts/tracker-application.coffee


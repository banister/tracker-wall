all:
	coffee -c app.coffee

start:
	node_modules/.bin/nodemon app.coffee

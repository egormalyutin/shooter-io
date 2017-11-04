express = require 'express'
app     = express app

app.engine('html', require('ejs').renderFile)
app.set('view engine', 'html');

app.use(express.static(__dirname + "/public"))
app.set('views', __dirname + '/views');




server  = require('http').createServer app

Eureca       = require 'eureca.io'
eurecaServer = new Eureca.Server
	allow: [ 'playerUpdated' ]

eurecaServer.attach server





i = 0

app.get '/', (req, res, next) ->
	res.render 'index.html'

server.listen 8000

game = require('./scripts/main.js')(eurecaServer)
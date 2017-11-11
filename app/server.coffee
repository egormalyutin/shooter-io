ips     = require 'ip'
require 'colors'

process.stdin.on 'data', (data) ->
	out.exit() if data.toString() == "\u0003"

express = require 'express'
favicon = require 'serve-favicon'
app     = express app


app.engine('html', require('ejs').renderFile)
app.set('view engine', 'html');

app.use(express.static(__dirname + "/public"))
app.set('views', __dirname + '/views');

# app.use(favicon(__dirname + '/public/favicon.ico')); 


compareIP = (ip1, ip2) ->
	ips.isEqual ip1 + "", ip2 + ""


server  = require('http').createServer app

Eureca       = require 'eureca.io'
eurecaServer = new Eureca.Server
	allow: [ 'playerUpdated', 'playerRemoved', 'serverClosed', 'serverOpened' ]

eurecaServer.attach server

i = 0

bannedIPs = ['192.168.1.108']

app.get '/', (req, res, next) ->
	banned = do ->
		return  true for ip in bannedIPs when compareIP req.ip, ip
		return false

	res.render 'index.html' unless banned

app.get '/*', (req, res, next) ->
	res.redirect '/'

port = process.env.PORT || 5000

server.listen port

out = require('./scripts/out.js') eurecaServer

game = require('./scripts/main.js') eurecaServer, out

out.promo 'SHOOTER.IO'
out.welcome 'Welcome in SHOOTER.IO server!'
out.message 'Listening on ' + ('http://localhost:' + port).blue + '!'
out.getAdminToken()
out.welcome 'Type "help" for view list of avaliable commands.'
out.welcome 'You can press "Ctrl+C" or type "exit" for stop server and exit from server\'s CLI.'
out.cli()


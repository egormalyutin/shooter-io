termkit = require 'terminal-kit'
term    = termkit.terminal
figlet  = require 'figlet'
center  = require 'center-align'
boxen   = require 'boxen'
util    = require 'util'
require 'colors'
out = {
	info: (phrase) ->
		term.bold.magenta('⬢')(' ').bold(phrase)('\n')
		out.cliRebase()

	error: (phrase) ->
		term.bold.red('λ')(' ').bold(phrase)('\n')
		out.cliRebase()

	promo: (phrase) ->
		term '\n'
		text = figlet.textSync phrase,
			font: 'Big'
			horizontalLayout: 'default'
			verticalLayout: 'default'

		term.bold.brightCyan(text)('\n')
		out.cliRebase()

	welcome: (phrase) ->
		term.bold.underline.brightCyan(phrase)('\n')
		out.cliRebase()

	message: (phrase) ->
		term '\n'
		term.bold(boxen(center(phrase + ""), {padding: 1}))
		term '\n\n'

	text: (phrase, multiline) ->
		# →
		lines = phrase.split(/\n/gi).length

		if lines == 1 and not multiline
			term.bold("→ ").bold(phrase)("\n")
		else
			term.bold("→ ")("\n")

			result = []
			for string in phrase.split /\n/gi
				term.bold "  " + string
				term '\n'

	help: ->
		out.text( 
			[
				'help'.cyan + '                  - display this help'
				'admin'.cyan + '                 - generate brand new admin token'
				'remove [player name]'.cyan + '  - remove player from game'
				'kick [player name]'.cyan + '    - similar to ' + '"remove"'.cyan
				'exit'.cyan + '                  - stop server and exit from server\'s cli'
			].join '\n'
		)

	cli: ->
		f = () ->
			out.cliLine = term.inputField (err, input) ->
				if err
					console.dir err
					return
				term '\n'
				com = 0
				if input.match(/^help/i)
					out.help()
					com++

				if input.match(/^exit/i)
					process.exit()
					com++

				if input.match(/^admin/i)
					out.getAdminToken()
					com++

				if input.match(/^remove/i)
					if input.match(/^remove .*$/i)
						out.removePlayer input.match(/^remove (.*)$/i)[1]
					else
						out.error 'Invalid syntax!'
					com++

				if input.match(/^kick/i)
					if input.match(/^kick .*$/i)
						out.removePlayer input.match(/^kick (.*)$/i)[1]
					else
						out.error 'Invalid syntax!'
					com++

				if input.match(/^players/i)
					players = eurecaServer.exports.getPlayers()
					results = []
					for _, player of players
						results.push player.name
					out.text (results.join '\n'), true
					com++

				if input.match(/^player /i)
					if input.match(/^player .*$/i)
						name = input.match(/^player (.*)$/i)[1]
						players = eurecaServer.exports.getPlayers()
						if players[name]
							out.text(util.format(players[name]))
						else
							out.error 'Player ' + name + ' not exists!'
					else
						out.error 'Invalid syntax!'
					com++

				unless com
					setImmediate ->
						out.error 'Unknown command!'

				f()
		f()

	cliRebase: () ->
		setImmediate( -> out.cliLine.rebase()) if out.cliLine

}

express = require 'express'
favicon = require 'serve-favicon'
app     = express app


app.engine('html', require('ejs').renderFile)
app.set('view engine', 'html');

app.use(express.static(__dirname + "/public"))
app.set('views', __dirname + '/views');

# app.use(favicon(__dirname + '/public/favicon.ico')); 




server  = require('http').createServer app

Eureca       = require 'eureca.io'
eurecaServer = new Eureca.Server
	allow: [ 'playerUpdated', 'playerRemoved' ]

eurecaServer.attach server





i = 0

app.get '/', (req, res, next) ->
	res.render 'index.html'

port = process.env.PORT || 5000

server.listen port

game = require('./scripts/main.js') eurecaServer, out

out.promo 'SHOOTER.IO'
out.welcome 'Welcome in SHOOTER.IO server!'
out.message 'Listening on ' + ('http://localhost:' + port).blue + '!'
out.getAdminToken()
out.welcome 'Type "help" for view list of avaliable commands.'
out.cli()


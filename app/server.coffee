termkit = require 'terminal-kit'
term    = termkit.terminal
figlet  = require 'figlet'
center  = require 'center-align'
boxen   = require 'boxen'
require 'colors'
out = {
	info: (phrase) ->
		term.bold.magenta('⬢')(' ').bold(phrase)('\n')
		out.cliRebase()

	error: (phrase) ->
		term.bold.red('λ')(' ').bold(phrase)('\n')
		out.cliRebase()

	promo: (phrase) ->
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

	text: (phrase) ->
		# →
		lines = phrase.split(/\n/gi).length

		if lines == 1
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
				'help'.cyan + '  - display this help'
				'admin'.cyan + ' - register player "admin"'
				'exit'.cyan + '  - stop server and exit from server\'s cli'
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

				unless com
					setImmediate ->
						out.error 'Unknown command!'

				f()
		f()

	cliRebase: () ->
		out.cliLine.rebase() if out.cliLine

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

out.promo 'SHOOTER.IO'
out.welcome 'Welcome in SHOOTER.IO server!'
out.message 'Listening on ' + ('http://localhost:' + port).blue + '!'
out.welcome 'Type "help" for view list of avaliable commands.'
out.cli()

game = require('./scripts/main.js') eurecaServer, out
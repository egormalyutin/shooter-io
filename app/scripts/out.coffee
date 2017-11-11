termkit = require 'terminal-kit'
term    = termkit.terminal
figlet  = require 'figlet'
center  = require 'center-align'
boxen   = require 'boxen'
util    = require 'util'


random = (min, max) -> 
	if not max
		max = min
		min = 0
	Math.floor(min + (Math.random() * (max - min)))

module.exports = (eurecaServer) ->
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
			term.bold.brightCyan(phrase)('\n')
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
					'kick   [player name]'.cyan + '  - alias to ' + '"remove"'.cyan
					'players'.cyan + '               - view list of players'
					'player [player name]'.cyan + '  - view information about player'
					'close'.cyan + '                 - close server (kick all players and disallow joining for new players)'
					'open'.cyan + '                  - open server back'
					'allow-joining'.cyan + '         - allow new players to join game'
					'disallow-joining'.cyan + '      - disallow new players to join game'
					'aj'.cyan + '                    - alias to ' + '"allow-joining"'.cyan
					'daj'.cyan + '                   - alias to ' + '"disallow-joining"'.cyan
					'exit'.cyan + '                  - stop server and exit from server\'s CLI'
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
						out.exit()
						com++

					if input.match(/^admin/i)
						out.getAdminToken()
						com++

					if input.match(/^open/i)
						out.openServer()
						com++

					if input.match(/^close/i)
						out.closeServer()
						com++

					if input.match(/^allow-joining/i)
						out.allowJoining()
						com++
					if input.match(/^aj/i)
						out.allowJoining()
						com++


					if input.match(/^disallow-joining/i)
						out.disallowJoining()
						com++
					if input.match(/^daj/i)
						out.disallowJoining()
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

		exit: ->
			phrases = [
				'Bye!'
				'See you later!'
				'See you soon!'
			]
			term '\n'
			term.bold.brightCyan(phrases[random(phrases.length)])('\n')
			term '\n'
			process.exit()
	}

	out
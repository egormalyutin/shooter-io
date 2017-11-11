client = new Eureca.Client

players = {}



#  __  __    _    ___ _   _
# |  \/  |  / \  |_ _| \ | |
# | |\/| | / _ \  | ||  \| |
# | |  | |/ ___ \ | || |\  |
# |_|  |_/_/   \_\___|_| \_|



preload = () ->
	game.physics.startSystem(Phaser.Physics.P2JS)
	game.load.image 'player', 'images/star.png'

create  = () ->

update  = () ->
	cursors = game.input.keyboard.createCursorKeys();
	m = 0

	for _, player of players
		player.body.setZeroRotation();
		player.body.setZeroVelocity();

	if global.controlling
		if cursors.left.isDown
			server.input global.name, global.token, "a"
			global.controlling.body.moveLeft 400
		else if cursors.right.isDown
			server.input global.name, global.token, "d"
			global.controlling.body.moveRight 400

		if cursors.up.isDown
			server.input global.name, global.token, "w"
			global.controlling.body.moveUp 400
		else if cursors.down.isDown
			server.input global.name, global.token, "s"
			global.controlling.body.moveDown 400


canvasWidth  = window.innerWidth  * window.devicePixelRatio
canvasHeight = window.innerHeight * window.devicePixelRatio

game = new Phaser.Game(
	canvasWidth, 
	canvasHeight, 
	Phaser.AUTO, # renderer
	'game', # canvas' parent element id
	{ preload: preload, create: create, update: update }, # bind events
	true # canvas transparency
)


global = {}
server = {}

# class Player
# 	constructor: (settings, token) ->
# 		for name, prop of settings
# 			@[name] = prop

# 		@element = $("<div/>")

# 		@_elementName = $('<span/>')
# 		@_elementName.text @name + ": "

# 		@_elementLabel = $("<span/>")
# 		@_elementLabel.text @count + " "

# 		@element.append @_elementName
# 		@element.append @_elementLabel

# 		sf = @

# 		if token
# 			@_elementUp = $('<button>UP</button>')
# 			@_elementUp.on 'click', ->
# 				server.playerChanged {
# 					name:         sf.name
# 					x:            sf.x
# 					y:            sf.y
# 					count:        sf.count + 1
# 					connectionID: sf.connectionID
# 				}, token
# 			@element.append @_elementUp
# 		$('#game').append @element

# 	render: ->
# 		@_elementLabel.text @count + " "

# 	remove: ->
# 		@element.remove()

newPlayer = (settings, token) ->
	pl = game.add.sprite 0, 0, 'player'
	for name, prop of settings
		pl[name] = prop

	game.physics.enable(pl, Phaser.Physics.P2JS);

	if token
		global.controlling = pl

	pl


client.exports.playerUpdated = (player) ->
	return unless global.ready
	unless players[player.name] and players.name != global.name
		players[player.name] = newPlayer player
	else
		players[player.name].name         = player.name
		players[player.name].x            = player.x
		players[player.name].y            = player.y
		players[player.name].count        = player.count
		players[player.name].connectionID = player.connectionID

client.exports.playerRemoved = (name) ->
	players[name].destroy()
	ui.preloader.css 'opacity', '1'
	delete players[name]

client.exports.serverClosed = (message) ->
	game.destroy()
	ui.connection.text message
	ui.connection.show()
	ui.connection.css 'opacity', '1'

client.exports.serverOpened = ->
	location.reload()

ui = # cache some ui elements
		body:       $("body")
		newPlayer:  $("#newPlayer")
		playerName: $("#playerName")
		menu:       $("#menu")
		unError:    $("#unError")
		connection: $("#connection")
		preloader:  $("#preloader")




client.ready (serverLocal) ->
	server = serverLocal

	ui.connection.hide()
	ui.menu.css 'opacity', '1'

	server.getState().onReady (state) ->
		unless state.open
			setTimeout(->
				setTimeout (() -> ui.preloader.remove()), 300
				ui.preloader.css 'opacity', '0'
				ui.connection.text "Sorry, but server is closed at now. You can try to connect later."
				ui.connection.show()
			, 700)
		else
			setTimeout(->
				setTimeout (() -> ui.preloader.remove()), 300
				ui.preloader.css 'opacity', '0'
				ui.connection.css 'opacity', '0'
			, 700)

	verifyUsername = (cb) ->
		un = ui.playerName.val()
		unless un == "admin" and global.token
			server.verifyUsername(un).onReady (result) ->
				if typeof result == 'string'
					ui.unError.text result
				else
					cb()
		else cb()

	ui.body.show()


	# When player tries to enter the game
	ui.newPlayer.on  'click',       () -> joinServer()
	ui.playerName.on 'keypress', (key) -> joinServer() if key.key == "Enter"

	$(document).on 'keydown', null, 'alt+shift+t', ->
		global.token = prompt('Your token', '')


	joinServer = () ->
		verifyUsername ->
			setTimeout (() -> ui.menu.hide()), 300
			ui.menu.css 'opacity', '0'

			name = ui.playerName.val()
			global.name  = name




			registerPlayer = (token) ->
				server.newPlayer(name, token).onReady (player) ->
					server.getPlayers().onReady (playersTmp) ->
						global.ready = true
						players = {}

						if Object.keys(playersTmp).length
							for _, player of playersTmp
								console.log player
								players[player.name] = newPlayer player if player.name != name

								players[player.name] = newPlayer player, global.token if player.name == name
								global.spawned = true                                  if player.name == name

						console.log 'Got token! ' + global.token 


			unless global.token
				server.getToken(name).onReady (token) ->
					global.token = token
					registerPlayer global.token
			else
				registerPlayer global.token


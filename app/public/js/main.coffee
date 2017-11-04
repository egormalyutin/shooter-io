client = new Eureca.Client
players = {}

global = {}
server = {}

class Player
	constructor: (settings, token) ->
		for name, prop of settings
			@[name] = prop

		@element = $("<div/>")
		@_elementLabel = $("<span/>")
		@_elementLabel.text @count

		@element.append @_elementLabel

		sf = @

		if token
			@_elementUp = $('<button>UP</button>')
			@_elementUp.on 'click', ->
				server.playerChanged {
					name:  sf.name
					x:     sf.x
					y:     sf.y
					count: sf.count + 1
				}, token
			@element.append @_elementUp
		$('#game').append @element

	render: ->
		@_elementLabel.text @count

client.exports.playerUpdated = (player) ->
	unless players[player.name]
		players[player.name] = new Player player
	else
		players[player.name].name  = player.name
		players[player.name].x     = player.x
		players[player.name].y     = player.y
		players[player.name].count = player.count
		players[player.name].render()



ui = # cache some ui elements
		body:       $("body")
		newPlayer:  $("#newPlayer")
		playerName: $("#playerName")
		menu:       $("#menu")


client.ready (serverLocal) ->
	server = serverLocal

	ui.body.show()


	# When player tries to enter the game
	ui.newPlayer.on  'click',       () -> joinServer()
	ui.playerName.on 'keypress', (key) -> joinServer() if key.key == "Enter"


	joinServer = () ->
		# Show game canvas
		setTimeout (() -> ui.menu.hide()), 300
		ui.menu.css 'opacity', '0'

		name = ui.playerName.val()

		server.getToken(name).onReady (token) ->
			global.name  = name
			global.token = token
			server.newPlayer(name, token).onReady (player) ->
				server.getPlayers().onReady (playersTmp) ->
					uis = {}
					players = {}

					for _, player of playersTmp
						console.log player
						players[player.name] = new Player player if player.name != name

						players[player.name] = new Player player, token if player.name == name
						global.spawned = true                           if player.name == name

					console.log 'Got token! ' + token 



					# #  __  __    _    ___ _   _
					# # |  \/  |  / \  |_ _| \ | |
					# # | |\/| | / _ \  | ||  \| |
					# # | |  | |/ ___ \ | || |\  |
					# # |_|  |_/_/   \_\___|_| \_|



					# preload = () ->
					# 	game.physics.startSystem(Phaser.Physics.P2JS)
					# 	game.load.image 'star', 'images/star.png'

					# create  = () ->

					# update  = () ->
					# 	cursors = game.input.keyboard.createCursorKeys();
					# 	# stop player movement
					# 	global.remote.body.velocity.x = 0;

					# 	if cursors.left.isDown
					# 		global.remote.body.velocity.x = -150
					# 	else if cursors.right.isDown
					# 		global.remote.body.velocity.x = 150


					# canvasWidth  = window.innerWidth  * window.devicePixelRatio
					# canvasHeight = window.innerHeight * window.devicePixelRatio


					# game = new Phaser.Game(
					# 	canvasWidth, 
					# 	canvasHeight, 
					# 	Phaser.AUTO, # renderer
					# 	'game', # canvas' parent element id
					# 	{ preload: preload, create: create, update: update }, # bind events
					# 	true # canvas transparency
					# )
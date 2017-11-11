p2 = require 'p2'
module.exports = (es, out) ->
	connections = {}
	players     = {}
	tokens      = {}

	playerUpdated = (c, player) ->
		c.playerUpdated
				name:  player.name
				count: player.count
				x: player.x
				y: player.y
				connectionID: player.connectionID

	## PHYSICS

	startTime = (new Date).getTime()
	lastTime = undefined
	timeStep = 1 / 70

	world = new p2.World {
		gravity: [0, 0]
	}

	ph = ->
		currentTime = (new Date).getTime()
		timeElapsed = currentTime - startTime
		dt = if lastTime then timeElapsed - lastTime / 100 else 0
		dt = Math.min 1 / 10, dt
		world.step timeStep

	setInterval ph, 1000/60

	state = {
		open: true
		closed: false
		setOpened: (s) ->
			unless typeof s == 'boolean'
				state.open   = true
				state.closed = false
			else
				state.open   = s
				state.closed = not s
			state._onOC()
		setClosed: (s) ->
			unless typeof s == 'boolean'
				state.closed = true
				state.open   = false
			else
				state.closed = s
				state.open   = not s
			state._onOC()

		_onOC: ->
			if state.closed
				for _, c of connections
					c.serverClosed "Sorry, but server is closed at now. You can try to connect later." 
				for _, player of players
					delete players[player.name]
					delete  tokens[player.name]
					for _, c of connections
						c.playerRemoved player.name
			else if state.open
				for _, c of connections
					c.serverOpened()
		
		canJoin: true

		allowJoining: (s) ->
			unless typeof s == 'boolean'
				state.canJoin = true
			else
				state.canJoin = s

		disallowJoining: (s) ->
			unless typeof s == 'boolean'
				state.canJoin = false
			else
				state.canJoin = not s

	}

	out.getAdminToken = (name) ->
		if tokens.admin
			out.error "Admin's token exists."
			return
		tokens.admin = 
			("admin" +
			':' +
			random(1000000000000000, 9999999999999999) + 
			':' +
			randomSymbs(30)
			)
		out.message 'Your token is "' + tokens.admin + '".\nPress "Alt+Shift+A" on main page and enter this token.\nThen enter "admin" to input and enjoy game!'
		return tokens.admin

	out.removePlayer = (name) ->
		if players[name]
			delete players[name]
			for _, c of connections
				c.playerRemoved name
			out.info 'Removed player "' + name + '".'
		else
			out.error 'Player "' + name + '" not exists.'

		if tokens[name]
			delete tokens[name]
			out.info 'Removed ' + name + '\'s token.'
		else
			out.error name + '\'s token not exists.'

	out.closeServer = ->
		state.setClosed()
		out.info 'Server succefully closed!'

	out.openServer = ->
		state.setOpened()
		out.info 'Server succefully opened!'

	out.allowJoining = ->
		state.allowJoining()
		out.info 'Joining is allowed now!'

	out.disallowJoining = ->
		state.disallowJoining()
		out.info 'Joining is disallowed now!'

	random = (min, max) -> 
		if not max
			max = min
			min = 0
		Math.floor(min + (Math.random() * (max - min)))
		
	randomSymbs = (count) ->
		symbs  = "qwertyuiopasdfghjklzxcvbnm"
		result = ""

		while result.length <= count
			result += symbs[random 0, symbs.length - 1]

		result

	es.onConnect (c) -> 
		out.info 'User ' + c.id + ' connected!'
		connections[c.id] = c.clientProxy

	es.onDisconnect (c) ->
		id = c.id
		out.info 'User ' + id + ' disconnected!'
		delete connections[id] if connections[id]

		removed = []

		for _, player of players
			if id == player.connectionID
				out.removePlayer player.name	

	es.exports.verifyUsername = (name) ->

		if name == 'admin' or name == 'аdmin' # there are russian "a" and english "a"
			return "Username \"admin\" is reserved."

		unless name.length <= 20 and name.length > 3
			return "Username must contain 3 symbols at least and 20 as maximum."

		if players[name]
			return "Player " + name + " already in game."

		if tokens[name]
			return name + "'s token exists"

		unless state.canJoin
			@clientProxy.serverClosed "Sorry, but server is closed for new players at now. You can try to connect later."	

		return true

	es.exports.getState = -> 
		open:    state.open 
		close:   state.closed
		canJoin: state.canJoin

	es.exports.getToken = (name) ->
		return unless state.canJoin
		return unless state.open
		if name == 'admin' or name == 'аdmin' # there are russian "a" and english "a"
			out.error "Username \"admin\" is reserved."

		unless name.length <= 20 and name.length > 3
			out.error "Username (tried " + name + ") must contain 3 symbols at least and 20 as maximum."
			return

		if players[name]
			out.error "Player " + name + " already in game."
			return

		if tokens[name]
			out.error name + "'s token exists."
			return

		return unless state.canJoin

		tokens[name] = 
			(name +
			':' +
			random(1000000000000000, 9999999999999999) + 
			':' +
			randomSymbs(30)
			)
		out.info 'New token: ' + tokens[name]
		return tokens[name]

	es.exports.newPlayer = (name, token) ->
		return unless state.canJoin
		return unless state.open

		return if not name or not token
		return if token != tokens[name]
		if players[name]
			out.error 'Player ' + name + ' exists!'
			return 

		players[name] = 
			name:  name
			count: 0	
			body: new p2.Body {
				mass: 0
				position: [0, 0]
			}
			connectionID: @user.clientId

		world.addBody players[name].body

		players[name].x = players[name].body.position[0]
		players[name].y = players[name].body.position[1]

		world.addBody players[name].body

		out.info 'Created new player ' + name + '!'

		for _, c of connections
			playerUpdated c, players[name]

	# es.exports.playerChanged = (player, token) ->
	# 	return unless tokens[player.name] and players[player.name]
	# 	if tokens[player.name] == token
	# 		players[player.name] = player 
	# 	else
	# 		out.error player.name + '\'s token is invalid!'
	# 		return

	# 	for _, c of connections
	# 		c.playerUpdated players[player.name]

	es.exports.input = (player, token, inp) ->
		return unless tokens[player] and players[player]
		unless tokens[player] == token
			out.error player.name + '\'s token is invalid!'
			return

		players[player].body.velocity = [0, 0]

		players[player].body.velocity[0] = -400 if inp == "a"
		players[player].body.velocity[0] = 400  if inp == "d"
		players[player].body.velocity[1] = -400 if inp == "w"
		players[player].body.velocity[1] = 400  if inp == "s"

		for _, c of connections
			playerUpdated c, players[player]

	es.exports.getPlayers = -> players

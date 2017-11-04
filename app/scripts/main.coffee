module.exports = (es) ->
	connections = {}
	players     = {}
	tokens      = {}

	random = (min, max) -> Math.floor(min + (Math.random() * (max - min)))
	randomSymbs = (count) ->
		symbs  = "qwertyuiopasdfghjklzxcvbnm"
		result = ""

		while result.length <= count
			result += symbs[random 0, symbs.length - 1]

		result

	verify = (name) ->
		name.length <= 20 and name.length > 3


	es.onConnect (c) -> 
		connections[c.id] = c.clientProxy

	es.onDisconnect (c) ->
		id = c.id
		console.log 'Player ' + id + ' disconnected!'
		delete connections[id] if connections[id]

		removed = []

		for _, player of players
			if id == player.connectionID
				for _, c of connections
					c.playerRemoved player.name
				delete players[player.name] 
				delete  tokens[player.name]

	es.exports.verifyUsername = (name) ->
		unless name.length <= 20 and name.length > 3
			return "Username must contain 3 symbols at least and 20 as maximum."

		if players[name]
			return "Player " + name + " already in game."

		return true

	es.exports.getToken = (name) ->
		unless name.length <= 20 and name.length > 3
			console.log "TOKEN ERROR: Username (tried " + name + ") must contain 3 symbols at least and 20 as maximum."
			return

		if players[name]
			console.log "TOKEN ERROR: Player " + name + " already in game."
			return

		return if tokens[name]

		tokens[name] = 
			(name +
			':' +
			random(1000000000000000, 9999999999999999) + 
			':' +
			randomSymbs(30)
			)
		console.log 'New token: ' + tokens[name]
		return tokens[name]

	es.exports.newPlayer = (name, token) ->
		return if not name or not token
		return if token != tokens[name]
		if players[name]
			console.log 'Player ' + name + ' exists!'
			return 

		players[name] = 
			name:  name
			x: 0
			y: 0
			count: 0	
			connectionID: @user.clientId

		console.log 'Created new player ' + name + '!'

		es.exports.playerChanged players[name], token

	es.exports.playerChanged = (player, token) ->
		if tokens[player.name] == token
			players[player.name] = player 
		else
			console.log 'Wrong ' + player.name + '\'s token!'
			return

		for _, c of connections
			c.playerUpdated players[player.name]

	es.exports.getPlayers = -> players

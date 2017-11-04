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
		delete connections[c.id] if connections[c.id]


	es.exports.getToken = (name) ->
		if verify name
			unless tokens[name]
				start = new Date
				tokens[name] = 
					(name +
					':' +
					random(1000000000000000, 9999999999999999) + 
					':' +
					randomSymbs(30)
					)
				end = new Date
				console.log end - start
				console.log 'New token: ' + tokens[name]
				return tokens[name]
			else
				console.log tokens[name] + '\'s token exists'
		else
			console.log 'Bad name ' + name + '!'

	es.exports.newPlayer = (name, token) ->
		return if token != tokens[name]
		if players[name]
			console.log 'Player ' + name + ' exists!'
			return 

		players[name] = 
			name:  name
			x: 0
			y: 0
			count: 0	

		console.log 'Created new player ' + name + '!'

		es.exports.playerChanged players[name], token

	es.exports.playerChanged = (player, token) ->
		if tokens[player.name] == token
			players[player.name] = player 
		else
			console.log 'Wrong token!'

		for _, c of connections
			c.playerUpdated players[player.name]
			console.log 'Updated connection!' 

		console.log 'Changed player ' + player.name + '!'

	es.exports.getPlayers = -> players

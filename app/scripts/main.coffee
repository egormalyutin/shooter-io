module.exports = (es, out) ->
	connections = {}
	players     = {}
	tokens      = {}

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
		out.message 'Your token is "' + tokens.admin + '".\nPress "alt+shift+a" on main page and enter this token.\nThen enter "admin" to input and enter.'
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

		return true

	es.exports.getToken = (name) ->
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
		return if not name or not token
		return if token != tokens[name]
		if players[name]
			out.error 'Player ' + name + ' exists!'
			return 

		players[name] = 
			name:  name
			x: 0
			y: 0
			count: 0	
			connectionID: @user.clientId

		out.info 'Created new player ' + name + '!'

		es.exports.playerChanged players[name], token

	es.exports.playerChanged = (player, token) ->
		return unless tokens[player.name] and players[player.name]
		if tokens[player.name] == token
			players[player.name] = player 
		else
			out.error player.name + '\'s token is invalid!'
			return

		for _, c of connections
			c.playerUpdated players[player.name]

	es.exports.getPlayers = -> players

// Generated by CoffeeScript 1.12.5
module.exports = function(es, out) {
  var connections, players, random, randomSymbs, tokens, verify;
  connections = {};
  players = {};
  tokens = {};
  out.getAdminToken = function(name) {
    if (tokens.admin) {
      out.error("Admin's token exists.");
      return;
    }
    tokens.admin = "admin" + ':' + random(1000000000000000, 9999999999999999) + ':' + randomSymbs(30);
    out.message('Your token is "' + tokens.admin + '".\nPress "alt+shift+a" on main page and enter this token.\nThen enter "admin" to input and enter.');
    return tokens.admin;
  };
  out.removePlayer = function(name) {
    var _, c;
    if (players[name]) {
      delete players[name];
      for (_ in connections) {
        c = connections[_];
        c.playerRemoved(name);
      }
      out.info('Removed player "' + name + '".');
    } else {
      out.error('Player "' + name + '" not exists.');
    }
    if (tokens[name]) {
      delete tokens[name];
      return out.info('Removed ' + name + '\'s token.');
    } else {
      return out.error(name + '\'s token not exists.');
    }
  };
  random = function(min, max) {
    return Math.floor(min + (Math.random() * (max - min)));
  };
  randomSymbs = function(count) {
    var result, symbs;
    symbs = "qwertyuiopasdfghjklzxcvbnm";
    result = "";
    while (result.length <= count) {
      result += symbs[random(0, symbs.length - 1)];
    }
    return result;
  };
  verify = function(name) {
    return name.length <= 20 && name.length > 3;
  };
  es.onConnect(function(c) {
    out.info('User ' + c.id + ' connected!');
    return connections[c.id] = c.clientProxy;
  });
  es.onDisconnect(function(c) {
    var _, id, player, removed, results;
    id = c.id;
    out.info('User ' + id + ' disconnected!');
    if (connections[id]) {
      delete connections[id];
    }
    removed = [];
    results = [];
    for (_ in players) {
      player = players[_];
      if (id === player.connectionID) {
        results.push(out.removePlayer(player.name));
      } else {
        results.push(void 0);
      }
    }
    return results;
  });
  es.exports.verifyUsername = function(name) {
    if (name === 'admin' || name === 'аdmin') {
      return "Username \"admin\" is reserved.";
    }
    if (!(name.length <= 20 && name.length > 3)) {
      return "Username must contain 3 symbols at least and 20 as maximum.";
    }
    if (players[name]) {
      return "Player " + name + " already in game.";
    }
    if (tokens[name]) {
      return name + "'s token exists";
    }
    return true;
  };
  es.exports.getToken = function(name) {
    if (name === 'admin' || name === 'аdmin') {
      out.error("Username \"admin\" is reserved.");
    }
    if (!(name.length <= 20 && name.length > 3)) {
      out.error("Username (tried " + name + ") must contain 3 symbols at least and 20 as maximum.");
      return;
    }
    if (players[name]) {
      out.error("Player " + name + " already in game.");
      return;
    }
    if (tokens[name]) {
      out.error(name + "'s token exists.");
      return;
    }
    tokens[name] = name + ':' + random(1000000000000000, 9999999999999999) + ':' + randomSymbs(30);
    out.info('New token: ' + tokens[name]);
    return tokens[name];
  };
  es.exports.newPlayer = function(name, token) {
    if (!name || !token) {
      return;
    }
    if (token !== tokens[name]) {
      return;
    }
    if (players[name]) {
      out.error('Player ' + name + ' exists!');
      return;
    }
    players[name] = {
      name: name,
      x: 0,
      y: 0,
      count: 0,
      connectionID: this.user.clientId
    };
    out.info('Created new player ' + name + '!');
    return es.exports.playerChanged(players[name], token);
  };
  es.exports.playerChanged = function(player, token) {
    var _, c, results;
    if (!(tokens[player.name] && players[player.name])) {
      return;
    }
    if (tokens[player.name] === token) {
      players[player.name] = player;
    } else {
      out.error(player.name + '\'s token is invalid!');
      return;
    }
    results = [];
    for (_ in connections) {
      c = connections[_];
      results.push(c.playerUpdated(players[player.name]));
    }
    return results;
  };
  return es.exports.getPlayers = function() {
    return players;
  };
};

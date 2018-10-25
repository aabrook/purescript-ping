/*
function cancelNoop(client) {
  return function(_cancelError, cancelerError, cancelerSuccess) {
    if(!client.connected) {
      cancellerSuccess()
      return
    }

    client.end(function(err) {
      if(err) {
        cancelerError(new Error(err))
      } else {
        cancelerSuccess()
      }
    })
  }
}
*/
function cancelNoop(_cancelError, cancelerError, cancelerSuccess) {
  cancelerSuccess()
}

exports._connect = function(url) {
  return function(opts) {
    return function(onError, onSuccess) {
      const client = require('mqtt').connect(url, opts)

      client.on('connect', function() {
        onSuccess(client)
      })
      client.on('error', function(err) {
        onError(new Error(err))
        client.end()
      })

      return cancelNoop
    }
  }
};

exports._end = function(client) {
  return function(onError, onSuccess) {
    client.end(function(err) {
      if(err) {
        onError(err)
      } else {
        onSuccess()
      }
    })

    return cancelNoop
  }
};

exports._subscribe = function(topic) {
  return function(client) {
    return function(onError, onSuccess) {
      client.subscribe(topic, function(err) {
        if(err) {
          onError(err)
        } else {
          onSuccess()
        }
      });

      return cancelNoop
    }
  }
};

exports._publish = function(topic) {
  return function(message) {
    return function(client) {
      return function(onError, onSuccess) {
        client.publish(topic, message, function(err) {
          if(err) {
            onError(err)
          } else {
            onSuccess()
          }
        });

        return cancelNoop
      }
    }
  }
};

exports._onConnect = function(client) {
  return function(onError, onSuccess) {
    client.on('connect', handler)
  }
}

exports._onMessage = function(handler) {
  return function(client) {
    return function() {
      client.on('message', handler)
    }
  }
};

exports._onClose = function(client) {
  return function(handler) {
    return function() {
      client.on('close', handler);
    }
  }
};

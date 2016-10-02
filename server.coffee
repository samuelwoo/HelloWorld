express = require "express"
path = require 'path'
settings = require "./app/config/settings"
errorMan = require './app/server/middleware/error'
employee = require "./app/server/manager/employee"

server =
  start: (cb) ->
    app = express()
    app.use errorMan
    app.use express.static(path.join(settings.path, 'public'))
    app.use express.bodyParser()
    require('./app/config/routes')(app)
    employee.instance().loadAll (err) ->
      if err
        console.log("Load employees failed because #{err}, Please fix it and then restart.")
        if cb then return cb(err) else return

      port = settings.server.port
      instance = app.listen port, ->
        server.running = true
        console.log "Server running on 127.0.0.1:#{port}."
        cb(null, instance, app) if cb

module.exports = server

# Start server if this file is executed from commandline
server.start() if process.argv[1] == __filename

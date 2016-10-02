path = require 'path'

appPath    = path.normalize(path.join(__dirname, '..'))
port       = parseInt(process.env.NODE_PORT) or 3000

settings =
  path: appPath
  server:
    port: port

module.exports = settings

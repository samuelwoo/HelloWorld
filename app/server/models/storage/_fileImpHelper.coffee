_ = require "lodash"
fs = require "fs"
path = require "path"

helper =
  fileNameFrom: (firstName, lastName) -> "#{firstName.toLocaleLowerCase()}_#{lastName.toLocaleLowerCase()}.json"
  pathNameFrom: (dirName) -> path.resolve("#{__dirname}/../../../storage/#{dirName}")
  writeTo: (fileName, content, cb) -> fs.writeFile fileName, JSON.stringify(content, null, 2), 'utf8', cb
  loadFrom: (fileName, cb) ->
    return cb("#{fileName} not exist") unless fs.existsSync(fileName)
    cb(null, require(fileName))

  loadAllFrom: (pathName, cb) ->
    fs.readdir pathName, (err, files) ->
      return cb(err) if err
      all = _.reduce files, (allDetails, file) ->
        return allDetails if file.indexOf('.json') < 0
        allDetails.push require("#{pathName}/#{file}")
        allDetails
      , []
      cb(null, all)


module.exports = helper

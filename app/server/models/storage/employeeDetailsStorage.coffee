_ = require "lodash"
fs = require "fs"
path = require "path"
helper = require "./_fileImpHelper"

###
  storage imp
###
class EmployeeDetailsStorageImp
  constructor: ->
  save: (employeeDetails, cb) -> cb("Override me")
  load: (firstName, lastName, cb) -> cb("Override me and cb with json obj")
  loadAll: (cb) -> cb("Override me")

###
  json file storage imp
###
class EmployeeDetailsFileImp extends EmployeeDetailsStorageImp
  storagePath: -> helper.pathNameFrom("details")
  filePathNameFrom: (firstName, lastName) -> "#{@storagePath()}/#{helper.fileNameFrom(firstName, lastName)}"
  save: (employeeDetails, cb) -> helper.writeTo @filePathNameFrom(employeeDetails.firstName, employeeDetails.lastName), employeeDetails, cb
  load: (firstName, lastName, cb) -> helper.loadFrom @filePathNameFrom(firstName, lastName), cb
  loadAll: (cb) -> helper.loadAllFrom @storagePath(), cb

module.exports = (storageType = 'file') ->
  switch storageType
    when "file" then new EmployeeDetailsFileImp()
    else new EmployeeDetailsFileImp()


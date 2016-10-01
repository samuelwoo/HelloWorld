_ = require "lodash"
fs = require "fs"
path = require "path"
helper = require "./_fileImpHelper"

###
  storage imp
###
class EmployeePayslipsStorageImp
  constructor: () ->
  save: (payslip, cb) -> cb("Override me")
  load: (firstName, lastName, cb) -> cb("Override me and cb with json obj")
  loadAll: (cb) -> cb("Override me")

###
  json file storage imp
###
class EmployeePayslipsFileImp extends EmployeePayslipsStorageImp
  constructor: () ->
  storagePath: -> helper.pathNameFrom("payslips")
  filePathNameFrom: (firstName, lastName) -> "#{@storagePath()}/#{helper.fileNameFrom(firstName, lastName)}"
  save: (firstName, lastName, payslips, cb) -> helper.writeTo @filePathNameFrom(firstName, lastName), payslips, cb
  load: (firstName, lastName, cb) -> helper.loadFrom @filePathNameFrom(firstName, lastName), cb
  loadAll: (cb) -> helper.loadAllFrom @storagePath(), cb

module.exports = (storageType = 'file') ->
  switch storageType
    when "file" then new EmployeePayslipsFileImp()
    else new EmployeePayslipsFileImp()

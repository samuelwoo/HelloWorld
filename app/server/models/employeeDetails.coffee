_ = require "lodash"
async = require "async"
storageImpFactory = require "./storage/employeeDetailsStorage"

###
  employee details
###
class EmployeeDetails
  @validate: (paras, cb) ->
    validators = {
      "firstName": (val, cb) ->
        return cb("FirstName is invalid") unless val
        cb()

      "lastName": (val, cb) ->
        return cb("LastName is invalid") unless val
        cb()

      "annualSalary": (val, cb) ->
        return cb("AnnualSalary is invalid") unless /^[0-9]*[1-9][0-9]*$/.test val
        cb()

      "superRate": (val, cb) ->
        return cb("SuperRate is invalid") unless val in [ 0 ... 51 ]
        cb()
    }

    _.defaults paras,
      firstName: ''
      lastName: ''
      annualSalary: 0
      superRate: 0

    doValidation = (fn, key, cb) -> fn(paras[key], cb)
    async.forEachOf validators, doValidation, (err) ->
      return cb(err) if err
      cb()

  @create: (opts, cb) ->
    EmployeeDetails.validate opts, (err) ->
      return cb(err) if err
      cb(null, new EmployeeDetails(opts.firstName, opts.lastName, opts.annualSalary, opts.superRate))

  @load: (firstName, lastName, cb) ->
    imp = storageImpFactory()
    imp.load firstName, lastName, (err, jsonObj) ->
      return cb(err) if err
      EmployeeDetails.create jsonObj, cb

  @loadAll: (cb) ->
    imp = storageImpFactory()
    imp.loadAll (err, jsonObjs) ->
      return cb(err) if err
      async.map jsonObjs, EmployeeDetails.create, (err, details) ->
        return cb(err) if err
        cb(null, details)

  constructor: (@firstName, @lastName, @annualSalary, @superRate) ->
    @imp = storageImpFactory()

  update: (@firstName, @lastName, @annualSalary, @superRate) ->

  save: (cb) -> @imp.save @, cb

  toJSON: ->
    jsonObj = {}
    jsonObj[k] = @[ k ] for k in _.without(Object.keys(@), 'imp')
    jsonObj

module.exports = EmployeeDetails

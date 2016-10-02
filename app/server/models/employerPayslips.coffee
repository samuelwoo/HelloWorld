_ = require 'lodash'
fs = require "fs"
path = require "path"
async = require "async"
storageImpFactory = require "./storage/employeePayslipsStorage"

###
  payslip
###
class EmployeePayslip
  @create: (opts, cb) ->
    _.defaults opts,
      payPeriod: ''
      grossIncome: 0,
      incomeTax: 0
      netIncome: 0
      super: 0

    cb(null, new EmployeePayslip(opts.payPeriod, opts.grossIncome, opts.incomeTax, opts.netIncome, opts.super))

  constructor: (@payPeriod, @grossIncome, @incomeTax, @netIncome, @super) ->
  update: (@payPeriod, @grossIncome, @incomeTax, @netIncome, @super) ->

###
  collection of payslip
###
class EmployeePayslips
  @load: (firstName, lastName, cb) ->
    imp = storageImpFactory()
    imp.load firstName, lastName, (err, jsonObj) ->
      async.map jsonObj, EmployeePayslip.create, (err, payslips) =>
        return cb(err) if err
        ps = new EmployeePayslips()
        ps.payslips = payslips
        cb(null, ps)

  constructor: ->
    @imp = storageImpFactory()
    @payslips = []

  paid: (payPeriod) -> _.find @payslips, payPeriod: payPeriod

  pay: (firstName, lastName, payPeriod, grossIncome, incomeTax, netIncome, superr, cb) ->
    @payslips.push new EmployeePayslip(payPeriod, grossIncome, incomeTax, netIncome, superr)
    @save firstName, lastName, cb

  save: (firstName, lastName, cb) -> @imp.save firstName, lastName, @, cb

  toJSON: -> @payslips

module.exports = EmployeePayslips

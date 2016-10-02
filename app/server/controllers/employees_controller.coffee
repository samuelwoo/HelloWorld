_              = require "lodash"
employee       = require "../manager/employee"

module.exports =
  get: (req, res, next) ->
    firstName = req.params.firstName
    lastName = req.params.lastName
    exist = employee.instance().find firstName, lastName
    if exist
      res.json exist
    else
      next("Employee #{firstName} #{lastName} not exist!")

  list: (req, res, next) ->
    res.json employee.instance()

  create: (req, res, next) ->
    firstName = req.body.firstName
    lastName = req.body.lastName
    annualSalary = parseInt req.body.annualSalary
    superRate = parseInt req.body.superRate

    employee.instance().createEmployee firstName, lastName, annualSalary, superRate, (err) ->
      return next(err) if err
      res.json "succeed"

  update: (req, res, next) ->
    firstName = req.params.firstName
    lastName = req.params.lastName
    annualSalary = parseInt req.body.annualSalary
    superRate = parseInt req.body.superRate

    employee.instance().updateEmployee firstName, lastName, annualSalary, superRate, (err) ->
      return next(err) if err
      res.json "succeed"

  destroy: (req, res, next) ->
    next("You can't do this")

  pay: (req, res, next) ->
    firstName = req.body.firstName
    lastName = req.body.lastName
    annualSalary = parseInt req.body.annualSalary
    superRate = parseInt req.body.superRate
    payPeriod = req.body.payPeriod

    employee.instance().pay firstName, lastName, annualSalary, superRate, payPeriod, (err) ->
      return next(err) if err
      res.json employee.instance().payslipsFor payPeriod

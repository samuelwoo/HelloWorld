_ = require "lodash"
fs = require "fs"
path = require "path"
async = require "async"
moment = require "moment"
taxConfig = require "../../config/tax.json"
employeeDetails = require "../models/employeeDetails.coffee"
employeePayslips = require "../models/employerPayslips.coffee"

DATE_FORMAT = "MM-YYYY"

###
  calculator
###
class PayslipCalculator
  @calculateGrossIncome: (annualSalary) -> Math.round(annualSalary / 12)
  @calculateIncomeTax: (annualSalary) ->
    inRange = (tax) ->
      tax.range.max ?= Infinity
      annualSalary > tax.range.min and annualSalary <= tax.range.max

    config = _.find taxConfig, inRange
    Math.round ( ( config.tax.base + ( annualSalary - config.range.min ) * config.tax.rate ) / 12 )

  @calculateNetIncome: (grossIncome, incomeTax) -> grossIncome - incomeTax
  @calculateSuper: (grossIncome, superRate) -> Math.round(grossIncome * superRate / 100)

###
  EmployeeManager
###
class EmployeeManager
  instance = null

  class Employee
    constructor: ->
      @allEmployees = []

    find: (firstName, lastName) -> _.find @allEmployees, (e) ->
      e.employeeDetails.firstName.toLocaleLowerCase() is firstName.toLocaleLowerCase() and
        e.employeeDetails.lastName.toLocaleLowerCase() is lastName.toLocaleLowerCase()

    loadAll: (cb) ->
      loadPaySlips = (details, cb) ->
        employeePayslips.load details.firstName, details.lastName, (err, payslips) ->
          return cb(err) if err
          console.log "--- Employee #{details.firstName} #{details.lastName} with all payslips loaded ---"
          cb(null, employeeDetails: details, employeePayslips: payslips)

      employeeDetails.loadAll (err, allDetails) =>
        return cb(err) if err
        async.map allDetails, loadPaySlips, (err, @allEmployees) =>
          return cb(err) if err
          cb(null, @allEmployees)

    saveAll: (cb) ->
      async.each @allEmployees, (employee) ->
        employee.employeePayslips.save employee.employeeDetails.firstName, employee.employeeDetails.lastName, (err) ->
          return cb(err) if err
          employee.employeeDetails.save cb


    pay: (firstName, lastName, annualSalary, superRate, payPeriod, cb) ->
      payFor = (whom, cb) ->
        grossIncome = PayslipCalculator.calculateGrossIncome(whom.employeeDetails.annualSalary)
        incomeTax = PayslipCalculator.calculateIncomeTax(whom.employeeDetails.annualSalary)
        netIncome = PayslipCalculator.calculateNetIncome(grossIncome, incomeTax)
        superr = PayslipCalculator.calculateSuper(grossIncome, whom.employeeDetails.superRate)
        paid = whom.employeePayslips.paid(payPeriod)
        if paid
          paid.update(payPeriod, grossIncome, incomeTax, netIncome, superr)
          whom.employeePayslips.save firstName, lastName, cb
        else
          whom.employeePayslips.pay firstName, lastName, payPeriod, grossIncome, incomeTax, netIncome, superr, cb

      exist = @find firstName, lastName
      if not exist
        @createEmployee firstName, lastName, annualSalary, superRate, (err) =>
          return cb(err) if err
          exist = @find firstName, lastName
          payFor exist, cb
      else
        @updateEmployee firstName, lastName, annualSalary, superRate, (err) ->
          return cb(err) if err
          payFor exist, cb

    createEmployee: (firstName, lastName, annualSalary, superRate, cb) ->
      return cb("Employee #{firstName} #{lastName} exist") if exist = @find firstName, lastName

      opts =
        firstName: firstName
        lastName: lastName
        annualSalary: annualSalary
        superRate: superRate

      employeeDetails.create opts, (err, details) =>
        return cb(err) if err
        @allEmployees.push employeeDetails: details, employeePayslips: new employeePayslips()
        details.save cb

    updateEmployee: (firstName, lastName, annualSalary, superRate, cb) ->
      return cb("Employee #{firstName} #{lastName} not exist") unless exist = @find firstName, lastName

      opts =
        firstName: firstName
        lastName: lastName
        annualSalary: annualSalary
        superRate: superRate
      employeeDetails.validate opts, (err) ->
        return cb(err) if err
        exist.employeeDetails.update(firstName, lastName, annualSalary, superRate)
        exist.employeeDetails.save cb

    payslipsFor: (payPeriod) ->
      _.map @allEmployees, (e) ->
        employeeDetails: e.employeeDetails
        employeePayslip: e.employeePayslips.paid(payPeriod)

    toJSON: -> @allEmployees

  @instance : ->
    instance ?= new Employee()

module.exports = EmployeeManager


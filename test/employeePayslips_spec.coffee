_ = require "lodash"
sinon = require('sinon')
should = require 'should'
payslips = require "../app/server/models/employerPayslips.coffee"

describe "employeePayslips", ->
  ps = null
  before (done) ->
    ps = new payslips()
    sinon.stub ps, 'save', (firstName, lastName, cb) -> cb(null, firstName: firstName, lastName: lastName)
    done()

  after ->
    ps.save.restore()

  describe "#pay", ->
    it "should be able to pay and then save without error", (done) ->
      ps.pay "Jack", "Smith", "08-2016", 12, 23, 34, 45, (err, result) ->
        should.not.exist err
        JSON.stringify(ps).should.eql JSON.stringify([
          payPeriod: '08-2016'
          grossIncome: 12,
          incomeTax: 23
          netIncome: 34
          super: 45
        ])
        result.should.eql firstName: "Jack", lastName: "Smith"
        done()



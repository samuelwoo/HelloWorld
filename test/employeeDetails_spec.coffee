_ = require "lodash"
sinon = require('sinon')
should = require 'should'
detail = require "../app/server/models/employeeDetails.coffee"

describe "employeeDetails", ->
  buildParams = (firstName = '', lastName = '', annualSalary = 0, superRate = 0) ->
    firstName: firstName
    lastName: lastName
    annualSalary: annualSalary
    superRate: superRate

  describe "#validation", ->
    it "should return error when firstName is null", (done) ->
      detail.create buildParams(), (err) ->
        should.exist err
        err.should.eql "FirstName is invalid"
        done()

    it "should return error when lastName is null", (done) ->
      detail.create buildParams("jack"), (err) ->
        should.exist err
        err.should.eql "LastName is invalid"
        done()

    it "should return error when annualSalary is negative", (done) ->
      detail.create buildParams("jack", "smith", -1), (err) ->
        should.exist err
        err.should.eql "AnnualSalary is invalid"
        done()

    it "should return error when superRate is < 0", (done) ->
      detail.create buildParams("jack", "smith", 10000, -1), (err) ->
        should.exist err
        err.should.eql "SuperRate is invalid"
        done()

    it "should return error when superRate is > 50", (done) ->
      detail.create buildParams("jack", "smith", 10000, 51), (err) ->
        should.exist err
        err.should.eql "SuperRate is invalid"
        done()

  describe "#create", ->
    it "should be able to create employee details", (done) ->
      opts = buildParams("Jack", "Smith", 30000, 20)
      detail.create opts, (err, instance) ->
        should.not.exist err
        JSON.stringify(instance).should.eql JSON.stringify(opts)
        done()

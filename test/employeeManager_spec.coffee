_ = require "lodash"
fs = require "fs"
should = require "should"
helper = require "../app/server/models/storage/_fileImpHelper.coffee"
em = require "../app/server/manager/employee.coffee"

describe "employeeManager", ->
  describe "#pay", ->
    describe "when employee not exist", ->
      it "should calculate correct and pay without error", (done) ->
        em.instance().pay "John", "Lewis", 10000, 10, "03-2016", (err) ->
          should.not.exist err
          details_path = helper.pathNameFrom("details")
          payslips_path = helper.pathNameFrom("payslips")
          fileName = helper.fileNameFrom("John", "Lewis")
          fs.existsSync("#{details_path}/#{fileName}").should.eql true
          fs.existsSync("#{payslips_path}/#{fileName}").should.eql true
          exist = em.instance().find "John", "Lewis"
          should.exist exist
          JSON.stringify(exist.employeeDetails).should.eql '{"firstName":"John","lastName":"Lewis","annualSalary":10000,"superRate":10}'
          JSON.stringify(exist.employeePayslips).should.eql '[{"payPeriod":"03-2016","grossIncome":833,"incomeTax":0,"netIncome":833,"super":83}]'
          done()

    describe "when employee exists", ->
      describe "same pay period", ->
        describe "same details", ->
          it "should calculate correct and pay", (done) ->
            em.instance().pay "John", "Lewis", 10000, 10, "03-2016", (err) ->
              should.not.exist err
              details_path = helper.pathNameFrom("details")
              payslips_path = helper.pathNameFrom("payslips")
              fileName = helper.fileNameFrom("John", "Lewis")
              fs.existsSync("#{details_path}/#{fileName}").should.eql true
              fs.existsSync("#{payslips_path}/#{fileName}").should.eql true
              exist = em.instance().find "John", "Lewis"
              should.exist exist
              JSON.stringify(exist.employeeDetails).should.eql '{"firstName":"John","lastName":"Lewis","annualSalary":10000,"superRate":10}'
              JSON.stringify(exist.employeePayslips).should.eql '[{"payPeriod":"03-2016","grossIncome":833,"incomeTax":0,"netIncome":833,"super":83}]'
              done()

        describe "different detail", ->
          it "should able to update detail and calculate then pay", (done) ->
            em.instance().pay "John", "Lewis", 30000, 20, "03-2016", (err) ->
              should.not.exist err
              details_path = helper.pathNameFrom("details")
              payslips_path = helper.pathNameFrom("payslips")
              fileName = helper.fileNameFrom("John", "Lewis")
              fs.existsSync("#{details_path}/#{fileName}").should.eql true
              fs.existsSync("#{payslips_path}/#{fileName}").should.eql true
              exist = em.instance().find "John", "Lewis"
              should.exist exist
              JSON.stringify(exist.employeeDetails).should.eql '{"firstName":"John","lastName":"Lewis","annualSalary":30000,"superRate":20}'
              JSON.stringify(exist.employeePayslips).should.eql '[{"payPeriod":"03-2016","grossIncome":2500,"incomeTax":187,"netIncome":2313,"super":500}]'
              done()

      describe "different pay period", ->
        describe "same details", ->
          it "should calculate correct and pay", (done) ->
            em.instance().pay "John", "Lewis", 30000, 20, "04-2016", (err) ->
              should.not.exist err
              details_path = helper.pathNameFrom("details")
              payslips_path = helper.pathNameFrom("payslips")
              fileName = helper.fileNameFrom("John", "Lewis")
              fs.existsSync("#{details_path}/#{fileName}").should.eql true
              fs.existsSync("#{payslips_path}/#{fileName}").should.eql true
              exist = em.instance().find "John", "Lewis"
              should.exist exist
              JSON.stringify(exist.employeeDetails).should.eql '{"firstName":"John","lastName":"Lewis","annualSalary":30000,"superRate":20}'
              JSON.stringify(exist.employeePayslips).should.eql '[{"payPeriod":"03-2016","grossIncome":2500,"incomeTax":187,"netIncome":2313,"super":500},{"payPeriod":"04-2016","grossIncome":2500,"incomeTax":187,"netIncome":2313,"super":500}]'
              done()

        describe "different detail", ->
          it "should able to update detail and calculate then pay", (done) ->
            em.instance().pay "John", "Lewis", 550000, 20, "02-2016", (err) ->
              should.not.exist err
              details_path = helper.pathNameFrom("details")
              payslips_path = helper.pathNameFrom("payslips")
              fileName = helper.fileNameFrom("John", "Lewis")
              fs.existsSync("#{details_path}/#{fileName}").should.eql true
              fs.existsSync("#{payslips_path}/#{fileName}").should.eql true
              exist = em.instance().find "John", "Lewis"
              should.exist exist
              JSON.stringify(exist.employeeDetails).should.eql '{"firstName":"John","lastName":"Lewis","annualSalary":550000,"superRate":20}'
              JSON.stringify(exist.employeePayslips).should.eql '[{"payPeriod":"03-2016","grossIncome":2500,"incomeTax":187,"netIncome":2313,"super":500},{"payPeriod":"04-2016","grossIncome":2500,"incomeTax":187,"netIncome":2313,"super":500},{"payPeriod":"02-2016","grossIncome":45833,"incomeTax":18421,"netIncome":27412,"super":9167}]'
              done()

    describe "json file", ->
      it "should storage correct", (done) ->
        details_path = helper.pathNameFrom("details")
        payslips_path = helper.pathNameFrom("payslips")
        fileName = helper.fileNameFrom("John", "Lewis")
        require("#{details_path}/#{fileName}").should.eql {
          annualSalary: 550000,
          firstName: 'John',
          lastName: 'Lewis',
          superRate: 20
        }
        require("#{payslips_path}/#{fileName}").should.eql [
          {
            grossIncome: 2500,
            incomeTax: 187,
            netIncome: 2313,
            payPeriod: '03-2016',
            super: 500
          },
          {
            grossIncome: 2500,
            incomeTax: 187,
            netIncome: 2313,
            payPeriod: '04-2016',
            super: 500
          },
          {
            grossIncome: 45833,
            incomeTax: 18421,
            netIncome: 27412,
            payPeriod: '02-2016',
            super: 9167
          }
        ]
        done()

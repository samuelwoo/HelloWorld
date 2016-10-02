_ = require "lodash"
settings = require "./settings"

controllers =
  employees: require "../server/controllers/employees_controller"

module.exports = (app) ->
  resources = (name, controller) ->
    app.get "#{name}", controller["list"]
    app.post "#{name}", controller["create"]
    app.put "#{name}/:firstName&:lastName", controller["update"]
    app.get "#{name}/:firstName&:lastName", controller["get"]
    app.delete "#{name}/:firstName&:lastName", controller["destroy"]

  resources "/employee", controllers.employees
  app.post "/employee/pay", controllers.employees["pay"]

  app.get "/", (req, res, next) ->
    res.sendfile "#{settings.path}/public/html/main.html"



module.exports = (err, req, res, next) ->
  logThenSendError = (err) ->
    console.log "err is : ",err, typeof(err)
    errMsg =
      if typeof(err) is 'object'
        JSON.stringify err, null, 2
      else if typeof(err) is 'string'
        err
    res.status(500).send errMsg

  logThenSendError err


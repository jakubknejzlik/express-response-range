responseRange = require('../index')
express = require('express')
contentRange = require('content-range')

data = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29]

module.exports = (options)->

  app = new express()

  app.use(responseRange(options))

  app.get('/range',(req,res,next)->
    res.send(req.range)
  )

  app.get('/',(req,res,next)->
    slicedData = data.slice(req.range.offset,req.range.offset + req.range.limit)
    res.sendRange(slicedData)
  )
  app.get('/known-length',(req,res,next)->
    slicedData = data.slice(req.range.offset,req.range.offset + req.range.limit)
    res.sendRange(slicedData,data.length)
  )

  return app

module.exports.data = data

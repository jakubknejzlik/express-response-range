extend = require('extend')
clone = require('clone')
contentRange = require('content-range')
rangeParse = require('http-range-parse')

defaultOptions = {
  unit: 'items'
  queryFallback: yes
  alwaysSendRange: no
  defaultLimit: 10
  zeroBasePagination: no
}



module.exports = (options = {})->
  options = extend(clone(defaultOptions),options)
  return (req,res,next)->

    range = req.get('Range')
    if range
      parsedRange = rangeParse(range)
      req.range = {offset:parsedRange.first,limit:(parsedRange.last - parsedRange.first + 1) or options.defaultLimit,unit:parsedRange.unit}

      res.setHeader('Accept-Ranges',options.unit)

    else if options.queryFallback
      range = {limit:options.defaultLimit,offset:0,unit:options.unit}
      if req.query.limit
        range.limit = Math.max(parseInt(req.query.limit),0)
      if options.maxLimit and parseInt(options.maxLimit)
        range.limit = Math.min(parseInt(options.maxLimit),range.limit)
      if req.query.offset
        range.offset = Math.max(parseInt(req.query.offset),0)
      if req.query.page
        page = parseInt(req.query.page)
        if not options.zeroBasePagination
          page = page - 1
          page = Math.max(page,0)
        range.offset = range.limit * page
      req.range = range

    res.sendRange = (data,count)->
      range = req.get('range')
      if range or options.alwaysSendRange
        if req.range
          @status(206)
          @setHeader('Content-Range',contentRange.format({
            offset: req.range.offset
            limit: data.length or req.range.limit
            count: count
            name: req.range.unit
          }))
        @send(data)
      else
        response = {}
        if count
          response.count = count
        response[options.unit] = data
        @send(response)

    next()



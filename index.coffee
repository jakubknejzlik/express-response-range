extend = require('extend')
contentRange = require('content-range')
rangeParse = require('http-range-parse')

defaultOptions = {
  unit: 'items'
  queryFallback: yes
  defaultLimit: 10
  zeroBasePagination: no
}



module.exports = (options = {})->
  options = extend(options,defaultOptions)
  return (req,res,next)->

    range = req.get('Range')
    if range
      parsedRange = rangeParse(range)
      req.range = {offset:parsedRange.first,limit:parsedRange.last - parsedRange.first + 1,unit:parsedRange.unit}

      res.setHeader('Accept-Ranges',options.unit)

    else if options.queryFallback
      range = {limit:options.defaultLimit,offset:0,unit:options.unit}
      if req.query.limit
        range.limit = parseInt(req.query.limit)
      if req.query.offset
        range.offset = parseInt(req.query.offset)
      if req.query.page
        page = parseInt(req.query.page)
        if not options.zeroBasePagination
          page = page - 1
          page = Math.max(page,0)
        range.offset = range.limit * page
      req.range = range

    res.sendRange = (data,count)->
      if req.get('range')
        @status(206)
      @setHeader('Content-Range',contentRange.format({
        offset: req.range.offset
        limit: req.range.limit
        count: count
        name: req.range.unit
      }))
      @send(data)

    next()



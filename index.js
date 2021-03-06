// Generated by CoffeeScript 1.10.0
(function() {
  var clone, contentRange, defaultOptions, extend, rangeParse;

  extend = require('extend');

  clone = require('clone');

  contentRange = require('content-range');

  rangeParse = require('http-range-parse');

  defaultOptions = {
    unit: 'items',
    queryFallback: true,
    alwaysSendRange: false,
    defaultLimit: 10,
    zeroBasePagination: false
  };

  module.exports = function(options) {
    if (options == null) {
      options = {};
    }
    options = extend(clone(defaultOptions), options);
    return function(req, res, next) {
      var page, parsedRange, range;
      range = req.get('Range');
      if (range) {
        parsedRange = rangeParse(range);
        req.range = {
          offset: parsedRange.first,
          limit:
            parsedRange.last - parsedRange.first + 1 || options.defaultLimit,
          unit: parsedRange.unit
        };
        res.setHeader('Accept-Ranges', options.unit);
      } else if (options.queryFallback) {
        range = {
          limit: options.defaultLimit,
          offset: 0,
          unit: options.unit
        };
        if (req.query.limit) {
          range.limit = Math.max(parseInt(req.query.limit), 0);
        }
        if (options.maxLimit && parseInt(options.maxLimit)) {
          range.limit = Math.min(parseInt(options.maxLimit), range.limit);
        }
        if (req.query.offset) {
          range.offset = Math.max(parseInt(req.query.offset), 0);
        }
        if (typeof req.query.page !== 'undefined') {
          page = parseInt(req.query.page);
          if (!options.zeroBasePagination) {
            page = page - 1;
            page = Math.max(page, 0);
          }
          range.offset = range.limit * page;
        }
        range.page =
          Math.floor(range.offset / range.limit) +
          (!options.zeroBasePagination ? 1 : 0);

        req.range = range;
      }
      res.sendRange = function(data, count) {
        var response;
        range = req.get('range');
        if (range || options.alwaysSendRange) {
          if (req.range) {
            this.status(206);
            this.setHeader(
              'Content-Range',
              contentRange.format({
                offset: req.range.offset,
                limit: data.length || req.range.limit,
                count: count,
                name: req.range.unit
              })
            );
          }
          return this.send(data);
        } else {
          response = {};
          if (count) {
            response.count = count;
          }
          response[options.unit] = data;
          response.offset = req.range.offset;
          response.page = req.range.page;
          return this.send(response);
        }
      };
      return next();
    };
  };
}.call(this));

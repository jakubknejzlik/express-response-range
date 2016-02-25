# express-response-range

Middleware for handling content-range with querystring fallback.

[![Build Status](https://travis-ci.org/jakubknejzlik/express-response-range.svg?branch=master)](https://travis-ci.org/jakubknejzlik/express-response-range)

# Example

```
 express = require('express')
 responseRange = require('express-response-range')


 var data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

 var options = {};
 
 var app = new express();
 app.use(responseRange(options)); // creates req.range and expose res.sendRange(data[,count]) method
    
 app.get('/', function(req, res, next) {
  var slicedData;
  slicedData = data.slice(req.range.offset, req.range.offset + req.range.limit);
  return res.sendRange(slicedData,slicedData.length); // send data and sets 206 status if request Range header is set 
 });

 app.listen(process.env.PORT)

```

# API

## constructor([options])

Returns middleware handling range header. For every call the `req.range` is created from request headers/querystring. 

* `options`
    * `unit` - name of unit (default `items`)
    * `queryFallback` - enable query fallback for requests without range (default `true`)
    * `alwaysSendRange` - send range response (plain payload) for non-ranged request (default `false`)
    * `defaultLimit` - default limit for response (default `10`)
    * `zeroBasePagination` - page parameter starts from 0 (default `false`)
    
## res.sendRange(data[,count])

Sends response (with `res.send`) and creates content-range header (or creates payload `{items:[],count:X}` for queryFallback)

* `data` - data to send to response
* `count` - number of items in whole collection (sent with range `items 0-10/X`)


# Query Fallback

When client doesn't support ranges, querystring parameters could be used (`?offset&limit&page`).

* page - can be used to compute `offset` (`offset = (page-1) * limit`)

*Note* - when using `zeroBasedPagination` the `page` parameter could be from zero (`offset = page * limit`)

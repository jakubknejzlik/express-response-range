# express-response-range

Middleware for handling content-range with querystring fallback.

[![Build Status](https://travis-ci.org/jakubknejzlik/express-response-range.svg?branch=master)](https://travis-ci.org/jakubknejzlik/express-response-range)

# Example

```
 express = require('express')
 expressResponseError = require('express-response-error')


 var data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

 var app = new express();
 app.use(responseRange()); // creates req.range and expose res.sendRange(data[,count]) method
    
 app.get('/', function(req, res, next) {
  var slicedData;
  slicedData = data.slice(req.range.offset, req.range.offset + req.range.limit);
  return res.sendRange(slicedData,slicedData.length); // send data and sets 206 status if request Range header is set 
 });

 app.listen(process.env.PORT)

```

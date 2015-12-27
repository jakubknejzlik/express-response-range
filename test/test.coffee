assert = require('assert')
responseRange = require('../index')
express = require('express')
supertest = require('supertest')
contentRange = require('content-range')

data = [0,1,2,3,4,5,6,7,8]


app = new express()

app.use(responseRange())

app.get('/range',(req,res,next)->
  res.send(req.range)
)

app.get('/',(req,res,next)->
  slicedData = data.slice(req.range.offset,req.range.offset + req.range.limit)
  res.sendRange(slicedData)
)
app.get('/known-length',(req,res,next)->
  slicedData = data.slice(req.range.offset,req.range.offset + req.range.limit)
  res.sendRange(slicedData,slicedData.length)
)


test = supertest(app)


describe('express-content-range',()->
  it('should get valid range',(done)->
    range = {unit:'items',offset:25,limit:10}
    test.get('/range')
    .set('Range','items=25-34')
    .expect(206)
    .expect((res)->
      assert.deepEqual(res.body,range)
    ).end(done)
  )

  it('should get valid range for query',(done)->
    range = {offset:45,limit:15,unit:'items'}
    test.get('/range?limit=15&page=4')
    .expect(200)
    .expect((res)->
      assert.deepEqual(res.body,range)
    ).end(done)
  )

  it('should get valid content/range',(done)->
    test.get('/')
    .set('Range','items=0-3')
    .expect(206)
    .expect((res)->
      assert.equal(res.headers['content-range'],'items 0-3/*')
      assert.deepEqual(res.body,data.slice(0,4))
    ).end(done)
  )

  it('should get valid content/range for query',(done)->
    test.get('/?limit=2&page=2')
    .expect(200)
    .expect((res)->
      assert.equal(res.headers['content-range'],'items 2-3/*')
      assert.deepEqual(res.body,data.slice(2,4))
    ).end(done)
  )

  it('should get valid content/range/length',(done)->
    test.get('/known-length')
    .set('Range','items=0-3')
    .expect(206)
    .expect((res)->
      assert.equal(res.headers['content-range'],'items 0-3/4')
      assert.deepEqual(res.body,data.slice(0,4))
    ).end(done)
  )

  it('should get valid content/range/length for query',(done)->
    test.get('/known-length?limit=2&page=2')
    .expect(200)
    .expect((res)->
      assert.equal(res.headers['content-range'],'items 2-3/2')
      assert.deepEqual(res.body,data.slice(2,4))
    ).end(done)
  )
)
assert = require('assert')
supertest = require('supertest')


data = require('./test-app').data

test = supertest(require('./test-app')())
testAlwaysRange = supertest(require('./test-app')({defaultLimit:20,maxLimit:21,alwaysSendRange:yes}))


describe('express-content-range',()->
  it('should get valid range',(done)->
    range = {unit:'items',offset:25,limit:10}
    test.get('/range')
    .set('Range','items=25-34')
    .expect(200)
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
      assert.deepEqual(res.body.items,data.slice(2,4))
    ).end(done)
  )

  it('should get valid content/range/length for closed interval',(done)->
    test.get('/known-length')
    .set('Range','items=0-3')
    .expect(206)
    .expect((res)->
      assert.equal(res.headers['content-range'],'items 0-3/30')
      assert.deepEqual(res.body,data.slice(0,4))
    ).end(done)
  )
  it('should get valid content/range/length for opened interval',(done)->
    test.get('/known-length')
    .set('Range','items=0-')
    .expect(206)
    .expect((res)->
      assert.equal(res.headers['content-range'],'items 0-9/30')
      assert.deepEqual(res.body,data.slice(0,10))
    ).end(done)
  )

  it('should get valid content/range/length for opened offset interval',(done)->
    test.get('/known-length')
    .set('Range','items=5-')
    .expect(206)
    .expect((res)->
      assert.equal(res.headers['content-range'],'items 5-14/30')
      assert.deepEqual(res.body,data.slice(5,15))
    ).end(done)
  )

  it('should get valid content/range/length for query',(done)->
    test.get('/known-length?limit=2&page=2')
    .expect(200)
    .expect((res)->
      assert.deepEqual(res.body.items,data.slice(2,4))
    ).end(done)
  )

  it('should get valid content/range/length for always query',()->
    testAlwaysRange.get('/known-length?limit=2&page=2')
    .expect(200)
    .expect((res)->
      assert.equal(res.headers['content-range'],undefined)
      assert.deepEqual(res.body,data.slice(2,4))
    )
  )

  it('should respect max limit',()->
    testAlwaysRange.get('/known-length?limit=100&offset=2')
    .expect(200)
    .expect((res)->
      assert.equal(res.headers['content-range'],undefined)
      assert.deepEqual(res.body,data.slice(2,23))
    )
  )
)
// Generated by CoffeeScript 1.10.0
(function() {
  var assert, data, supertest, test, testAlwaysRange;

  assert = require('assert');

  supertest = require('supertest');

  data = require('./test-app').data;

  test = supertest(require('./test-app')());

  testAlwaysRange = supertest(require('./test-app')({
    defaultLimit: 20,
    alwaysSendRange: true
  }));

  describe('express-content-range', function() {
    it('should get valid range', function(done) {
      var range;
      range = {
        unit: 'items',
        offset: 25,
        limit: 10
      };
      return test.get('/range').set('Range', 'items=25-34').expect(200).expect(function(res) {
        return assert.deepEqual(res.body, range);
      }).end(done);
    });
    it('should get valid range for query', function(done) {
      var range;
      range = {
        offset: 45,
        limit: 15,
        unit: 'items'
      };
      return test.get('/range?limit=15&page=4').expect(200).expect(function(res) {
        return assert.deepEqual(res.body, range);
      }).end(done);
    });
    it('should get valid content/range', function(done) {
      return test.get('/').set('Range', 'items=0-3').expect(206).expect(function(res) {
        assert.equal(res.headers['content-range'], 'items 0-3/*');
        return assert.deepEqual(res.body, data.slice(0, 4));
      }).end(done);
    });
    it('should get valid content/range for query', function(done) {
      return test.get('/?limit=2&page=2').expect(200).expect(function(res) {
        return assert.deepEqual(res.body.items, data.slice(2, 4));
      }).end(done);
    });
    it('should get valid content/range/length', function(done) {
      return test.get('/known-length').set('Range', 'items=0-3').expect(206).expect(function(res) {
        assert.equal(res.headers['content-range'], 'items 0-3/9');
        return assert.deepEqual(res.body, data.slice(0, 4));
      }).end(done);
    });
    it('should get valid content/range/length', function(done) {
      return test.get('/known-length').set('Range', 'items=0-').expect(206).expect(function(res) {
        assert.equal(res.headers['content-range'], 'items 0-8/9');
        return assert.deepEqual(res.body, data.slice(0, 9));
      }).end(done);
    });
    it('should get valid content/range/length', function(done) {
      return test.get('/known-length').set('Range', 'items=5-').expect(206).expect(function(res) {
        assert.equal(res.headers['content-range'], 'items 5-8/9');
        return assert.deepEqual(res.body, data.slice(5, 9));
      }).end(done);
    });
    it('should get valid content/range/length for query', function(done) {
      return test.get('/known-length?limit=2&page=2').expect(200).expect(function(res) {
        return assert.deepEqual(res.body.items, data.slice(2, 4));
      }).end(done);
    });
    return it('should get valid content/range/length for query', function(done) {
      return testAlwaysRange.get('/known-length?limit=2&page=2').expect(200).expect(function(res) {
        assert.equal(res.headers['content-range'], void 0);
        return assert.deepEqual(res.body, data.slice(2, 4));
      }).end(done);
    });
  });

}).call(this);

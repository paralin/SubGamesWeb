'use strict';

var should = require('should');
var app = require('../../app');
var User = require('./user.model');

var user = new User({
  authItems: [],
  profile: {
    name: "test user"
  },
  steam: {
    steamid: "76561198029304414",
    communityvisibilitystate: 1,
    profilestate: 1,
    personaname: "test user",
    lastlogoff: 4,
    commentpermission: 1,
    profileurl: "http://steamcommunity.com/id/kidovate",
    avatar: "http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/5c/5c82337faff6f3e87a3c1434cd0001afa7632c3e.jpg",
    avatarmedium: "http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/5c/5c82337faff6f3e87a3c1434cd0001afa7632c3e.jpg",
    avatarfull: "http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/5c/5c82337faff6f3e87a3c1434cd0001afa7632c3e.jpg",
    personastate: 1,
    realname: "Test User",
    primaryclanid: "103582791432550288",
    timecreated: 1000000,
    personastateflags: 1,
    gameextrainfo: "Dota 2",
    gameid: "570",
    loccountrycode: "US",
    locstatecode: 'CA',
    loccityid: 5
  }
});

describe('User Model', function() {
  before(function(done) {
    // Clear users before testing
    User.remove().exec().then(function() {
      done();
    });
  });

  afterEach(function(done) {
    User.remove().exec().then(function() {
      done();
    });
  });

  it('should begin with no users', function(done) {
    User.find({}, function(err, users) {
      users.should.have.length(0);
      done();
    });
  });

  it('should fail when saving a duplicate user', function(done) {
    user.save(function() {
      var userDup = new User(user);
      userDup.save(function(err) {
        should.exist(err);
        done();
      });
    });
  });

  it('should fail when saving without a steam id', function(done) {
    user.steam.steamid = '';
    user.save(function(err) {
      should.exist(err);
      done();
    });
  });

  it('should fail when saving without a valid steam id', function(done) {
    user.steam.steamid = '351djb325325jnsebt23';
    user.save(function(err) {
      should.exist(err);
      done();
    });
  });
});

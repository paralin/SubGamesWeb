'use strict';

var User = require('./user.model');
var passport = require('passport');
var config = require('../../config/environment');
var jwt = require('jsonwebtoken');

var validationError = function(res, err) {
  return res.json(422, err);
};

exports.status = function(req, res){  
  var resp = {};
  resp.isAuthed = req.user != null;
  if(req.user){
    resp.sessID = req.sessionID;
    var user = {
      _id: req.user._id,
      profile: req.user.profile,
      authItems: req.user.authItems
    };
    if(req.user.steam) user.steam = req.user.steam;
    if(req.user.twitchtv) user.twitchtv = req.user.twitchtv;
    var profile = {
      _id: req.user._id,
      steamid: req.user.steam.steamid
    }
    resp.token = jwt.sign(profile, config.secrets.session, {algorithm:'HS256'});//{expiresInMinutes: 5});
    resp.server = config.networkServer;
    resp.user = user;
  }
  res.json(resp);
};

'use strict';

var express = require('express');
var passport = require('passport');
var auth = require('../auth.service');
var _ = require('lodash');

var router = express.Router();

var auth = function(req, res, next){
  var redir = {
    failureRedirect: '/authreturn'
  };
  if(!req.isAuthenticated()) passport.authenticate('steam', redir)(req, res, next);
  else passport.authorize('steam', redir)(req, res, next);
};

var successRedir = function(req, res, next){
  res.redirect('/authreturn');
};

router.get('/', auth, successRedir);
router.get('/return', auth, successRedir);

var disconnect = function(req, res, next){
  if(req.user){
    if(req.user.twitchtv && !_.isEmpty(req.user.twitchtv)){
      req.user.steam = undefined;
      req.user.save();
    }else{
      req.logout();
    }
  }
};

router.get('/disconnect', disconnect, function(req, res){
  res.redirect("/authreturn");
});

module.exports = router;

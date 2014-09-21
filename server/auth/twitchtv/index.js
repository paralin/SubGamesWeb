'use strict';

var express = require('express');
var passport = require('passport');
var auth = require('../auth.service');

var router = express.Router();

var auth = function(req, res, next){
  var redir = {
    failureRedirect: '/loginProblem'
  };
  if(!req.isAuthenticated()) passport.authenticate('twitchtv', redir)(req, res, next);
  else passport.authorize('twitchtv', redir)(req, res, next);
};

var successRedir = function(req, res, next){
  res.redirect('/');
};

router.get('/', auth, successRedir);
router.get('/return', auth, successRedir);

module.exports = router;

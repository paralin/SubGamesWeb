'use strict';

var mongoose = require('mongoose');
var passport = require('passport');
var config = require('../config/environment');
var User = require('../api/user/user.model');
var compose = require('composable-middleware');
var _ = require('lodash');

/**
 * Attaches the user object to the request if authenticated
 * Otherwise returns 403
 */
function isAuthenticated() {
  return compose()
    .use(function(req, res, next) {
      if(req.user) next();
      else res.send(401);
    });
}

/**
 * Checks if the user role meets the minimum requirements of the route
 */
function hasRole(roleRequired) {
  if (!roleRequired) throw new Error('Required role needs to be set');

  return compose()
  .use(isAuthenticated())
  .use(function meetsRequirements(req, res, next) {
    if (_.contains(req.user.authItems, roleRequired)) {
      next();
    }
    else {
      res.send(403);
    }
  });
}

exports.isAuthenticated = isAuthenticated;
exports.hasRole = hasRole;

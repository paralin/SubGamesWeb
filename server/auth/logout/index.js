'use strict';

var express = require('express');
var auth = require('../auth.service');

var router = express.Router();

router.get('/', function(req, res){  
  req.logout();
  res.redirect('/login');
});

module.exports = router;

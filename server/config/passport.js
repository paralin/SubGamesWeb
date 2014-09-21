var session = require('express-session');
var MongoStore = require('connect-mongo')(session);
var cookieParser = require('cookie-parser');
var passport = require('passport');
var config = require('./environment');

module.exports = function(app){
  app.use(cookieParser(config.secrets.session));
  app.use(session({
    secret: config.secrets.session,
    cookie: {
      maxAge: 86400000
    },
    store: new MongoStore({
      url: config.mongo.uri
    })
  }));
  app.use(passport.initialize());
  app.use(passport.session());
};

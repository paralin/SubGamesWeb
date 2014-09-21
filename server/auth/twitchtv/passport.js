var passport = require('passport');
var TwitchStrategy = require('passport-twitchtv').Strategy;

exports.setup = function (User, config) {
  scope = "user_read user_follows_edit user_subscriptions channel_check_subscription";
  passport.use(new TwitchStrategy({
    clientID: process.env.TWITCH_ID,
    clientSecret: process.env.TWITCH_SECRET,
    callbackURL: process.env.DOMAIN+'/auth/twitchtv/return',
    scope: scope,
    passReqToCallback: true
  },
  function(req, accessToken, refreshToken, profile, done){
    var prof = {
      id: profile.id,
      displayName: profile.displayName,
      email: profile.email,
      username: profile.username,
      logo: profile._json.logo,
      profileurl: profile._json._links.self
    };
    var tok = {
      access: accessToken,
      refresh: refreshToken,
      scope: scope
    };
    User.findOne({'twitchtv.id': prof.id}, function(err, user){
      if(err) return done(err);
      if(req.user){
        if(user && req.user._id !== user._id){
          if(user.steam){
            user.twitchtv = user.twitchtv_tokens = null;
            user.save();
          }else{
            console.log("Deleting user "+user._id+" when linking with Twitch.");
            User.remove({'_id': user._id});
          }
        }
        req.user.twitchtv = prof;
        req.user.twitchtv_tokens = tok;
        req.user.save(function(err){
          return done(err, req.user);
        });
      }
      else{
        if(user){
          user.twitchtv = prof;
          user.twitchtv_tokens = tok;
          user.save(function(error){
            return done(error, user);
          });
        }else{
          require('crypto').randomBytes(12, function(ex, buf){
            var newUser = new User();
            newUser._id = buf.toString('hex');
            newUser.twitchtv = prof;
            newUser.twitchtv_tokens = tok;
            newUser.authItems = [];
            newUser.save(function(err){
              return done(err, newUser);
            });
          })
        }
      }
    });
  }));
};

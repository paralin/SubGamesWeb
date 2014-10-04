var passport = require('passport');
var SteamStrategy = require('passport-steam').Strategy;
var Steam = require('steam-webapi');
var request = require('request');
var _ = require('lodash');

var steam;
exports.setup = function (User, config) {
  Steam.key = process.env.STEAM_API;
  Steam.ready(function(err){
    console.log("Steam web api ready.");
    steam = new Steam();
  });

  passport.serializeUser(function(user, done){
    done(null, user._id);
  });

  passport.deserializeUser(function(id, done){
    User.findById(id, function(err, user){
      if(user){
        if(user.steam && user.steam.steamid && user.twitchtv && user.twitchtv.id){
          if(!_.contains(user.authItems, 'play')){
            user.authItems.push("play");
            user.save();
          }
          if(!_.contains(user.authItems, 'streamer') && _.contains(["76561197961827458", "76561198029304414"], user.steam.steamid)){
            user.authItems.push("streamer");
            user.save();
          }
        }else{
          if(_.contains(user.authItems, "play")){
            user.authItems = [];
            user.save();
          }
        }
      }
      done(err, user);
    });
  });

  passport.use(new SteamStrategy({
    returnURL: process.env.DOMAIN+'/auth/steam/return',
    realm: process.env.DOMAIN+'/',
    apiKey: process.env.STEAM_API,
    stateless: true,
    profile: false,
    passReqToCallback: true
  },
  function(req, identifier, profile, done){
    var steamid = identifier.split('/');
    steamid = steamid[steamid.length-1];
    steam.getPlayerSummaries({steamids: steamid}, function(err, data){
      if(err)
        return done(err);
      profile = data.players[0];
      User.findOne({'steam.steamid': profile.steamid}, function(err, user){
        if(err) return done(err);
        if(req.user){
          if(user && req.user._id !== user._id){
            if(user.twitchtv){
              user.steam = null;
              user.save();
            }else{
              console.log("Deleting user "+user._id+" when linking with Steam.");
              User.remove({"_id": user._id});
            }
          }
          req.user.steam = profile;
          req.user.save(function(error){
            return done(error, req.user);
          });
        }else{
          if(user){
            user.steam = profile;
            user.authItems = [];
            user.save(function(err){
              return done(err, user);
            });
          }else{
            require('crypto').randomBytes(12, function(ex, buf){
              var newUser = new User();
              newUser._id = buf.toString('hex');
              newUser.steam = profile;
              newUser.authItems = [];
              newUser.save(function(err){
                return done(err, newUser);
              });
            });
          }
        }
      })
    });
  }));
};

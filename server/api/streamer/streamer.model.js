'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var StreamerSchema = new Schema({
  _id: String,
  name: String,
  logo: String,
  url: String,
  uid: String
});

module.exports = mongoose.model('Streamer', StreamerSchema, "streamers");

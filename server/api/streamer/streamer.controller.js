'use strict';

var _ = require('lodash');
var Streamer = require('./streamer.model');

// Get list of streamers
exports.index = function(req, res) {
  Streamer.find(function (err, streamers) {
    if(err) { return handleError(res, err); }
    return res.json(200, streamers);
  });
};

// Get a single streamer
exports.show = function(req, res) {
  Streamer.findById(req.params.id, function (err, streamer) {
    if(err) { return handleError(res, err); }
    if(!streamer) { return res.send(404); }
    return res.json(streamer);
  });
};

// Creates a new streamer in the DB.
exports.create = function(req, res) {
  Streamer.create(req.body, function(err, streamer) {
    if(err) { return handleError(res, err); }
    return res.json(201, streamer);
  });
};

// Updates an existing streamer in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Streamer.findById(req.params.id, function (err, streamer) {
    if (err) { return handleError(res, err); }
    if(!streamer) { return res.send(404); }
    var updated = _.merge(streamer, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, streamer);
    });
  });
};

// Deletes a streamer from the DB.
exports.destroy = function(req, res) {
  Streamer.findById(req.params.id, function (err, streamer) {
    if(err) { return handleError(res, err); }
    if(!streamer) { return res.send(404); }
    streamer.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}
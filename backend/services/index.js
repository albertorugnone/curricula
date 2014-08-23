var fs = require('fs');
var express = require('express');
var services = express.Router();

var version = '/v1';

var paths = {
  "data" : {
    "alive" : "./backend/data/alive.json"
  },
  "services" : {
    "alive" : version + "/alive"
  }
};

/* GET  */
services.get(paths.services.alive, function(req, res) {
 fs.readFile(paths.data.alive, function(err, data)   {
    if(err) {
      console.log(err);
      res.status(404)
          .set({
            'Content-Type': 'text/plain',
          })
          .send(paths.data.alive + ' not found')
          .send(err);
    } else {
      console.log(data);
      res.status(202)
          .set({
            'Content-Type': 'text/plain',
            })
          .send(data);
    }
  });
});

module.exports = services;

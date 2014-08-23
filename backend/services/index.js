var fs = require('fs');
var express = require('express');
var services = express.Router();

var version = '/v1';

var paths = {
  "data" : {
    "alive" : "./data/alive"
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
      res.status(404).send(paths.data.alive + ' not found');
    } else {
      console.log(data);
       res.status(202).send(data);
    }
  });
});

module.exports = services;

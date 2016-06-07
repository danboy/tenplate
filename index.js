var fs = require('fs');
var self = {
  controllers: function(options){
    var path = (options && options.path) ? options.path : __dirname+'/../../app/controllers/';
    
    options = Object.assign({
      path : path 
    }, options);

    var files = fs.readdirSync(options.path),
        Controllers = {};

    files.forEach(function(controller){
      if (controller === "index.js" || controller.substr(controller.lastIndexOf('.') + 1) !== 'js')
        return;
      var name = controller.charAt(0).toUpperCase()+controller.replace('.js', '').replace('Controller','').slice(1);
      var c = require(options.path+controller);
      Controllers[name] = c;
    });

    return Controllers;
  },
  getControllers: function(options){
    options = Object.assign({
      path : __dirname+'/../../app/controllers/'
    }, options);

    var files = fs.readdirSync(options.path),
        Controllers = {};

    files.forEach(function(controller){
      if (controller === "index.js" || controller.substr(controller.lastIndexOf('.') + 1) !== 'js')
        return;
      var name = controller.charAt(0).toUpperCase()+controller.replace('.js', '').replace('Controller','').slice(1);
      var c = require(path+controller);
      Controllers[name] = c;
    });

    return Controllers;
  },
  locals: function(app){
    var path = __dirname+'/../../app/helpers/',
        files = fs.readdirSync(path);

    files.forEach(function(controller){
      if (controller === "index.js" || controller.substr(controller.lastIndexOf('.') + 1) !== 'js')
        return;
      var locals = require(path+controller);
      for(var key in locals){
        app.set(key, locals[key]);
      }
    });

  },

  merge: function(a, b){
    for (var attrname in b){
      a[attrname] = b[attrname];
    }
    return a;
  }
};

module.exports = self;

var EWSWebService = require('../dist/ews-web-service')
var config = require('./config.json');

var serviceOptions = {
  rejectUnauthorized: false,
  proxy: {host: 'localhost', port: 8888},
  agent: new require('http').Agent({keepAlive: true})
};

var service = new EWSWebService(config.url, serviceOptions);
service.setAuth(config.username, config.password);
service.findItem({
  itemShape: {baseShape: 'idOnly'},
  parentFolderIds: {id: 'deleteditems', type: 'distinguished'}
}).then(function(res) {
  console.log('Done');
}).catch(function(err) {
  throw err;
});

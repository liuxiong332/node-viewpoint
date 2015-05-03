var EWSClient = require('../dist/ews-client')
var config = require('./config.json');

var serviceOptions = {
  rejectUnauthorized: false,
  proxy: {host: 'localhost', port: 8888},
  agent: new require('http').Agent({keepAlive: true})
};

var client = new EWSClient(config.username, config.password, config.url,
  serviceOptions);

client.syncItems({
  maxReturned: 10,
  folderId: {id: 'deleteditems', type: 'distinguished'}
}).then(function(res) {
  console.log('Done');
  console.log(res.syncState());
}).catch(function(err) {
  console.log(err.stack);
});

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
  shape: 'Default',
  syncState: '',
  maxReturned: 10,
  folderId: {id: 'deleteditems', type: 'distinguished'}
}).then(function(res) {
  console.log('Done');
  console.log(res);
  res.forEach(function(item) {
    var info = {
      from: {name: item.from().name, email: item.from().emailAddress},
      subject: item.subject()
    };
    console.log(JSON.stringify(info, null, 2));
  });
}).catch(function(err) {
  console.log(err.stack);
});

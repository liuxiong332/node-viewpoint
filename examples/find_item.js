var EWSClient = require('../dist/ews-client')
var config = require('./config.json');

var serviceOptions = {
  rejectUnauthorized: false,
  // proxy: {host: 'localhost', port: 8888},
  agent: new require('https').Agent({keepAlive: true})
};

var client = new EWSClient(config.username, config.password, config.url,
  serviceOptions);

TRASH_ID = {id: 'deleteditems', type: 'distinguished'}

client.findItems({
  shape: 'IdOnly',
  folderId: TRASH_ID,
  indexedPageItemView: {offset: 0, maxReturned: '6'}
}).then(function(res) {
  res.response().items().forEach(function(item) {
    console.log(item.itemId());
  });
  console.log('Done');
}).catch(function(err) {
  console.log('err', err);
});

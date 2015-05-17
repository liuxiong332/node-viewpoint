# node-viewpoint
[![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url] [![Dependency Status][daviddm-image]][daviddm-url] [![Coverage Status][coveralls-image]][coveralls-url]

the exchange API for nodejs module


## Install

```bash
$ npm install --save viewpoint
```


## Usage

```javascript
var EWSClient = require('viewpoint');
var client = new EWSClient(username, password, ewsUrl, config);
client.syncFolders().then(function(res) {
  console.log('sync folders successfully!');
});
```

More examples can refer to `examples/` in the source repo.

## API

### EWSClient

#### Methods

**constructor**: `function(username, password, url, options)` constructor function

**getFolder**: `function(folderId, opts)`. get the specific folder by folderId

  *folderId*: `String` or `Object`. the `folderId` can be like <id> or {id: <id>, changeKey: <key>}. If you need distinguished id, then you should make `folderId` like {id: <id>, type: 'distinguished'}

  *return*: `Folder`. the `Folder` object

**getFolders**: `function(folderIds, opts)` get folders by folderIds array

  *folderIds* `Array` the array of folderId used to get a list of folder

  *return*: `Array` each item is `Folder`

**findFolders**: `function(opts)` get the folders by the `opts`

**createFolders**: `function(names, opts)` create the folders by the names

**moveFolders**: `function(folderIds, opts)` move the folders that the id is in the `folderIds`

**syncFolders**: `function(opts)` synchronize the folders

### Folder

#### Methods

**totalCount**: `Number` the total count of items

**childFolderCount**: `Number` the count of child folders

**unreadCount**: `Number` the count of unread items

**folderClass**: the folder class such as 'IPF'

**displayName**: the display name

**folderId**: get folder id object

**parentFolderId**: get parent folder id object

### RootFolder

**Methods**

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [gulp](http://gulpjs.com/).


## License

Copyright (c) 2015 liuxiong. Licensed under the MIT license.



[npm-url]: https://npmjs.org/package/node-viewpoint
[npm-image]: https://badge.fury.io/js/node-viewpoint.svg
[travis-url]: https://travis-ci.org/liuxiong332/node-viewpoint
[travis-image]: https://travis-ci.org/liuxiong332/node-viewpoint.svg?branch=master
[daviddm-url]: https://david-dm.org/liuxiong332/node-viewpoint
[daviddm-image]: https://david-dm.org/liuxiong332/node-viewpoint.svg?theme=shields.io
[coveralls-url]: https://coveralls.io/r/liuxiong332/node-viewpoint
[coveralls-image]: https://coveralls.io/repos/liuxiong332/node-viewpoint/badge.png

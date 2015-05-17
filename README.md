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

Many API function return the `Promise` object. For simplicity, I will use `Promise(ObjectType)` to represent the Promise object that return the `ObjectType` object. e.g. for function `foo` that return `Promise(Number)`, you can invoke it with
`foo().then(number) {}`.

### EWSClient

#### Methods

* **constructor**: `function(username, password, url, options).` Constructor function

* **getFolder**: `function(folderId, opts).` Get the specific folder by folderId

  * *folderId*: `String` or `Object.` The `folderId` can be like <id> or {id: <id>, changeKey: <key>}. If you need distinguished id, then you should make `folderId` like {id: <id>, type: 'distinguished'}

  * *return*: `Promise(Folder).` The `Folder` object

* **getFolders**: `function(folderIds, opts).` Get folders by folderIds array

  * *folderIds* `Array.` The array of folderId used to get a list of folder

  * *return*: `Promise(Array).` Each item is `Folder`

* **findFolders**: `function(opts).` Get the folders by the `opts`

  * *return*: `Promise(RootFolder)`

* **createFolders**: `function(names, opts).` Create the folders by the names

* **moveFolders**: `function(folderIds, opts).` Move the folders that the id is in the `folderIds`

* **syncFolders**: `function(opts).` Synchronize the folders

### Folder

#### Methods

* **totalCount**: `function().` The total count of items

  * *return*: `Number`

* **childFolderCount**: `function().` The count of child folders

  * *return*: `Number`

* **unreadCount**: `function().` The count of unread items

  * *return*: `Number`

* **folderClass**: `function().` The folder class such as 'IPF'

  * *return*: `String`

* **displayName**: `function().` The display name

  * *return*: `String`

* **folderId**: `function().` Get folder id object

  * *return*: `Object`

* **parentFolderId**: `function().` Get parent folder id object

  * *return*: `Object`

### RootFolder

#### Methods

* **totalItemsInView**: `function().` Get the count of return items.

  * *return*: `Number.`

* **includesLastItemInRange**: `function().` Get whether or not the last item is included.

  * *return*: `Bool`

* **items**: `function().` Get the items of folder.

  * *return*: `Array.` The `Array` of `Message`.

* **folders**: `function().` Get the child folders of this folder.

  * *return*: `Array.` The `Array` of `Folder`.

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

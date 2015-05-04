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

_(Coming soon)_


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

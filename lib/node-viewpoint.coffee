
httpntlm = require 'httpntlm'

requestXml = '''
  <?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:t="http://schemas.microsoft.com/exchange/services/2006/types">
    <soap:Body>
      <FindFolder Traversal="Shallow" xmlns="http://schemas.microsoft.com/exchange/services/2006/messages">
        <FolderShape>
          <t:BaseShape>Default</t:BaseShape>
        </FolderShape>
        <ParentFolderIds>
          <t:DistinguishedFolderId Id="inbox"/>
        </ParentFolderIds>
      </FindFolder>
    </soap:Body>
  </soap:Envelope>
  '''

httpConfig =
  url: 'https://bjmail.kingsoft.com/EWS/exchange.asmx'
  username: 'bolt-ci'
  password: 'test1234()'
  workstation: '', domain: ''
  rejectUnauthorized: false
  body: requestXml

# httpntlm.post httpConfig, (err, res) ->
#   throw err if err?
#
#   console.log res.headers
#   console.log res.body

https = require 'https'
request = httpntlm.get httpConfig,  (err, res) ->
  throw err if err?
  console.log("statusCode: ", res.statusCode)
  console.log("headers: ", res.headers)
  res.on 'data', (d)->
    process.stdout.write(d)
# request.on 'error', (e) ->
#   console.log e

module.exports = ->
  'awesome'

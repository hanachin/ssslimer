# Params:
# html:               encodeURIComponent('data:text/html;charset=UTF-8,<b>HelloWorld</b>')
# selector(optional): encodeURIComponent('h1')

CaptureService = require('capture-service').CaptureService
UploadService  = require('upload-service').UploadService
env = require('system').env
fs  = require('fs')

server = require('webserver').create()

console.log "PORT:#{+(env.PORT || 3000)}"
for k, v of env
  console.log "#{k}: #{v}"
server.listen +(env.PORT || 3000), (req, res) ->
  query = parseQueryString(req.queryString)

  console.log "request path: #{req.url}"
  console.log "capture html: #{query.html}"
  console.log "img selector: #{query.selector}"

  captureSetting = html: query.html, selector: query.selector
  uploadSetting  =
    bucket_url: query.bucket_url
    form:
      AWSAccessKeyId: query.AWSAccessKeyId
      key: query.key
      policy: query.policy
      signature: query.signature
      acl: query.acl

  return unless CaptureService.validates(captureSetting)
  return unless UploadService.validates(uploadSetting)

  cs = new CaptureService(captureSetting)
  us = new UploadService(uploadSetting)
  cs.capture ->
    console.log "[capture]\tcapture callback start"
    res.write fs.read(cs.filepath, 'b')
    res.close()
    us.upload(cs.filepath, -> cs.remove())
    console.log "[capture]\tcapture callback end"
  res.setHeader 'Content-Type', 'image/jpeg'
  res.setEncoding 'binary'
  res._response.processAsync()

parseQueryString = (qs) ->
  return {} if qs is ''

  result = {}
  qs.split('&').forEach (kv) ->
    [k, v] = kv.split('=')
    result[k] = decodeURIComponent v
  result

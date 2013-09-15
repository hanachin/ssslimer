# Params:
# url:                encodeURIComponent('http://example.com/')
# selector(optional): encodeURIComponent('h1')
#
# example:
# http://localhost:3000/?url=http%3A%2F%2Fexample.com%2F&selector=h1

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
  console.log "capture url:  #{query.url}"

  captureSetting = url: query.url, selector: query.selector
  uploadSetting  = AWSAccessKeyId: query.AWSAccessKeyId, key: query.key, acl: query.acl, signature: query.signature

  # TODO: move validation logic into upload service && capture service
  return unless validateCaptureSetting(captureSetting)
  # return unless validateUploadSetting(uploadSetting)

  cs = new CaptureService(captureSetting)
  cs.capture ->
    console.log "[capture]\tcapture callback start"
    res.write fs.read(cs.filepath, 'b')
    res.close()
    console.log "[capture]\tcapture callback end"
  res.setHeader 'Content-Type', 'image/jpeg'
  res.setEncoding 'binary'
  res._response.processAsync()

  # TODO: implement upload service
  # cs = new CaptureService(captureSetting)
  # us = new UploadService(uploadSetting)
  # cs.capture -> us.upload(cs.filepath, -> cs.remove())

validateCaptureSetting = (s) -> !!s.url
validateUploadSetting  = (s) -> s.AWSAccessKeyId && s.key && s.acl && s.signature && s.policy

parseQueryString = (qs) ->
  return {} if qs is ''

  result = {}
  qs.split('&').forEach (kv) ->
    [k, v] = kv.split('=')
    result[k] = decodeURIComponent v
  result

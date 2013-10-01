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

port = +(env.PORT || 5000)
console.log "listen port: #{port}"
server.listen port, (req, res) ->
  query = parseQueryString(req.queryString)

  console.log "request path: #{req.url}"
  console.log "capture url:  #{query.url}"

  captureSetting = url: query.url, selector: query.selector
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

  uploadSuccess = ->
    console.log "[upload]\tupload success"
    res.close()
    cs.remove()

  uploadError = ->
    console.log "[upload]\tupload error"
    console.log "[upload]\tupload error"
    res.writeHead(500, {})
    res.close()
    cs.remove()

  captureSuccess = ->
    console.log "[capture]\tcapture success"
    us.upload cs.filepath, success: uploadSuccess, error: uploadError

  captureError = ->
    console.log "[capture]\tcapture error"
    res.writeHead(500, {})
    res.close()

  cs.capture success: captureSuccess, error: captureError

  res._response.processAsync()

parseQueryString = (qs) ->
  return {} if qs is ''

  result = {}
  qs.split('&').forEach (kv) ->
    [k, v] = kv.split('=')
    result[k] = decodeURIComponent v
  result

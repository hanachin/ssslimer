# Params:
# url:                encodeURIComponent('http://example.com/')
# selector(optional): encodeURIComponent('h1')
#
# example:
# http://localhost:3000/?url=http%3A%2F%2Fexample.com%2F&selector=h1

CaptureService = require('capture-service').CaptureService
UploadService  = require('upload-service').UploadService
env = require('system').env

server = require('webserver').create()

server.listen +(env.PORT || 3000), (req, res) ->
  query = parseQueryString(req.queryString)

  captureSetting = url: query.url, selector: query.selector
  uploadSetting  = AWSAccessKeyId: query.AWSAccessKeyId, key: query.key, acl: query.acl, signature: query.signature

  # TODO: move validation logic into upload service && capture service
  return unless validateCaptureSetting(captureSetting)
  # return unless validateUploadSetting(uploadSetting)

  cs = new CaptureService(captureSetting)
  cs.capture()

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

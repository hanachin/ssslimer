fs      = require('fs')
webpage = require('webpage')

UploadService = (@setting) ->
  console.log '[upload]\tinitialize...'
  { @bucket_url, @form } = @setting
  console.log '[upload]\tinitialize done'

UploadService::form_html = ->
 """
<html>
<head>
  <title>S3 POST Form</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
  <form id="s3" action="#{@bucket_url}" method="post" enctype="multipart/form-data">
    <input type="hidden" name="key" value="#{@form.key}">
    <input type="hidden" name="AWSAccessKeyId" value="#{@form.AWSAccessKeyId}">
    <input type="hidden" name="acl" value="#{@form.acl}">
    <input type="hidden" name="policy" value="#{@form.policy}">
    <input type="hidden" name="signature" value="#{@form.signature}">
    <input type="hidden" name="Content-Type" value="image/jpeg">
    <!-- Include any additional input fields here -->
    File to upload to S3:
    <input id="file" name="file" type="file">
    <br>
    <input type="submit" value="Upload File to S3">
  </form>
</body>
</html>
"""

UploadService::upload = (filepath, callback) ->
  console.log "[upload]\tUploading #{filepath}..."
  page = webpage.create()
  page.setContent @form_html(), 'http://example.com/'
  page.uploadFile('#file', filepath)

  bucket_url = @bucket_url
  page.onResourceReceived = ({url, status}) ->
    if bucket_url == url && status == 204
      console.log "[upload]\tUploading #{filepath} done"
      callback?()

  page.evaluate -> document.querySelector('#s3').submit()

exports.UploadService = UploadService

# TODO: upload to s3

UploadService = (@setting) ->
  console.log '[upload]\tinitialize...'
  { @bucket_url, @form } = @setting
  console.log '[upload]\tinitialize done'
  console.log JSON.stringify @bucket_url
  console.log JSON.stringify @form

UploadService::upload = (filepath, callback) ->
  console.log "[upload]\tUploading #{filepath}..."
  console.log "[upload]\tUploading #{filepath} done"
  callback?()

exports.UploadService = UploadService

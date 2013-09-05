# TODO: upload to s3

UploadService = (@setting) ->
  console.log '[upload]\tinitialize...'
  { @AWSAccessKeyId, @key, @acl, @signature } = @setting
  console.log '[upload]\tinitialize done'

UploadService::upload = (filepath, callback) ->
  console.log "[upload]\tUploading #{filepath}..."
  console.log "[upload]\tUploading #{filepath} done"
  callback?()

exports.UploadService = UploadService
